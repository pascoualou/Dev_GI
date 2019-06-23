/*-----------------------------------------------------------------------------
File        : calasslo.p
Purpose     : Module de calcul de la rubrique de quittancement 504  pour l'application de l'assurance locative
Author(s)   : LG - 2000/07/09, Kantena - 2017/12/21
Notes       : reprise de adb/srtc/quit/calasslo.p
derniere revue: 2018/08/13 - phm: OK

 01  16/10/2000  LG   Mettre tous les montants en ROUND de 2
 02  28/03/2001  AD   Gestion devise (0301/0761)
 03  29/11/2001  SY   CREDIT LYONNAIS: les fournisseurs loyer ont leur mois de qtt & mois modifiable différents de celui des locataires (GlMflQtt & GlMflMdf)
 04  04/03/2004  SY   Correction code retour si tout OK ("00")
 05  16/09/2008  SY   0608/0065 Gestion mandats 5 chiffres
 06  23/09/2008  SY   0608/0065: détection bail FL par la nature du mandat maitre et non plus les bornes noflodeb
 21  08/12/2008  PL   0408/0032: Hono Loc par le quit.
-----------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/mode2calcul.i}
{preprocesseur/param2locataire.i}
&scoped-define NoRub504 504
&scoped-define NoLib504  01

using parametre.pclie.parametrageFournisseurLoyer.
using parametre.syspr.syspr.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{adb/include/ttAsloc.i}
{crud/include/rubqt.i}
{bail/include/tbtmpqtt.i}
{bail/include/tbtmprub.i}
{bail/include/isgesflo.i}    //  fonctions: donneBailSousLoc, donneBailSousLocDeleguee, donneMandatLoc, donneMandatSousLoc, chargementListeFamilles. procédures: donneLoyerQuittance

{outils/include/lancementProgramme.i}

define variable goCollectionHandlePgm as class collection                  no-undo.
define variable goCollectionContrat   as class collection                  no-undo.
define variable goSyspr               as class syspr                       no-undo.
define variable goFournisseurLoyer    as class parametrageFournisseurLoyer no-undo.
define variable gcTypeBail            as character no-undo.
define variable giNumeroBail          as int64     no-undo.
define variable giNumeroQuittance     as integer   no-undo.
define variable gdaDebutPeriode       as date      no-undo.
define variable gdaFinPeriode         as date      no-undo.
define variable gdaDebutQuittancement as date      no-undo.
define variable gdaFinQuittancement   as date      no-undo.
define variable gdeQuittanceTotal     as decimal   no-undo.
define variable gdeQuittanceTaxe      as decimal   no-undo.
define variable gdeLoyerTaxe          as decimal   no-undo.
define variable gdeLoyerTotal         as decimal   no-undo.
define variable gdeMontantRubrique    as decimal   no-undo.
define variable giNombreRubrique      as integer   no-undo.
define variable ghProcAsloc           as handle    no-undo.

function lecTauTax returns decimal private(pcTypeTva as character):
    /*---------------------------------------------------------------------------
    Purpose : Procedure de lecture du taux à appliquer
    Notes   :
    ---------------------------------------------------------------------------*/
    goSyspr:reload("CDTVA", pcTypeTva).
    return if goSyspr:isDbParameter then goSyspr:zone1 else 0.
end function.

procedure lancementCalasslo:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   : service externe
    ------------------------------------------------------------------------*/
    define input parameter poCollectionContrat   as class collection no-undo.
    define input parameter poCollectionQuittance as class collection no-undo.
    define input-output parameter table for ttQtt.
    define input-output parameter table for ttRub.

    assign   
        gcTypeBail            = poCollectionContrat:getCharacter("cTypeContrat")
        giNumeroBail          = poCollectionContrat:getInt64("iNumeroContrat")
        giNumeroQuittance     = poCollectionQuittance:getInteger("iNumeroQuittance")
        gdaDebutPeriode       = poCollectionQuittance:getDate("daDebutPeriode")
        gdaFinPeriode         = poCollectionQuittance:getDate("daFinPeriode")
        gdaDebutQuittancement = poCollectionQuittance:getDate("daDebutQuittancement")
        gdaFinQuittancement   = poCollectionQuittance:getDate("daFinQuittancement")
        goCollectionContrat   = poCollectionContrat
        goCollectionHandlePgm = new collection()    
        goFournisseurLoyer    = new parametrageFournisseurLoyer()    // Recuperation du paramètre GESFL
        goSyspr               = new syspr("CDTVA", "")               // instancié avant boucle.            
        ghProcAsloc           = lancementPgm("crud/asloc_CRUD.p", goCollectionHandlePgm).
    .
    run calassloPrivate.
    delete object goSyspr no-error.
    delete object goFournisseurLoyer no-error.
    suppressionPgmPersistent(goCollectionHandlePgm).

