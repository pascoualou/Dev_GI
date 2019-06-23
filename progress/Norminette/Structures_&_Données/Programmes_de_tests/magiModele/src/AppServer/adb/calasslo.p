/*-----------------------------------------------------------------------------
File        : calasslo.p
Purpose     : Module de calcul de la rubrique de quittancement 504  pour l'application de l'assurance locative
Author(s)   : LG - 2000/07/09, Kantena - 2017/12/21
Notes       : reprise de adb/srtc/quit/calasslo.p
derniere revue: 2018/04/26 - phm: OK   mais attention, bail/include/isgesflo.i KO

 01  16/10/2000  LG   Mettre tous les montants en ROUND de 2
 02  28/03/2001  AD   Gestion devise (0301/0761)
 03  29/11/2001  SY   CREDIT LYONNAIS: les fournisseurs loyer ont leur mois de qtt & mois modifiable différents de celui des locataires (GlMflQtt & GlMflMdf)
 04  04/03/2004  SY   Correction code retour si tout OK ("00")
 05  16/09/2008  SY   0608/0065 Gestion mandats 5 chiffres
 06  23/09/2008  SY   0608/0065: détection bail FL par la nature du mandat maitre et non plus les bornes noflodeb
 21  08/12/2008  PL   0408/0032: Hono Loc par le quit.
-----------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/codePeriode.i}
&scoped-define NoRub504 504
&scoped-define NoLib504  01

using parametre.pclie.parametrageFournisseurLoyer.
using parametre.syspr.syspr.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{adb/include/ttAsloc.i}
{bail/include/rubqt.i}       // attention, rubqt, pas prrub !!!???
{bail/include/equit.i &nomtable=ttqtt}
{bail/include/tmprub.i}
{bail/include/isgesflo.i}    //  fonctions: donneBailSousLoc, donneBailSousLocDeleguee, donneMandatLoc, donneMandatSousLoc, chargementListeFamilles. procédures: donneLoyerQuittance

define input  parameter pcTypeBail            as character no-undo.
define input  parameter piNumeroBail          as int64     no-undo.
define input  parameter piNumeroQuittance     as integer   no-undo.
define input  parameter pdaDebutPeriode       as date      no-undo.
define input  parameter pdaFinPeriode         as date      no-undo.
define input  parameter pdaDebutQuittancement as date      no-undo.
define input  parameter pdaFinQuittancement   as date      no-undo.
define input  parameter poCollection          as class collection no-undo.
define input-output parameter table for ttQtt.
define input-output parameter table for ttRub.
define output parameter pcCodeRetour          as character no-undo initial "00".

define variable gdeQuittanceTotal  as decimal   no-undo.
define variable gdeQuittanceTaxe   as decimal   no-undo.
define variable gdeLoyerTaxe       as decimal   no-undo.
define variable gdeLoyerTotal      as decimal   no-undo.
define variable gdeMontantRubrique as decimal   no-undo.
define variable giNombreRubrique   as integer   no-undo.
define variable ghProcAsloc        as handle    no-undo.
define variable goSyspr            as class syspr                       no-undo.
define variable goFournisseurLoyer as class parametrageFournisseurLoyer no-undo.

function lecTauTax returns decimal(pcTypeTva as character):
    /*---------------------------------------------------------------------------
    Purpose : Procedure de lecture du taux à appliquer
    Notes   :
    ---------------------------------------------------------------------------*/
    goSyspr:reload("CDTVA", pcTypeTva).
    return if goSyspr:isDbParameter then goSyspr:zone1 else 0.
end function.

run adb/asloc_crud.p persistent set ghProcAsloc.
run getTokenInstance in ghProcAsloc(mToken:JSessionId).
assign
    goFournisseurLoyer = new parametrageFournisseurLoyer()    // Recuperation du paramètre GESFL
    goSyspr            = new syspr("CDTVA", "")               // instancié avant boucle.
.
run calassloPrivate.

delete object goSyspr no-error.
delete object goFournisseurLoyer no-error.
run destroy in ghProcAsloc no-error.

