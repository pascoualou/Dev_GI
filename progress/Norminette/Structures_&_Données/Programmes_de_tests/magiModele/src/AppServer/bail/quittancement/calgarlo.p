/*-----------------------------------------------------------------------------
File        : calgarlo.p
Purpose     : Module de calcul de la rubrique de quittancement 101 des Fournisseurs
              de loyer associés à la garantie locative (tache 04263 du mandat Location)
              EurostudiomesCapitanFLV1.doc, Fiche 0103/0210
Author(s)   : SY - 2004/05/04, Kantena - 2017/12/21
Notes       : reprise de adb/srtc/quit/calgarlo.p
derniere revue: 2018/08/13 - phm: OK

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
{oerealm/include/instanciateTokenOnModel.i}  // Doit être positionnée juste après using

{bail/include/tbtmpqtt.i}
{bail/include/tbtmprub.i}

{outils/include/lancementProgramme.i}        // fonctions lancementPgm, suppressionPgmPersistent

define variable goCollectionHandlePgm as class collection no-undo.
define variable ghProc                      as handle    no-undo.
define variable giNumeroBail                as int64     no-undo.
define variable giNumeroQuittance           as integer   no-undo.
define variable gdaDebutPeriode             as date      no-undo.
define variable gdaFinPeriode               as date      no-undo.
define variable gdaDebutQuittancement       as date      no-undo.
define variable gdaFinQuittancement         as date      no-undo.
define variable giCodePeriodeQuittancement  as integer   no-undo.
define variable giMoisQuittancement         as integer   no-undo.
define variable giMoisEchu                  as integer   no-undo.
define variable giMoisModifiable            as integer   no-undo.
define variable giNumeroCodeRubrique        as integer   no-undo.
define variable gdeMontantRubrique          as decimal   no-undo.
define variable gdeMontantCalcule           as decimal   no-undo.
define variable giNumeroRubrique            as integer   no-undo.
define variable gdeMontantQuittanceRubrique as decimal   no-undo.

{bail/include/filtreLo.i}          // Include pour Filtrage locataire à prendre, procedure filtreLoc
{adb/include/garlofl.i}            // fonction montantAnnuelLoyer

procedure lancementCalgarlo:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   : service externe
    ------------------------------------------------------------------------*/
    define input parameter poCollectionContrat   as class collection no-undo.
    define input parameter poCollectionQuittance as class collection no-undo.
    define input-output parameter table for ttQtt.
    define input-output parameter table for ttRub.

    assign
        giNumeroBail               = poCollectionContrat:getInt64("iNumeroContrat")
        giMoisModifiable           = poCollectionContrat:getInteger("iMoisModifiable")
        giMoisEchu                 = poCollectionContrat:getInteger("iMoisEchu")
        giMoisQuittancement        = poCollectionContrat:getInteger("iMoisQuittancement")
        giNumeroQuittance          = poCollectionQuittance:getInteger("iNumeroQuittance")
        gdaDebutPeriode            = poCollectionQuittance:getDate("daDebutPeriode")
        gdaFinPeriode              = poCollectionQuittance:getDate("daFinPeriode")
        gdaDebutQuittancement      = poCollectionQuittance:getDate("daDebutQuittancement")
        gdaFinQuittancement        = poCollectionQuittance:getDate("daFinQuittancement")
        giCodePeriodeQuittancement = poCollectionQuittance:getInteger("iCodePeriodeQuittancement")
        goCollectionHandlePgm      = new collection()
    .

message "gga lancementCalgarlo " giNumeroBail "/" giNumeroQuittance "/" gdaDebutPeriode "/" gdaFinPeriode "/" gdaDebutQuittancement "/" gdaFinQuittancement "/"
                           giCodePeriodeQuittancement "/" giMoisModifiable "/" giMoisEchu "/" giMoisQuittancement.

    run calgarloPrivate.
    suppressionPgmPersistent(goCollectionHandlePgm).

end procedure.