end procedure.

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
    define variable vcCodeTerme              as character no-undo initial {&TERMEQUITTANCEMENT-avance}.
    define variable viMoisModifiable         as integer   no-undo.
    define variable vdeTauxAss               as decimal   no-undo.    
    define variable vdeForfaitAss            as decimal   no-undo.
    define buffer tache    for tache.
    define buffer vbTache  for tache.
    define buffer vb2Tache for tache.
    define buffer ctrat    for ctrat.

    /* Recherche si locataire Avance ou Echu */
    for last tache no-lock
        where tache.tpcon = {&TYPECONTRAT-bail}
          and tache.nocon = giNumeroBail
          and tache.tptac = {&TYPETACHE-quittancement}:
        vcCodeTerme = tache.ntges.
    end.
    /* Ini mois modifiable du locataire */
    if goCollectionContrat:getLogical("lBailFournisseurLoyer")
    then viMoisModifiable = goCollectionContrat:getInteger("iMoisModifiable").
    else if vcCodeTerme = {&TERMEQUITTANCEMENT-echu}
         then viMoisModifiable = goCollectionContrat:getInteger("iMoisModifiable").
         else viMoisModifiable = goCollectionContrat:getInteger("iMoisEchu"). 

    /* Recherche mois quitt de la quittance traitée */
    for first ttQtt
        where ttQtt.iNumeroLocataire = giNumeroBail
          and ttQtt.iNoQuittance = giNumeroQuittance:
        viMoisQuittancement = ttQtt.iMoisTraitementQuitt.
    end.
    /* Suppression de tous les enreg concernant la quittance dans ttRub pour la rubrique 504 Assurance locative */
    for each ttRub
        where ttRub.iNumeroLocataire = giNumeroBail
          and ttRub.iNoQuittance = giNumeroQuittance
          and ttRub.iNorubrique = {&NoRub504}:
        assign
            gdeMontantRubrique = gdeMontantRubrique + ttRub.dMontantQuittance
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
    run deleteAslocBailMois in ghProcAsloc(giNumeroBail, viMoisQuittancement).
    /* Vérification PEC de la tache Assurance locative */
    if not can-find(first cttac no-lock
                    where cttac.tpcon = gcTypeBail
                      and cttac.nocon = giNumeroBail
                      and cttac.tptac = {&TYPETACHE-assuranceLocative}) then return.

    for each ttRub
        where ttRub.iNumeroLocataire = giNumeroBail
          and ttRub.iNoQuittance = giNumeroQuittance:
        /* Calcul somme loyer.*/
        if ttRub.iFamille = 01 and ttRub.iSousFamille <> 04
        then assign
            gdeLoyerTaxe  = gdeLoyerTaxe  + ttRub.dMontantQuittance   /* total proraté */
            gdeLoyerTotal = gdeLoyerTotal + ttRub.dMontantTotal   /* total période */
        .
        /* Calcul somme charges. */
        if ttRub.iFamille = 02 then assign
            vdeChargesTaxe  = vdeChargesTaxe + ttRub.dMontantQuittance    /* total proraté */
            vdeChargesTotal = vdeChargesTotal + ttRub.dMontantTotal   /* total période */
        .
        /* Total quittance */
        assign
            vdeQuittanceMontant      = vdeQuittanceMontant      + ttRub.dMontantQuittance   /* total proraté */
            vdeQuittanceMontantTotal = vdeQuittanceMontantTotal + ttRub.dMontantTotal   /* total période */
        .
        /* Calcul somme loyer + charges + Impots et taxes */
        run calTotImp(output vdeImpotTaxe, output vdeImpotTotal).
        /* Calcul somme loyer + Impots et taxes */
        run calLoyTax(output vdeLoyerImpotTaxe, output vdeLoyerImpotTotal).
    end.

    /* Récupération des données dans la table TACHE */
    /* Calculer d'abord la part assurance*/
    for each tache no-lock
        where tache.tpcon = gcTypeBail
          and tache.nocon = giNumeroBail
          and tache.tptac = {&TYPETACHE-assuranceLocative}
          and tache.dtree <= gdaDebutPeriode
          and tache.dtFin >= gdaFinPeriode
          and (tache.dtreg = ? or tache.dtreg >= gdaFinPeriode)
        break by tache.nocon:
        /*Récupération du bareme*/
        do viCompteur = 1 to num-entries(tache.lbdiv, "&"):
            viItemBareme = integer(entry(viCompteur, tache.lbdiv, "&")).
            for first vbTache no-lock
                where vbTache.tpcon = {&TYPECONTRAT-assuranceLocative}
                  and vbTache.nocon = tache.notac
                  and vbTache.tptac = {&TYPETACHE-bareme}
                  and vbTache.notac = viItemBareme:
                assign
                    vdeTauxAss    = integer(vbTache.cdreg) / 100
                    vdeForfaitAss = integer(entry(2, vbTache.lbDiv, "&")) / 100
                .
                case vbTache.pdreg:      /* Mode de calcul pour les assurances */
                    when {&MODECALCUL-loyer} then assign
                        vdeAssuranceLocatif      = (gdeLoyerTaxe  * vdeTauxAss + vdeForfaitAss) / 100
                        vdeAssuranceLocatifTotal = (gdeLoyerTotal * vdeTauxAss + vdeForfaitAss) / 100
                    .
                    when {&MODECALCUL-quittance} then assign
                        vdeAssuranceLocatif      = (vdeQuittanceMontant      * vdeTauxAss + vdeForfaitAss) / 100
                        vdeAssuranceLocatifTotal = (vdeQuittanceMontantTotal * vdeTauxAss + vdeForfaitAss) / 100
                    .
                    when {&MODECALCUL-loyerEtCharges} then assign
                        vdeChargesTaxe           = vdeChargesTaxe + gdeLoyerTaxe
                        vdeChargesTotal          = vdeChargesTotal + gdeLoyerTotal
                        vdeAssuranceLocatif      = (vdeChargesTaxe  * vdeTauxAss + vdeForfaitAss) / 100
                        vdeAssuranceLocatifTotal = (vdeChargesTotal * vdeTauxAss + vdeForfaitAss) / 100
                    .
                    when {&MODECALCUL-loyerEtChargesEtTaxes} then assign
                        vdeAssuranceLocatif      = (vdeImpotTaxe  * vdeTauxAss + vdeForfaitAss) / 100
                        vdeAssuranceLocatifTotal = (vdeImpotTotal * vdeTauxAss + vdeForfaitAss) / 100
                    .
                    when {&MODECALCUL-loyerEtTaxes} then assign
                        vdeAssuranceLocatif      = (vdeLoyerImpotTaxe  * vdeTauxAss + vdeForfaitAss) / 100
                        vdeAssuranceLocatifTotal = (vdeLoyerImpotTotal * vdeTauxAss + vdeForfaitAss) / 100
                    .
                end case.
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
                        ttAsloc.noloc = giNumeroBail
                        ttAsloc.msqtt = viMoisQuittancement
                        ttAsloc.CRUD  = "C"
                    .
                end.
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
                where vbTache.tpcon = gcTypeBail
                  and vbTache.nocon = giNumeroBail
                  and vbTache.tptac = {&TYPETACHE-assuranceLocative}
                  and (vbTache.dtree <= gdaDebutPeriode
                  and vbTache.dtFin >= gdaFinPeriode
                  and (vbTache.dtreg = ? or vbTache.dtreg >= gdaFinPeriode)):
                /* Récupération du bareme */
                do viCompteur = 1 to num-entries(vbTache.lbdiv, "&"):
                    viItemBareme = integer(entry(viCompteur, vbTache.lbdiv, "&")).
                    for first vb2Tache no-lock
                        where vb2Tache.tpcon = {&TYPECONTRAT-assuranceLocative}
                          and vb2Tache.nocon = vbTache.notac
                          and vb2Tache.tptac = {&TYPETACHE-bareme}
                          and vb2Tache.notac = viItemBareme:
                        assign
                            vdeTauxAss    = integer(vb2Tache.tpges) / 100
                            vdeForfaitAss = integer(entry(1, vb2Tache.lbDiv, "&")) / 100
                        .
                        case vb2Tache.pdges:  /* Mode de calcul pour les honoraires par ctt */
                            when {&MODECALCUL-loyer} then assign
                                vdeHonoraireLocatif      = (gdeLoyerTaxe  * vdeTauxAss + vdeForfaitAss) / 100
                                vdeHonoraireLocatifTotal = (gdeLoyerTotal * vdeTauxAss + vdeForfaitAss) / 100
                            .
                            when {&MODECALCUL-quittance} then assign
                                vdeHonoraireLocatif      = (vdeQuittanceMontant      * vdeTauxAss + vdeForfaitAss) / 100
                                vdeHonoraireLocatifTotal = (vdeQuittanceMontantTotal * vdeTauxAss + vdeForfaitAss) / 100
                            .
                            when {&MODECALCUL-loyerEtCharges} then assign
                                vdeChargesTaxe           = vdeChargesTaxe + gdeLoyerTaxe
                                vdeChargesTotal          = vdeChargesTotal + gdeLoyerTotal
                                vdeHonoraireLocatif      = (vdeChargesTaxe  * vdeTauxAss + vdeForfaitAss) / 100
                                vdeHonoraireLocatifTotal = (vdeChargesTotal * vdeTauxAss + vdeForfaitAss) / 100
                            .
                            when {&MODECALCUL-loyerEtChargesEtTaxes} then assign
                                vdeHonoraireLocatif      = (vdeImpotTaxe  * vdeTauxAss + vdeForfaitAss) / 100
                                vdeHonoraireLocatifTotal = (vdeImpotTotal * vdeTauxAss + vdeForfaitAss) / 100
                            .
                            when {&MODECALCUL-loyerEtTaxes} then assign
                                vdeHonoraireLocatif      = (vdeLoyerImpotTaxe  * vdeTauxAss + vdeForfaitAss) / 100
                                vdeHonoraireLocatifTotal = (vdeLoyerImpotTotal * vdeTauxAss + vdeForfaitAss) / 100
                            .
                        end case.
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
                            ttAsloc.mtHon = round(ttAsloc.mtHon,2) + round(vdeHonoraireLocatif, 2)
                            ttAsloc.ttHon = round(ttAsloc.ttHon,2) + round(vdeHonoraireLocatifTotal, 2)
                            ttAsloc.txHon = integer(vb2Tache.tpges) / 100
                        .
                        else do:
                            create ttAsloc.
                            assign
                                ttAsloc.noass = tache.notac
                                ttAsloc.nobar = viItemBareme
                                ttAsloc.txHon = integer(vb2Tache.tpges) / 100
                                ttAsloc.mtHon = round(vdeHonoraireLocatif, 2)
                                ttAsloc.ttHon = round(vdeHonoraireLocatifTotal, 2)
                                ttAsloc.noloc = giNumeroBail
                                ttAsloc.msqtt = viMoisQuittancement
                                ttAsloc.CRUD  = "C"
                            .
                        end.
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