procedure calassloPrivate private:
    /*---------------------------------------------------------------------------
    Purpose : Procedure de lecture du taux à appliquer
    Notes   :
    ---------------------------------------------------------------------------*/
    define variable viCompteur               as integer   no-undo.
    define variable viItemBareme             as integer   no-undo.
    define variable vcTypeTva                as character no-undo.
    define variable vdeTauxTva               as decimal   no-undo.
    define variable vdeChargesTaxe           as decimal   no-undo.
    define variable vdeChargesTotal          as decimal   no-undo.
    define variable vdeImpotTaxe             as decimal   no-undo.
    define variable vdeImpotTotal            as decimal   no-undo.
    define variable vdeLoyerImpotTaxe        as decimal   no-undo.
    define variable vdeLoyerImpotTotal       as decimal   no-undo.
    define variable vdeQuittanceMontant      as decimal   no-undo.
    define variable vdeQuittanceMontantTotal as decimal   no-undo.
    define variable vdeAssuranceLocatif      as decimal   no-undo.
    define variable vdeAssuranceLocatifTotal as decimal   no-undo.
    define variable vdePrimeAssurance        as decimal   no-undo.
    define variable vdePrimeAssuranceTotal   as decimal   no-undo.
    define variable vdeHonoraire             as decimal   no-undo.
    define variable vdeHonoraireTotal        as decimal   no-undo.
    define variable vdeHonoraireLocatif      as decimal   no-undo.
    define variable vdeHonoraireLocatifTotal as decimal   no-undo.
    define variable vdeMontant504            as decimal   no-undo.
    define variable vdeTotal504              as decimal   no-undo.
    define variable vdeMontantTva            as decimal   no-undo.
    define variable vdeTotalTva              as decimal   no-undo.
    define variable viMoisQuittancement      as integer   no-undo.
    define variable vcCodeTerme              as character no-undo initial "00001".
    define variable viMoisModifiable         as integer   no-undo.
    define variable vde1                     as decimal   no-undo.    // todo  trouver un nom plus parlant !
    define variable vde2                     as decimal   no-undo.
    define buffer tache    for tache.
    define buffer vbTache  for tache.
    define buffer vb2Tache for tache.
    define buffer ctrat    for ctrat.

    /* Recherche si locataire Avance ou Echu */
    for last tache no-lock
        where tache.tpcon = {&TYPECONTRAT-bail}
          and tache.nocon = piNumeroBail
          and tache.tptac = {&TYPETACHE-quittancement}:
        vcCodeTerme = tache.ntges.
    end.
    /* Ini mois modifiable du locataire */
    if goFournisseurLoyer:isGesFournisseurLoyer()
    and can-find(first ctrat no-lock
                 where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
                   and ctrat.nocon = integer(truncate(piNumeroBail / 100000, 0))
                   and (ctrat.ntcon = {&NATURECONTRAT-mandatLocation}
                     or ctrat.ntcon = {&NATURECONTRAT-mandatLocationIndivision}))
    then viMoisModifiable = poCollection:getInteger("GlMflMdf").
    else viMoisModifiable = if vcCodeTerme = "00002"
                            then poCollection:getInteger("GlMoiMec")
                            else poCollection:getInteger("GlMoiMdf").

    /* Recherche mois quitt de la quittance traitée */
    for first ttQtt
        where ttQtt.NoLoc = piNumeroBail
          and ttQtt.NoQtt = piNumeroQuittance:
        viMoisQuittancement = ttQtt.msqtt.
    end.
    /* Suppression de tous les enreg concernant la quittance dans ttRub pour la rubrique 504 Assurance locative */
    for each ttRub
        where ttRub.NoLoc = piNumeroBail
          and ttRub.NoQtt = piNumeroQuittance
          and ttRub.NoRub = {&NoRub504}:
        assign
            gdeMontantRubrique = gdeMontantRubrique + ttRub.vlmtq
            giNombreRubrique   = giNombreRubrique + 1
        .
        delete ttRub no-error.
    end.
    /* Mise a jour du total de la quittance déduction du total des rubriques supprimées */
    assign
        gdeMontantRubrique = - gdeMontantRubrique
        giNombreRubrique   = - giNombreRubrique
    .
    run majttQtt.
    run deleteAslocBailMois in ghProcAsloc(piNumeroBail, viMoisQuittancement).
    /* Vérification PEC de la tache Assurance locative */
    if not can-find(first cttac no-lock
                    where cttac.tpcon = pcTypeBail
                      and cttac.nocon = piNumeroBail
                      and cttac.tptac = {&TYPETACHE-assuranceLocative}) then return.

    /* Tests des dates de début de quittance et quittancement et des dates de fin de quittance et de quittancement */
    if (pdaDebutQuittancement < pdaDebutPeriode)
    or (pdaFinQuittancement > pdaFinPeriode)
    or (pdaFinPeriode < pdaDebutPeriode)
    then do:
        pcCodeRetour = "01".
        return.
    end.
    for each ttRub
        where ttRub.noloc = piNumeroBail
          and ttRub.noqtt = piNumeroQuittance:
        /* Calcul somme loyer.*/
        if ttRub.cdfam = 01 and ttRub.cdsfa <> 04
        then assign
            gdeLoyerTaxe  = gdeLoyerTaxe  + ttRub.vlmtq   /* total proraté */
            gdeLoyerTotal = gdeLoyerTotal + ttRub.mttot   /* total période */
        .
        /* Calcul somme charges. */
        if ttRub.cdfam = 02 then assign
            vdeChargesTaxe  = vdeChargesTaxe + ttRub.vlmtq    /* total proraté */
            vdeChargesTotal = vdeChargesTotal + ttRub.mttot   /* total période */
        .
        /* Total quittance */
        assign
            vdeQuittanceMontant      = vdeQuittanceMontant      + ttRub.vlmtq   /* total proraté */
            vdeQuittanceMontantTotal = vdeQuittanceMontantTotal + ttRub.mttot   /* total période */
        .
        /* Calcul somme loyer + charges + Impots et taxes */
        run calTotImp(output vdeImpotTaxe, output vdeImpotTotal).
        /* Calcul somme loyer + Impots et taxes */
        run calLoyTax(output vdeLoyerImpotTaxe, output vdeLoyerImpotTotal).
    end.

    /* Récupération des données dans la table TACHE */
    /* Calculer d'abord la part assurance*/
    for each tache no-lock
        where tache.tpcon = pcTypeBail
          and tache.nocon = piNumeroBail
          and tache.tptac = {&TYPETACHE-assuranceLocative}
          and tache.dtree <= pdaDebutPeriode
          and tache.dtFin >= pdaFinPeriode
          and (tache.dtreg = ? or tache.dtreg >= pdaFinPeriode)
        break by tache.nocon:
        /*Récupération du bareme*/
        do viCompteur = 1 to num-entries(tache.lbdiv, "&"):
            viItemBareme = integer(entry(viCompteur, tache.lbdiv, "&")).
            find last vbTache no-lock
                where vbTache.tpcon = {&TYPECONTRAT-assuranceLocative}
                  and vbTache.nocon = tache.notac
                  and vbTache.tptac = {&TYPETACHE-bareme}
                  and vbTache.notac = viItemBareme no-error.
            if available vbTache
            then do:
                assign
                    vde1 = integer(vbTache.cdreg) / 100
                    vde2 = integer(entry(2, vbTache.lbDiv, "&")) / 100
                .
                case vbTache.pdreg:      /* Mode de calcul pour les assurances */
                    when {&MODECALCUL-loyer} then assign
                        vdeAssuranceLocatif      = (gdeLoyerTaxe  * vde1 + vde2) / 100
                        vdeAssuranceLocatifTotal = (gdeLoyerTotal * vde1 + vde2) / 100
                    .
                    when {&MODECALCUL-quittance} then assign
                        vdeAssuranceLocatif      = (vdeQuittanceMontant      * vde1 + vde2) / 100
                        vdeAssuranceLocatifTotal = (vdeQuittanceMontantTotal * vde1 + vde2) / 100
                    .
                    when {&MODECALCUL-loyerEtCharges} then assign
                        vdeChargesTaxe           = vdeChargesTaxe + gdeLoyerTaxe
                        vdeChargesTotal          = vdeChargesTotal + gdeLoyerTotal
                        vdeAssuranceLocatif      = (vdeChargesTaxe  * vde1 + vde2) / 100
                        vdeAssuranceLocatifTotal = (vdeChargesTotal * vde1 + vde2) / 100
                    .
                    when {&MODECALCUL-loyerEtChargesEtTaxes} then assign
                        vdeAssuranceLocatif      = (vdeImpotTaxe  * vde1 + vde2) / 100
                        vdeAssuranceLocatifTotal = (vdeImpotTotal * vde1 + vde2) / 100
                    .
                    when {&MODECALCUL-loyerEtTaxes} then assign
                        vdeAssuranceLocatif      = (vdeLoyerImpotTaxe  * vde1 + vde2) / 100
                        vdeAssuranceLocatifTotal = (vdeLoyerImpotTotal * vde1 + vde2) / 100
                    .
                end case.
            end.
            /* Calcul du montant total de la prime assur. */
            assign
                vdePrimeAssurance      = vdePrimeAssurance      + round(vdeAssuranceLocatif, 2)
                vdePrimeAssuranceTotal = vdePrimeAssuranceTotal + round(vdeAssuranceLocatifTotal, 2)
            .
            /* Récupérer les montants assur. par contrat */
            find first ttAsloc
                where ttAsloc.noass = tache.notac
                  and ttAsloc.nobar = viItemBareme no-error.
            if available ttAsloc
            then assign
                ttAsloc.MtAss = round(ttAsloc.Mtass, 2) + round(vdeAssuranceLocatif, 2)
                ttAsloc.TtAss = round(ttAsloc.Ttass, 2) + round(vdeAssuranceLocatifTotal, 2)
                ttAsloc.Txass = integer(vbTache.cdreg) / 100
            .
            else do:
                create ttAsloc.
                assign
                    ttAsloc.noass = tache.notac
                    ttAsloc.nobar = viItemBareme
                    ttAsloc.mtass = round(vdeAssuranceLocatif, 2)
                    ttAsloc.Txass = integer(vbTache.cdreg) / 100
                    ttAsloc.Ttass = round(vdeAssuranceLocatifTotal, 2)
                    ttAsloc.noloc = piNumeroBail
                    ttAsloc.msqtt = viMoisQuittancement
                    ttAsloc.CRUD  = "C"
                .
            end.
        end.
        if last-of(tache.nocon) then do:
            /* Nouveau total quittance = total qtt + Part assurance locative*/
            assign
                vdeQuittanceMontant      = vdeQuittanceMontant      + round(vdePrimeAssurance, 2)      /* total proraté */
                vdeQuittanceMontantTotal = vdeQuittanceMontantTotal + round(vdePrimeAssuranceTotal, 2) /* total période */
            .