procedure calgarloPrivate private:
    /*---------------------------------------------------------------------------
    Purpose : Procedure qui met à jour ou crée la rubrique 101 selon la garantie calculée
    Notes   : (TOUTES LES QUITTANCES DOIVENT ETRE CHARGEES)
    ---------------------------------------------------------------------------*/
    define variable viNumeroMandat           as integer  no-undo.
    define variable viNumeroQuittanceEncours as integer  no-undo.
    define variable viNombreQuittanceEncours as integer  no-undo.
    define variable viNombreQuittance        as integer  no-undo.
    define variable vlTaciteReconduction     as logical  no-undo.
    define variable vdaSortieLocataire       as date     no-undo.
    define variable vdaResiliationBail       as date     no-undo.
    define variable vdaFinBail               as date     no-undo.
    define variable vdaFinApplication        as date     no-undo.
    define variable vlPrendre                as logical  no-undo.
    define buffer equit for equit.

    /* Recherche si tache Garantie locative F.L */
    viNumeroMandat = truncate(giNumeroBail / 100000, 0).               // INT( substring( string(giNumeroBail, "9999999999"), 1 , 5))
    if not can-find(first tache no-lock
                    where tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
                      and tache.nocon = viNumeroMandat
                      and tache.tptac = {&TYPETACHE-garantieLoyerFL}) then return.
    
    /* Recherche si TOUTES les quittances chargées */
    /* Parcours des quittances en cours du locataire, par Mois de traitement GI (use-index ix_equit03, msqtt) */
    {&_proparse_ prolint-nowarn(use-index)}
    for each equit no-lock
        where equit.noLoc = giNumeroBail
          and ((equit.cdter = "00001" and equit.msqtt >= giMoisModifiable)
            or (equit.cdter = "00002" and equit.msqtt >= giMoisEchu))
        use-index ix_equit03:        // par noloc, msqtt, nomdt
        viNombreQuittanceEncours = viNombreQuittanceEncours + 1 .
        /* Recherche de la 1ère quittance >= Mois Quitt */
        if viNumeroQuittanceEncours = 0 and equit.MsQtt >= giMoisQuittancement then viNumeroQuittanceEncours = equit.noqtt.
    end.

    /* Parcours des quittances Chargées du locataire */
    for each ttQtt
        where ttQtt.iNumeroLocataire = giNumeroBail:
        viNombreQuittance = viNombreQuittance + 1.
    end.
    /* Recherche mois quitt de la quittance traitée */
    find first ttQtt
        where ttQtt.iNumeroLocataire = giNumeroBail
          and ttQtt.iNoQuittance = giNumeroQuittance no-error.
    if not available ttQtt then do:
        mError:createError({&error}, 1000852, string(giNumeroQuittance)).   //problème génération quittance &1, erreur sur table quittance
        return.
    end.
    /* Recalcul du loyer seulement si on est sur la 1ère quittance >= Mois De Quit FL en cours
      (on ne touche pas aux quittances émises) ET TOUTES LES Quittances chargées: */
    if viNumeroQuittanceEncours <> 0 and not (ttQtt.iNoQuittance = viNumeroQuittanceEncours and viNombreQuittance = viNombreQuittanceEncours ) then do:
        if (ttQtt.iNoQuittance = viNumeroQuittanceEncours and viNombreQuittance <> viNombreQuittanceEncours)
        then mLogger:writeLog(9, substitute("giNumeroBail = &1: ** WARNING ** PAS DE CALCUL CAR TOUS LES Equit N'ONT PAS ETE CHARGES ", string(giNumeroBail, "9999999999"))).
        return.
    end.

    gdeMontantCalcule = round(montantAnnuelLoyer(giNumeroBail) / (12 / giCodePeriodeQuittancement), 2).
    /* Si aucun montant: ne pas toucher le loyer */
    if gdeMontantCalcule = 0 then return.

    /* Recherche Rub Loyer 101.xx si montant inchangé: rien à faire */
    if can-find(first ttRub
                where ttRub.iNumeroLocataire = giNumeroBail
                  and ttRub.iNoQuittance = giNumeroQuittance
                  and ttRub.iNorubrique = 101
                  and ttRub.dMontantTotal = gdeMontantCalcule) then return.

    run filtreLoc(gdaDebutPeriode, giNumeroBail, output vlTaciteReconduction, output vdaFinBail,output vdaSortieLocataire, output vdaResiliationBail, output vlPrendre).
    /*--> Calcul de la date de fin d'application maximum */
    run dtFapMax(vlTaciteReconduction, vdaFinBail, vdaSortieLocataire, vdaResiliationBail, output vdaFinApplication).
    /* Calcul de la durée de la période de quittancement */
    assign
        giNumeroCodeRubrique = (if available ttRub then ttRub.iNoLibelleRubrique else 01)
        gdeMontantRubrique   = (gdeMontantCalcule * (gdaFinQuittancement - gdaDebutQuittancement + 1)) / (gdaFinPeriode - gdaDebutPeriode + 1)
    .
    run trtRubLoy(vdaFinApplication).
end procedure.