procedure calTotImp private:
    /*---------------------------------------------------------------------------
    Purpose : calcul du total loyer + Charges + Impots et Taxes (sauf APL et TVA)
    Notes   : Ajout PL le 10/12/2008 : Sauf hono LOC => Fam 08 & 09
    ---------------------------------------------------------------------------*/
    define output parameter pdeMontantQuittance as decimal  no-undo.
    define output parameter pdeMontantTotal     as decimal  no-undo.

    for each ttRub
        where ttRub.iNumeroLocataire = giNumeroBail
          and ttRub.iNoQuittance = giNumeroQuittance:
        if (ttRub.iFamille = 01 and ttRub.iSousFamille <> 04)
        or  ttRub.iFamille = 02
        or (ttRub.iFamille = 05 and (ttRub.iSousFamille = 01
                               or ttRub.iNorubrique = 750
                               or ttRub.iNorubrique = 751
                               or ttRub.iNorubrique = 760
                               or ttRub.iNorubrique = 761
                               or ttRub.iNorubrique = 770
                               or ttRub.iNorubrique = 771
                               or ttRub.iNorubrique = 777))
        then assign
            pdeMontantQuittance = pdeMontantQuittance + ttRub.dMontantQuittance
            pdeMontantTotal     = pdeMontantTotal     + ttRub.dMontantTotal
        .
    end.