boucleVbtache:
            for each vbTache no-lock
                where vbTache.tpcon = pcTypeBail
                  and vbTache.nocon = piNumeroBail
                  and vbTache.tptac = {&TYPETACHE-assuranceLocative}
                  and (vbTache.dtree <= pdaDebutPeriode
                  and vbTache.dtFin >= pdaFinPeriode
                  and (vbTache.dtreg = ? or vbTache.dtreg >= pdaFinPeriode)):
                /* Récupération du bareme */
                do viCompteur = 1 to num-entries(vbTache.lbdiv, "&"):
                    viItemBareme = integer(entry(viCompteur, vbTache.lbdiv, "&")).
                    find last vb2Tache no-lock
                        where vb2Tache.tpcon = {&TYPECONTRAT-assuranceLocative}
                          and vb2Tache.nocon = vbTache.notac
                          and vb2Tache.tptac = {&TYPETACHE-bareme}
                          and vb2Tache.notac = viItemBareme no-error.
                    if available vb2Tache
                    then do:
                        assign
                            vde1 = integer(vb2Tache.tpges) / 100
                            vde2 = integer(entry(1, vb2Tache.lbDiv, "&")) / 100
                        .
                        case vb2Tache.pdges:  /* Mode de calcul pour les honoraires par ctt */
                            when {&MODECALCUL-loyer} then assign
                                vdeHonoraireLocatif      = (gdeLoyerTaxe  * vde1 + vde2) / 100
                                vdeHonoraireLocatifTotal = (gdeLoyerTotal * vde1 + vde2) / 100
                            .
                            when {&MODECALCUL-quittance} then assign
                                vdeHonoraireLocatif      = (vdeQuittanceMontant      * vde1 + vde2) / 100
                                vdeHonoraireLocatifTotal = (vdeQuittanceMontantTotal * vde1 + vde2) / 100
                            .
                            when {&MODECALCUL-loyerEtCharges} then assign
                                vdeChargesTaxe           = vdeChargesTaxe + gdeLoyerTaxe
                                vdeChargesTotal          = vdeChargesTotal + gdeLoyerTotal
                                vdeHonoraireLocatif      = (vdeChargesTaxe  * vde1 + vde2) / 100
                                vdeHonoraireLocatifTotal = (vdeChargesTotal * vde1 + vde2) / 100
                            .
                            when {&MODECALCUL-loyerEtChargesEtTaxes} then assign
                                vdeHonoraireLocatif      = (vdeImpotTaxe  * vde1 + vde2) / 100
                                vdeHonoraireLocatifTotal = (vdeImpotTotal * vde1 + vde2) / 100
                            .
                            when {&MODECALCUL-loyerEtTaxes} then assign
                                vdeHonoraireLocatif      = (vdeLoyerImpotTaxe  * vde1 + vde2) / 100
                                vdeHonoraireLocatifTotal = (vdeLoyerImpotTotal * vde1 + vde2) / 100
                            .
                        end case.
                    end.
                    /* Calcul du montant total de la prime Honor. */
                    assign
                        vdeHonoraire      = vdeHonoraire      + round(vdeHonoraireLocatif, 2)
                        vdeHonoraireTotal = vdeHonoraireTotal + round(vdeHonoraireLocatifTotal, 2)
                    .
                    /* Récupérer les montants assur. par contrat */
                    find first ttAsloc
                        where ttAsloc.noass = vbTache.notac
                          and ttAsloc.nobar = viItemBareme no-error.
                    if available ttAsloc then assign
                        ttAsloc.MtHon = round(ttAsloc.MtHon,2) + round(vdeHonoraireLocatif, 2)
                        ttAsloc.TtHon = round(ttAsloc.TtHon,2) + round(vdeHonoraireLocatifTotal, 2)
                        ttAsloc.TxHon = integer(vb2Tache.tpges) / 100
                    .
                    else do:
                        create ttAsloc.
                        assign
                            ttAsloc.noass = tache.notac
                            ttAsloc.Nobar = viItemBareme
                            ttAsloc.TxHon = integer(vb2Tache.tpges) / 100
                            ttAsloc.mtHon = round(vdeHonoraireLocatif, 2)
                            ttAsloc.TtHon = round(vdeHonoraireLocatifTotal, 2)
                            ttAsloc.noloc = piNumeroBail
                            ttAsloc.msqtt = viMoisQuittancement
                            ttAsloc.CRUD  = "C"
                        .
                    end.
                end.
                /* Calcul de la TVA par contrat */
                assign
                    vcTypeTva = ""
                    vdeTauxTva = 0
                .
                /* Récupération du contrat assurance associé */
                for first ctrat no-lock
                    where ctrat.tpcon = {&TYPECONTRAT-assuranceLocative}
                      and ctrat.nocon = vbTache.notac:
                    assign
                        vcTypeTva  = ctrat.tpren
                        vdeTauxTva = lecTauTax(ctrat.tpact)
                    .
                end.
                if vdeTauxTva = 0 then next boucleVbtache.

                assign
                    vdeMontant504 = 0
                    vdeTotal504   = 0
                .
                case vcTypeTva:
                    when "00001" then do:
                        for each ttAsloc
                            where ttAsloc.noass = vbTache.notac:
                            assign
                                vdeMontant504  = round(vdeMontant504, 2) + round(ttAsloc.mtass, 2) + round(ttAsloc.mthon, 2)
                                vdeTotal504    = round(vdeTotal504, 2)   + round(ttAsloc.Ttass, 2) + round(ttAsloc.Tthon, 2)
                                ttAsloc.mttva = ((round(ttAsloc.mtass, 2) + round(ttAsloc.mthon, 2)) * vdeTauxTva) / 100
                                ttAsloc.tttva = ((round(ttAsloc.ttass, 2) + round(ttAsloc.tthon, 2)) * vdeTauxTva) / 100
                            .
                        end.
                        assign
                            vdeMontantTva = round(vdeMontantTva, 2) + ((round(vdeMontant504, 2) * vdeTauxTva) / 100)
                            vdeTotalTva   = round(vdeTotalTva, 2)   + ((round(vdeTotal504, 2) * vdeTauxTva) / 100)
                        .
                    end.
                    when "00002" then do:
                        for each ttAsloc
                            where ttAsloc.noass = vbTache.notac:
                            assign
                                vdeMontant504  = round(vdeMontant504, 2) + round(ttAsloc.mthon, 2)
                                vdeTotal504    = round(vdeTotal504, 2)   + round(ttAsloc.Tthon, 2)
                                ttAsloc.mttva = (round(ttAsloc.mthon, 2) * vdeTauxTva) / 100
                                ttAsloc.tttva = (round(ttAsloc.tthon, 2) * vdeTauxTva) / 100
                            .
                        end.
                        assign
                            vdeMontantTva = vdeMontantTva + ((round(vdeMontant504, 2) * vdeTauxTva) / 100)
                            vdeTotalTva   = vdeTotalTva   + ((round(vdeTotal504, 2) * vdeTauxTva) / 100)
                        .
                    end.
                end case.
            end.
            /* cumul de la rubrique assurance locative */
            assign
                gdeQuittanceTaxe  = round(gdeQuittanceTaxe, 2)  + round(vdePrimeAssurance, 2)      + round(vdeHonoraire, 2)      + round(vdeMontantTva, 2)
                gdeQuittanceTotal = round(gdeQuittanceTotal, 2) + round(vdePrimeAssuranceTotal, 2) + round(vdeHonoraireTotal, 2) + round(vdeTotalTva, 2)
            .
        end.
    end.
    /* Création de la rubrique 504 */
    if gdeQuittanceTaxe <> 0 then do:
        if viMoisQuittancement = viMoisModifiable
        then run setAsloc in ghProcAsloc(table ttAsloc by-reference).
        run creRub504.
    end.