procedure trtRubLoy private:
    /*---------------------------------------------------------------------------
    Purpose : Procedure qui met à jour ou crée la rubrique 101 selon la garantie calculée
    Notes   : (TOUTES LES QUITTANCES DOIVENT ETRE CHARGEES)
    ---------------------------------------------------------------------------*/
    define input parameter pdaFinApplication as date  no-undo.

    define variable vdaDebutRubrique       as date   no-undo.
    define variable vdaDebutApplicationOld as date   no-undo.
    define variable vdaFinApplicationOld   as date   no-undo.
    define buffer vbttRub for ttRub.
    define buffer rubqt   for rubqt.

    /* Calcul dates d'application */
    vdaDebutRubrique = ttQtt.daDebutPeriode.
    /* Positionnement sur la Rubrique  101-xx */
    find first rubqt no-lock
        where rubqt.cdrub = {&rubrique101}
          and rubqt.cdlib = giNumeroCodeRubrique no-error.
    if not available rubqt then do:
        mError:createError({&error}, 104126, "{&rubrique101}").
        return.
    end.
    find first ttRub
        where ttRub.iNumeroLocataire = giNumeroBail
          and ttRub.iNoQuittance = giNumeroQuittance
          and ttRub.iNorubrique = {&rubrique101}
          and ttRub.iNoLibelleRubrique = giNumeroCodeRubrique no-error.
    if not available ttRub then do:
        create ttRub.
        assign
            vdaDebutApplicationOld      = vdaDebutRubrique
            vdaFinApplicationOld        = ttQtt.daFinPeriode  /* date de fin quittance corrigée */
            giNumeroRubrique            = 1
            gdeMontantQuittanceRubrique = gdeMontantRubrique
            ttRub.iNumeroLocataire = giNumeroBail
            ttRub.iNoQuittance = giNumeroQuittance
            ttRub.iNorubrique = {&rubrique101}
            ttRub.iNoLibelleRubrique = giNumeroCodeRubrique
            ttRub.cLibelleRubrique = outilTraduction:getLibelle(rubqt.nome1)
            ttRub.iFamille = rubqt.cdfam
            ttRub.iSousFamille = rubqt.cdsfa
            ttRub.cCodeGenre = rubqt.CdGen
            ttRub.cCodeSigne = rubqt.CdSig
            ttRub.CdDet = "0"
            ttRub.dQuantite = 0
            ttRub.dPrixunitaire = 0
            ttRub.dMontantTotal = gdeMontantCalcule
            ttRub.iProrata = ttQtt.iProrata   /* cdpro */
            ttRub.iNumerateurProrata = ttQtt.iNumerateurProrata   /* nbnum */
            ttRub.iDenominateurProrata = ttQtt.iDenominateurProrata   /* nbden */
            ttRub.dMontantQuittance = gdeMontantRubrique
            ttRub.daDebutApplication = vdaDebutRubrique
            ttRub.daFinApplication = pdaFinApplication
            ttRub.iNoOrdreRubrique = 0
        .
    end.
    else assign
        vdaDebutApplicationOld      = ttRub.daDebutApplication
        vdaFinApplicationOld        = ttRub.daFinApplication
        giNumeroRubrique            = 0
        gdeMontantQuittanceRubrique = gdeMontantRubrique - ttRub.dMontantTotal
        /* Modification rubrique Loyer */
        ttRub.dMontantTotal = gdeMontantCalcule
        ttRub.dMontantQuittance = gdeMontantRubrique
        ttRub.daFinApplication = pdaFinApplication
    .
    /* Modification du montant de la quittance et nb rub dans ttQtt */
    run majttQtt.
    /* Verification existence de la rubrique avec un autre libellé dans les quittances futures et forçage avec libellé giNumeroCodeRubrique */
    for each vbttRub
        where vbttRub.iNumeroLocataire = giNumeroBail
          and vbttRub.iNoQuittance > giNumeroQuittance
          and vbttRub.iNorubrique = {&rubrique101}
          and vbttRub.iNoLibelleRubrique <> giNumeroCodeRubrique:
        /* Forcage dates d'application et libelle */
        assign
            vbttRub.iNoLibelleRubrique = giNumeroCodeRubrique
            vbttRub.daDebutApplication = ttRub.daDebutApplication
            vbttRub.daFinApplication = ttRub.daFinApplication
        .
    end.
    /* Lancement du module de répercussion sur les quittances futures */
    ghProc = lancementPgm("bail/quittancement/majlocrb.p", goCollectionHandlePgm).
    run trtMajlocrb in ghProc (giNumeroBail,
                                     giNumeroQuittance,
                                     {&rubrique101},
                                     giNumeroCodeRubrique,
                                     vdaDebutApplicationOld,
                                     vdaFinApplicationOld,
                                     "",
                                     input-output table ttQtt by-reference,
                                     input-output table ttRub by-reference).
    if mError:erreur() then return.                                                                  

    mLogger:writeLog(9, substitute("giNumeroBail = &1 No Qtt = &2 msqtt = &3 - CdRubLoy = &4 - NoLibLoy = &5 - gdeMontantCalcule = &6",
        string(giNumeroBail, "9999999999"),
        giNumeroQuittance,
        if available ttQtt then string(ttQtt.iMoisTraitementQuitt) else "",
        {&rubrique101},
        string(giNumeroCodeRubrique, "99"),
        gdeMontantCalcule)).
end procedure.

procedure majttQtt private:
    /*---------------------------------------------------------------------------
    Purpose : Procedure qui met à jour le montant quittance pour la rubrique dans ttQtt
    Notes   :
    ---------------------------------------------------------------------------*/
    find first ttQtt
        where ttQtt.iNumeroLocataire = giNumeroBail
          and ttQtt.iNoQuittance = giNumeroQuittance no-error.
    if available ttQtt then assign
        ttQtt.dMontantQuittance = ttQtt.dMontantQuittance + gdeMontantQuittanceRubrique
        ttQtt.iNombreRubrique = ttQtt.iNombreRubrique + giNumeroRubrique
        ttQtt.CdMaj = 1
    .
end procedure.