end procedure.

procedure calLoyTax private:
    /*---------------------------------------------------------------------------
    Purpose : calcule du total loyer + Impots et Taxes (sauf APL et TVA), pas les charges
    Notes   : Ajout PL le 10/12/2008 : Sauf hono LOC => Fam 08 & 09
    ---------------------------------------------------------------------------*/
    define output parameter pdeMontantQuittance as decimal  no-undo.
    define output parameter pdeMontantTotal as decimal  no-undo.

    for each ttRub
        where ttRub.iNumeroLocataire = giNumeroBail
          and ttRub.iNoQuittance = giNumeroQuittance:
        if (ttRub.iFamille = 01 and ttRub.iSousFamille <> 04)
        or (ttRub.iFamille = 05 and (ttRub.iSousFamille = 01
                               or ttRub.iNorubrique = 750
                               or ttRub.iNorubrique = 751
                               or ttRub.iNorubrique = 760
                               or ttRub.iNorubrique = 761
                               or ttRub.iNorubrique = 770
                               or ttRub.iNorubrique = 771
                               or ttRub.iNorubrique = 777))
        then assign
            pdeMontantQuittance = pdeMontantQuittance + ttRub.dMontantQuittance    /* montant quittancé */
            pdeMontantTotal     = pdeMontantTotal     + ttRub.dMontantTotal    /* montant total période */
        .
    end.