end procedure.

procedure calTotImp:
    /*---------------------------------------------------------------------------
    Purpose : calcul du total loyer + Charges + Impots et Taxes (sauf APL et TVA)
    Notes   : Ajout PL le 10/12/2008 : Sauf hono LOC => Fam 08 & 09
    ---------------------------------------------------------------------------*/
    define output parameter pdeMontantQuittance as decimal  no-undo.
    define output parameter pdeMontantTotal     as decimal  no-undo.

    for each ttRub
        where ttRub.noloc = piNumeroBail
          and ttRub.noqtt = piNumeroQuittance:
        if (ttRub.cdfam = 01 and ttRub.cdsfa <> 04)
        or (ttRub.cdfam = 02)
        or (ttRub.cdfam = 05 and ttRub.cdsfa = 01 )
        or (ttRub.cdfam = 05 and ttRub.norub = 750)
        or (ttRub.cdfam = 05 and ttRub.norub = 751)
        or (ttRub.cdfam = 05 and ttRub.norub = 760)
        or (ttRub.cdfam = 05 and ttRub.norub = 761)
        or (ttRub.cdfam = 05 and ttRub.norub = 770)
        or (ttRub.cdfam = 05 and ttRub.norub = 771)
        or (ttRub.cdfam = 05 and ttRub.norub = 777)
        then assign
            pdeMontantQuittance = pdeMontantQuittance + ttRub.vlmtq
            pdeMontantTotal     = pdeMontantTotal     + ttRub.mttot
        .
    end.

