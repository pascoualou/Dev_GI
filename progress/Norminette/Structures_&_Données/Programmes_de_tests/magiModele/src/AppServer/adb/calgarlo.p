/*-----------------------------------------------------------------------------
File        : calgarlo.p
Purpose     : Module de calcul de la rubrique de quittancement 101 des Fournisseurs
              de loyer associés à la garantie locative (tache 04263 du mandat Location)
              EurostudiomesCapitanFLV1.doc, Fiche 0103/0210
Author(s)   : SY - 2004/05/04, Kantena - 2017/12/21
Notes       : reprise de adb/srtc/quit/calgarlo.p
derniere revue: 2018/04/26 - phm: OK

01 19/08/2004  SY    TVA EUROSTUDIOMES : correction perte date fin application rub 101 si tacite rec.
02 04/03/2004  SY    Correction code retour si tout OK ("00")
03 12/12/2006  SY    0905/0335: plusieurs libellés autorisés pour les rubriques loyer si param RUBML           |
                     ATTENTION: nouveaux param entrée/sortie pour majlocrb.p
04 16/09/2008  SY    0608/0065 Gestion mandats 5 chiffres
05 24/09/2008  SY    0608/0065 détection bail FL par la nature du mandat maitre et non plus les bornes noflodeb
06 22/01/2009  PL    0110/0175 gestion prorata + récupération correcte du loyer garanti.
-----------------------------------------------------------------------------*/
{preprocesseur/referenceClient.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
&scoped-define rubrique101    101
using parametre.pclie.parametrageFournisseurLoyer.
using parametre.pclie.parametrageProlongationExpiration.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{bail/include/equit.i &nomtable=ttqtt}
{bail/include/tmprub.i}
define input  parameter piNumeroBail               as int64     no-undo.
define input  parameter piNumeroQuittance          as integer   no-undo.
define input  parameter pdaDebutPeriode            as date      no-undo.
define input  parameter pdaFinPeriode              as date      no-undo.
define input  parameter pdaDebutQuittancement      as date      no-undo.
define input  parameter pdaFinQuittancement        as date      no-undo.
define input  parameter piCodePeriodeQuittancement as integer   no-undo.
define input  parameter poCollection as class collection no-undo.
define input-output parameter table for ttQtt.
define input-output parameter table for ttRub.
define output parameter pcCodeRetour               as character no-undo initial "00".

{bail/include/filtreLo.i}          // Include pour Filtrage locataire à prendre, procedure filtreLoc
{adb/include/garlofl.i}            // fonction montantAnnuelLoyer
define variable giNumeroCodeRubrique        as integer  no-undo.
define variable gdeMontantRubrique          as decimal  no-undo.
define variable gdeMontantCalcule           as decimal  no-undo.
define variable giNumeroRubrique            as integer  no-undo.
define variable gdeMontantQuittanceRubrique as decimal  no-undo.

run calgarloPrivate.

procedure calgarloPrivate private:
    /*---------------------------------------------------------------------------
    Purpose : Procedure qui met à jour ou crée la rubrique 101 selon la garantie calculée
    Notes   : (TOUTES LES QUITTANCES DOIVENT ETRE CHARGEES)
    ---------------------------------------------------------------------------*/
    define variable viNumeroMandat           as integer  no-undo.
    define variable viNumeroQuittanceEncours as integer  no-undo.
    define variable viNombreQuittanceEncours as integer  no-undo.
    define variable viNombreQuittance        as integer  no-undo.
    define variable viMoisQuittancement      as integer  no-undo.
    define variable viMoisMoisEchu           as integer  no-undo.
    define variable viMoisMoisModifiable     as integer  no-undo.
    define variable vlTaciteReconduction     as logical  no-undo.
    define variable vdaSortieLocataire       as date     no-undo.
    define variable vdaResiliationBail       as date     no-undo.
    define variable vdaFinBail               as date     no-undo.
    define variable vdaFinApplication        as date     no-undo.
    define variable vlPrendre                as logical  no-undo.
    define buffer equit for equit.

    /* Recherche si tache Garantie locative F.L */
    viNumeroMandat = truncate(piNumeroBail / 100000, 0).               // INT( substring( string(piNumeroBail, "9999999999"), 1 , 5))
    if not can-find(first tache no-lock
                    where tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
                      and tache.nocon = viNumeroMandat
                      and tache.tptac = {&TYPETACHE-garantieLoyerFL}) then return.

    /* Tests des dates de début de quittance et quittancement et des dates de fin de quittance et de quittancement */
    if (pdaDebutQuittancement < pdaDebutPeriode)
    or (pdaFinQuittancement > pdaFinPeriode)
    or (pdaFinPeriode < pdaDebutPeriode) then do:
        pcCodeRetour = "01".
        return.
    end.

    /* Recherche mois de quitt selon Locat ou FL */
    run iniMsQttMdt(viNumeroMandat, output viMoisQuittancement, output viMoisMoisEchu, output viMoisMoisModifiable).
    /* Recherche si TOUTES les quittances chargées */
    /* Parcours des quittances en cours du locataire, par Mois de traitement GI (use-index ix_equit03, msqtt) */
    {&_proparse_ prolint-nowarn(use-index)}
    for each equit no-lock
        where equit.NoLoc = piNumeroBail
        and ((equit.cdter = "00001" and equit.msqtt >= viMoisMoisModifiable)
          or (equit.cdter = "00002" and equit.msqtt >= viMoisMoisEchu))
        use-index ix_equit03:
        viNombreQuittanceEncours = viNombreQuittanceEncours + 1 .
        /* Recherche de la 1ère quittance >= Mois Quitt */
        if viNumeroQuittanceEncours = 0 and equit.MsQtt >= viMoisQuittancement then viNumeroQuittanceEncours = equit.noqtt.
    end.

    /* Parcours des quittances Chargées du locataire */
    for each ttQtt
        where ttQtt.NoLoc = piNumeroBail:
        viNombreQuittance = viNombreQuittance + 1.
    end.
    /* Recherche mois quitt de la quittance traitée */
    find first ttQtt
        where ttQtt.NoLoc = piNumeroBail
          and ttQtt.NoQtt = piNumeroQuittance no-error.
    if not available ttQtt then do:
        pcCodeRetour = "01".
        return.
    end.
    /* Recalcul du loyer seulement si on est sur la 1ère quittance >= Mois De Quit FL en cours
      (on ne touche pas aux quittances émises) ET TOUTES LES Quittances chargées: */
    if viNumeroQuittanceEncours <> 0 and not (ttQtt.noqtt = viNumeroQuittanceEncours and viNombreQuittance = viNombreQuittanceEncours ) then do:
        if (ttQtt.noqtt = viNumeroQuittanceEncours and viNombreQuittance <> viNombreQuittanceEncours)
        then mLogger:writeLog(9, substitute("piNumeroBail = &1: ** WARNING ** PAS DE CALCUL CAR TOUS LES Equit N'ONT PAS ETE CHARGES ", string(piNumeroBail, "9999999999"))).
        return.
    end.

    gdeMontantCalcule = round(montantAnnuelLoyer(piNumeroBail) / (12 / piCodePeriodeQuittancement), 2).
    /* Si aucun montant: ne pas toucher le loyer */
    if gdeMontantCalcule = 0 then return.

    /* Recherche Rub Loyer 101.xx si montant inchangé: rien à faire */
    if can-find(first ttRub
                where ttRub.noloc = piNumeroBail
                  and ttRub.noqtt = piNumeroQuittance
                  and ttRub.norub = 101
                  and ttRub.mttot = gdeMontantCalcule) then return.

    run filtreLoc(pdaDebutPeriode, piNumeroBail, output vlTaciteReconduction, output vdaFinBail,output vdaSortieLocataire, output vdaResiliationBail, output vlPrendre).
    /*--> Calcul de la date de fin d'application maximum */
    run dtFapMax(vlTaciteReconduction, vdaFinBail, vdaSortieLocataire, vdaResiliationBail, output vdaFinApplication).
    /* Calcul de la durée de la période de quittancement */
    assign
        giNumeroCodeRubrique = (if available ttRub then ttRub.nolib else 01)
        gdeMontantRubrique   = (gdeMontantCalcule * (pdaFinQuittancement - pdaDebutQuittancement + 1)) / (pdaFinPeriode - pdaDebutPeriode + 1)
    .
    run trtRubLoy(vdaFinApplication).
end procedure.

procedure trtRubLoy:
    /*---------------------------------------------------------------------------
    Purpose : Procedure qui met à jour ou crée la rubrique 101 selon la garantie calculée
    Notes   : (TOUTES LES QUITTANCES DOIVENT ETRE CHARGEES)
    ---------------------------------------------------------------------------*/
    define input parameter pdaFinApplication as date  no-undo.

    define variable vdaDebutRubrique       as date      no-undo.
    define variable vdaDebutApplicationOld as date      no-undo.
    define variable vdaFinApplicationOld   as date      no-undo.
    define variable vcRetour               as character no-undo.
    define variable vcParametre            as character no-undo.
    define buffer vbttRub for ttRub.
    define buffer rubqt   for rubqt.

    /* Calcul dates d'application */
    vdaDebutRubrique = ttQtt.dtdpr.
    /* Positionnement sur la Rubrique  101-xx */
    find first rubqt no-lock
        where rubqt.cdrub = {&rubrique101}
          and rubqt.cdlib = giNumeroCodeRubrique no-error.
    if not available rubqt then do:
        mError:createError({&error}, 104126, "{&rubrique101}").
        pcCodeRetour = "01".
        return.
    end.
    find first ttRub
        where ttRub.noloc = piNumeroBail
          and ttRub.noqtt = piNumeroQuittance
          and ttRub.norub = {&rubrique101}
          and ttRub.nolib = giNumeroCodeRubrique no-error.
    if not available ttRub then do:
        create ttRub.
        assign
            vdaDebutApplicationOld      = vdaDebutRubrique
            vdaFinApplicationOld        = ttQtt.dtfpr  /* date de fin quittance corrigée */
            giNumeroRubrique            = 1
            gdeMontantQuittanceRubrique = gdeMontantRubrique
            ttRub.NoLoc = piNumeroBail
            ttRub.NoQtt = piNumeroQuittance
            ttRub.NoRub = {&rubrique101}
            ttRub.NoLib = giNumeroCodeRubrique
            ttRub.LbRub = outilTraduction:getLibelle(rubqt.nome1)
            ttRub.CdFam = rubqt.cdfam
            ttRub.CdSfa = rubqt.cdsfa
            ttRub.CdGen = rubqt.CdGen
            ttRub.CdSig = rubqt.CdSig
            ttRub.CdDet = "0"
            ttRub.VlQte = 0
            ttRub.VlPun = 0
            ttRub.MtTot = gdeMontantCalcule
            ttRub.CdPro = ttQtt.cdquo   /* cdpro */
            ttRub.VlNum = ttQtt.Nbnum   /* nbnum */
            ttRub.VlDen = ttQtt.Nbden   /* nbden */
            ttRub.VlMtq = gdeMontantRubrique
            ttRub.DtDap = vdaDebutRubrique
            ttRub.DtFap = pdaFinApplication
            ttRub.NoLig = 0
        .
    end.
    else assign
        vdaDebutApplicationOld      = ttRub.DtDap
        vdaFinApplicationOld        = ttRub.DtFap
        giNumeroRubrique            = 0
        gdeMontantQuittanceRubrique = gdeMontantRubrique - ttRub.mttot
        /* Modification rubrique Loyer */
        ttRub.MtTot = gdeMontantCalcule
        ttRub.VlMtq = gdeMontantRubrique
        ttRub.DtFap = pdaFinApplication
    .
    /* Modification du montant de la quittance et nb rub dans ttQtt */
    run majttQtt.
    /* Verification existence de la rubrique avec un autre libellé dans les quittances futures et forçage avec libellé giNumeroCodeRubrique */
    for each vbttRub
        where vbttRub.noloc = piNumeroBail
          and vbttRub.noqtt > piNumeroQuittance
          and vbttRub.norub = {&rubrique101}
          and vbttRub.nolib <> giNumeroCodeRubrique:
        /* Forcage dates d'application et libelle */
        assign
            vbttRub.nolib = giNumeroCodeRubrique
            vbttRub.dtdap = ttRub.dtdap
            vbttRub.dtfap = ttRub.dtfap
        .
    end.
    /* Lancement du module de répercussion sur les quittances futures */
    run bail/quittancement/majlocrb.p(
        piNumeroBail,
        piNumeroQuittance,
        {&rubrique101},
        giNumeroCodeRubrique,
        vdaDebutApplicationOld,
        vdaFinApplicationOld,
        input-output vcParametre,
        input-output table ttQtt by-reference,
        input-output table ttRub by-reference,
        output vcRetour
    ).
    mLogger:writeLog(9, substitute("piNumeroBail = &1 No Qtt = &2 msqtt = &3 - CdRubLoy = &4 - NoLibLoy = &5 - gdeMontantCalcule = &6",
        string(piNumeroBail, "9999999999"),
        piNumeroQuittance,
        if available ttQtt then string(ttQtt.msqtt) else "",
        {&rubrique101},
        string(giNumeroCodeRubrique, "99"),
        gdeMontantCalcule)).
end procedure.

procedure iniMsQttMdt:
    /*---------------------------------------------------------------------------
    Purpose : Procedure d'init du mois de quittancement selon mandat (Floyer ou non)
    Notes   : todo   c'est la même dans calbaipr.p
    ---------------------------------------------------------------------------*/
    define input  parameter piNumeroMandat   as int64    no-undo.
    define output parameter piMoisQuittance  as integer  no-undo.
    define output parameter piMoisModifiable as integer  no-undo.
    define output parameter piMoisEchu       as integer  no-undo.

    define variable voFournisseurLoyer as class parametrageFournisseurLoyer no-undo.

    /* Prochain Mois de Quittancement du mandat */
    assign
        voFournisseurLoyer = new parametrageFournisseurLoyer()
        piMoisQuittance    = poCollection:getInteger("GlMoiQtt")
        piMoisModifiable   = poCollection:getInteger("GlMoiMdf")
        piMoisEchu         = poCollection:getInteger("GlMoiMec")
    .
    if voFournisseurLoyer:isGesFournisseurLoyer()
    and can-find(first ctrat no-lock
        where ctrat.tpcon  = {&TYPECONTRAT-mandat2Gerance}
          and ctrat.nocon  = piNumeroMandat
          and (ctrat.ntcon = {&NATURECONTRAT-mandatLocation}
            or ctrat.ntcon = {&NATURECONTRAT-mandatLocationIndivision}))
    then assign
        piMoisQuittance  = poCollection:getInteger("GlMflQtt")
        piMoisEchu       = poCollection:getInteger("GlMoiMec")
        piMoisModifiable = piMoisEchu
    .
    delete object voFournisseurLoyer.
end procedure.

procedure majttQtt:
    /*---------------------------------------------------------------------------
    Purpose : Procedure qui met à jour le montant quittance pour la rubrique dans ttQtt
    Notes   :
    ---------------------------------------------------------------------------*/
    find first ttQtt
        where ttQtt.NoLoc = piNumeroBail
          and ttQtt.NoQtt = piNumeroQuittance no-error.
    if available ttQtt then assign
        ttQtt.MtQtt = ttQtt.MtQtt + gdeMontantQuittanceRubrique
        ttQtt.NbRub = ttQtt.NbRub + giNumeroRubrique
        ttQtt.CdMaj = 1
    .
end procedure.