end procedure.

procedure creRub504 private:
    /*---------------------------------------------------------------------------
    Purpose : Procedure de création d'une rubrique 504 dans ttRub
    Notes   : Ajout PL le 10/12/2008 : Sauf hono LOC => Fam 08 & 09
    ---------------------------------------------------------------------------*/
    define variable vhProcRubqt as handle no-undo.

    vhProcRubqt = lancementPgm("crud/rubqt_CRUD.p", goCollectionHandlePgm).
    empty temp-table ttRubqt.
    run readRubqt in vhProcRubqt({&NoRub504}, {&NoLib504}, table ttRubqt by-reference).
    for first ttRubqt:
        create ttRub.
        assign
            ttRub.iNumeroLocataire = giNumeroBail
            ttRub.iNoQuittance = giNumeroQuittance
            ttRub.iFamille = ttRubqt.cdFam
            ttRub.iSousFamille = ttRubqt.cdSfa
            ttRub.iNorubrique = {&NoRub504}
            ttRub.iNoLibelleRubrique = {&NoLib504}
            ttRub.cLibelleRubrique = outilTraduction:getLibelle(ttRubqt.nome1)
            ttRub.cCodeGenre = ttRubqt.cdgen
            ttRub.cCodeSigne = ttRubqt.cdsig
            ttRub.cdDet = "0"
            ttRub.dQuantite = 0
            ttRub.dPrixunitaire = 0
            ttRub.dMontantTotal = gdeQuittanceTotal
            ttRub.iProrata = 0
            ttRub.iNumerateurProrata = 0
            ttRub.iDenominateurProrata = 0
            ttRub.dMontantQuittance = gdeQuittanceTaxe
            ttRub.daDebutApplication = gdaDebutQuittancement
            ttRub.daFinApplication = gdaFinQuittancement
            ttRub.iNoOrdreRubrique = 0
            /* Modification du montant de la quittance. Dans ttQtt.dMontantQuittance */
            gdeMontantRubrique = gdeQuittanceTaxe
            giNombreRubrique   = 1
        .
        run majttQtt.
    end.

end procedure.

procedure majttQtt private:
    /*---------------------------------------------------------------------------
    Purpose : Procedure qui met à jour le montant quittance pour la rubrique dans ttQtt
    Notes   :
    ---------------------------------------------------------------------------*/
    for first ttQtt
        where ttQtt.iNumeroLocataire = giNumeroBail
          and ttQtt.iNoQuittance = giNumeroQuittance:
        assign
            ttQtt.dMontantQuittance = ttQtt.dMontantQuittance + gdeMontantRubrique
            ttQtt.iNombreRubrique = ttQtt.iNombreRubrique + giNombreRubrique
            ttQtt.CdMaj = 1
        .
    end.
end procedure.