end procedure.

procedure calLoyTax:
    /*---------------------------------------------------------------------------
    Purpose : calcule du total loyer + Impots et Taxes (sauf APL et TVA)
    Notes   : Ajout PL le 10/12/2008 : Sauf hono LOC => Fam 08 & 09
    ---------------------------------------------------------------------------*/
    define output parameter pdeMontantQuittance as decimal  no-undo.
    define output parameter pdeMontantTotal as decimal  no-undo.

    for each ttRub
        where ttRub.noloc = piNumeroBail
          and ttRub.noqtt = piNumeroQuittance:
        if (ttRub.cdfam = 01 and ttRub.cdsfa <> 04)
        or (ttRub.cdfam = 05 and ttRub.cdsfa = 01 )
        or (ttRub.cdfam = 05 and ttRub.norub = 750)
        or (ttRub.cdfam = 05 and ttRub.norub = 751)
        or (ttRub.cdfam = 05 and ttRub.norub = 760)
        or (ttRub.cdfam = 05 and ttRub.norub = 761)
        or (ttRub.cdfam = 05 and ttRub.norub = 770)
        or (ttRub.cdfam = 05 and ttRub.norub = 771)
        or (ttRub.cdfam = 05 and ttRub.norub = 777)
        then assign
            pdeMontantQuittance = pdeMontantQuittance + ttRub.vlmtq    /* montant quittancé */
            pdeMontantTotal     = pdeMontantTotal     + ttRub.mttot    /* montant total période */
        .
    end.

end procedure.

procedure creRub504:
    /*---------------------------------------------------------------------------
    Purpose : Procedure de création d'une rubrique 504 dans ttRub
    Notes   : Ajout PL le 10/12/2008 : Sauf hono LOC => Fam 08 & 09
    ---------------------------------------------------------------------------*/
    define variable vhProcRubqt as handle no-undo.

    run bail/quittancement/rubqt_crud.p persistent set vhProcRubqt.
    run getTokenInstance in vhProcRubqt(mToken:JSessionId).
    empty temp-table ttRubqt.
    run readRubqt in vhProcRubqt({&NoRub504}, {&NoLib504}, table ttRubqt by-reference).
    run destroy in vhProcRubqt.
    for first ttRubqt:
        create ttRub.
        assign
            ttRub.NoLoc = piNumeroBail
            ttRub.NoQtt = piNumeroQuittance
            ttRub.CdFam = ttRubqt.cdFam
            ttRub.CdSfa = ttRubqt.cdSfa
            ttRub.NoRub = {&NoRub504}
            ttRub.NoLib = {&NoLib504}
            ttRub.LbRub = outilTraduction:getLibelle(ttRubqt.nome1)
            ttRub.CdGen = ttRubqt.cdgen
            ttRub.CdSig = ttRubqt.cdsig
            ttRub.CdDet = "0"
            ttRub.VlQte = 0
            ttRub.VlPun = 0
            ttRub.MtTot = gdeQuittanceTotal
            ttRub.CdPro = 0
            ttRub.VlNum = 0
            ttRub.VlDen = 0
            ttRub.VlMtq = gdeQuittanceTaxe
            ttRub.DtDap = pdaDebutQuittancement
            ttRub.DtFap = pdaFinQuittancement
            ttRub.NoLig = 0
            /* Modification du montant de la quittance. Dans ttQtt.mtqtt */
            gdeMontantRubrique = gdeQuittanceTaxe
            giNombreRubrique   = 1
        .
        run majttQtt.
    end.

end procedure.

procedure majttQtt:
    /*---------------------------------------------------------------------------
    Purpose : Procedure qui met à jour le montant quittance pour la rubrique dans ttQtt
    Notes   :
    ---------------------------------------------------------------------------*/
    for first ttQtt
        where ttQtt.NoLoc = piNumeroBail
          and ttQtt.NoQtt = piNumeroQuittance:
        assign
            ttQtt.MtQtt = ttQtt.MtQtt + gdeMontantRubrique
            ttQtt.NbRub = ttQtt.NbRub + giNombreRubrique
            ttQtt.CdMaj = 1
        .
    end.
end procedure.
