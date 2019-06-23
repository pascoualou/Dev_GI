/*------------------------------------------------------------------------
File        : appelDeFond.p
Purpose     :
Author(s)   : kantena - 2016/11/14
Notes       :
Tables      : BASE sadb :
----------------------------------------------------------------------*/
{preprocesseur/nature2honoraire.i}
{preprocesseur/typeAppel2fonds.i}
{preprocesseur/typeAppel.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2intervention.i}
{preprocesseur/statut2intervention.i}
{preprocesseur/listeRubQuit2TVA.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{application/include/error.i}
{application/include/combo.i}
{travaux/include/dossierTravaux.i}
{travaux/include/appelDefond.i}
{travaux/include/intervention.i}
{compta/include/soldeCompte.i}
{compta/include/tbcptaprov.i}

&SCOPED-DEFINE NOFOURNISSEUR-VIDE "00000"

define variable giNumeroItem as integer no-undo. /* utilise dans fonction createttCombo */

function createttCombo returns logical (pcNom as character, pcCode as character, pcLibelle as character):
    /*------------------------------------------------------------------------------
    Purpose: todo fonction deja existante voir si possibilite de la rendre commune
    Notes  :
    ------------------------------------------------------------------------------*/
    create ttCombo.
    assign
        giNumeroItem      = giNumeroItem + 1
        ttcombo.iSeqId    = giNumeroItem
        ttCombo.cNomCombo = pcNom
        ttCombo.cCode     = pcCode
        ttCombo.cLibelle  = pcLibelle
    .
end function.

function LbApp return character private(pcNoFouUse as character, pcLbIntUse as character, pcTypeContrat as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Note   :  extrait de gesdossi.p function LbApp
    -------------------------------------------------------------------------------*/
    define variable vcLbRetUse as character no-undo.
    define variable viNbLigUSe as integer   no-undo.
    define variable vcNmFouUse as character no-undo.
    define variable viJ        as integer   no-undo.
    define variable viCpUseInc as integer   no-undo.

    vcLbRetUse = fill(separ[1], 8).    // Initialiser 9 entry dans le retour
    /*--> Libelle fournisseur */
    if pcNoFouUse <> {&NOFOURNISSEUR-VIDE}
    then do:
        assign
            vcNmFouUse = outilFormatage:GetNomFour("F", integer(pcNoFouUse), pcTypeContrat)
            viCpUseInc = truncate(length(vcNmFouUse, 'character') / 32, 0) + 1
        .
        do viJ = 1 to viCpUseInc while viNbLigUSe < 9:
            assign
                viNbLigUSe                              = viNbLigUSe + 1
                entry(viNbLigUSe, vcLbRetUse, separ[1]) = substring(vcNmFouUse, 1 + (viJ - 1) * 32, 32, 'character')
            .
        end.
    end.
    /*--> Libelle intervention */
    viCpUseInc = truncate(length(pcLbIntUse, 'character') / 32, 0) + 1.
    do viJ = 1 to viCpUseInc while viNbLigUSe < 9:
        assign
            viNbLigUSe                              = viNbLigUSe + 1
            entry(viNbLigUSe, vcLbRetUse, separ[1]) = substring(pcLbIntUse, 1 + (viJ - 1) * 32, 32, 'character')
        .
    end.
    return vcLbRetUse.

end function.

procedure getAppelDeFond:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : Service externe (beAppeldeFond.cls repartitionAV.p)
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as collection no-undo.
    define output parameter table for ttEnteteAppelDeFond.
    define output parameter table for ttAppelDeFond.
    define output parameter table for ttAppelDeFondRepCle.
    define output parameter table for ttAppelDeFondRepMat.
    define output parameter table for ttDossierAppelDeFond.

    define variable vcTypeMandat           as character no-undo.
    define variable viNumeroMandat         as integer   no-undo.
    define variable viNumeroDossierTravaux as integer   no-undo.
    define variable vdeMontantTotalAppel   as decimal   no-undo.
    define variable vcTypeAppel            as character no-undo.
    define variable vlModeTraitementManuel as logical   no-undo.
    define variable vlModeTraitementAuto   as logical   no-undo.
    define variable vlExisteOSouDevis      as logical   no-undo.
    define variable vlExisteOrdreService   as logical   no-undo.

    define buffer doset for doset.
    define buffer dosdt for dosdt.
    define buffer dosap for dosap.
    define buffer dtOrd for dtOrd.
    define buffer ordse for ordse.
    define buffer svdev for svdev.
    define buffer devis for devis.
    define buffer itaxe for itaxe.

    empty temp-table ttEnteteAppelDeFond.
    empty temp-table ttAppelDeFond.
    empty temp-table ttAppelDeFondRepCle.
    empty temp-table ttAppelDeFondRepMat.
    empty temp-table ttDossierAppelDeFond.
    assign
        vcTypeMandat           = poCollection:getCharacter("cTypeMandat")
        viNumeroMandat         = poCollection:getInteger("iNumeroMandat")
        viNumeroDossierTravaux = poCollection:getInteger("iNumeroDossierTravaux")
    .

message "gga debut getAppelDeFond " vcTypeMandat "//" viNumeroMandat "//" viNumeroDossierTravaux.

    /*--> Chargement entete appel de fond */
    for each doset no-lock
        where doset.TpCon = vcTypeMandat
          and doset.NoCon = viNumeroMandat
          and doset.NoDos = viNumeroDossierTravaux:
        create ttEnteteAppelDeFond.
        assign
            ttEnteteAppelDeFond.CRUD                      = 'R'
            ttEnteteAppelDeFond.iNumeroOrdre              = doset.NoOrd
            ttEnteteAppelDeFond.iNumeroIdentifiant        = doset.noidt
            ttEnteteAppelDeFond.cCodeTypeAppel            = doset.TpApp
            ttEnteteAppelDeFond.cCodeCollectifFinancement = doset.sscoll-cle /* 0306/0215 - coll financement fd rlt/res */
            ttEnteteAppelDeFond.cCodeTypeAppelSur         = doset.TpSur
            ttEnteteAppelDeFond.iNumeroIntervention       = doset.NoInt
            ttEnteteAppelDeFond.iNombreAppel              = doset.NbApp
            ttEnteteAppelDeFond.dMontantAppel             = doset.MtApp
            ttEnteteAppelDeFond.iCodeTva                  = doset.CdTva
            ttEnteteAppelDeFond.dMontantTva               = doset.MtTva
            ttEnteteAppelDeFond.lbcom                     = doset.lbcom
            ttEnteteAppelDeFond.cRepriseAppel             = if doset.lbcom = "E" then outilTraduction:getLibelle(111808) /*"Uniquement"*/
                                                            else if doset.lbcom = "P" then outilTraduction:getLibelle(111809) /*"Partiellement"*/
                                                            else "Non"    // todo   traduction ?!
            ttEnteteAppelDeFond.cLibelleTypeAppel         = outilTraduction:getLibelleParam("TPDOS", DosEt.TpApp)
            ttEnteteAppelDeFond.cLibelleAppelSur          = outilTraduction:getLibelleParam("TPAHB", DosEt.TpSur)
            vcTypeAppel                                   = (if vcTypeAppel = ? or vcTypeAppel = "" then doset.tpapp else "")
            ttEnteteAppelDeFond.dtTimestamp               = datetime(DosEt.dtmsy, DosEt.HeMsy)
            ttEnteteAppelDeFond.rRowid                    = rowid(doset)
            vlExisteOSouDevis                             = false
        .
        find first itaxe no-lock
            where itaxe.soc-cd = integer(mToken:cRefPrincipale)
              and itaxe.taxe-cd = DosEt.cdTva no-error.
        if available itaxe then ttEnteteAppelDeFond.dTauxTVA = itaxe.taux.

        if doset.tpApp = {&TYPEAPPEL2FONDS-travaux}
        or doset.tpApp = {&TYPEAPPEL2FONDS-architecte}
        or doset.tpApp = {&TYPEAPPEL2FONDS-dommageOuvrage}
        then do:
            /*--> On regarde en premier si il y a un OS */
            vlExisteOrdreService = false.
            for first dtord no-lock
                where dtord.noint = ttEnteteAppelDeFond.iNumeroIntervention
              , first ordse no-lock
                where ordse.noord = dtord.noord:
                assign
                    ttEnteteAppelDeFond.cCodeFournisseur     = string(ordse.nofou)
                    ttEnteteAppelDeFond.cLibelleFournisseur  = outilFormatage:getNomFour("F", ordse.nofou, vcTypeMandat)
                    ttEnteteAppelDeFond.cLibelleIntervention = dtord.Lbint
                    vlExisteOrdreService                     = true
                    vlExisteOSouDevis                        = true
                .
            end.
            /*--> Sinon on recupère la réponse votée */
            if not vlExisteOrdreService
            then for first svdev no-lock
                where svdev.noint = ttEnteteAppelDeFond.iNumeroIntervention
                  and svdev.fgvot = true
              , first devis no-lock
                where devis.nodev = svdev.nodev:
                assign
                    ttEnteteAppelDeFond.cCodeFournisseur     = string(devis.nofou)
                    ttEnteteAppelDeFond.cLibelleFournisseur  = outilFormatage:getNomFour("F", devis.nofou, vcTypeMandat)
                    ttEnteteAppelDeFond.cLibelleIntervention = svdev.lbint
                    vlExisteOSouDevis                        = true
                .
            end.
        end.
        /*--> Appel de type Provision / Architecte / Dom Ouvra / Honoraire */
        if doset.TpApp <> {&TYPEAPPEL2FONDS-travaux} and vlExisteOSouDevis = false
        then assign
            ttEnteteAppelDeFond.cCodeFournisseur     = string(doset.nofou)
            ttEnteteAppelDeFond.cLibelleIntervention = doset.lbint[1]
            ttEnteteAppelDeFond.cLibelleFournisseur  = if doset.nofou = 0 and (doset.tpapp = {&TYPEAPPEL2FONDS-architecte} or doset.tpapp = {&TYPEAPPEL2FONDS-honoraire})    // par le cabinet
                                                       then outilTraduction:getLibelle(111560)
                                                       else outilFormatage:getNomFour("F", doset.nofou, vcTypeMandat)
        .
        /*--> Chargement de la table detail des appels */
        vdeMontantTotalAppel = 0.
        for each dosdt no-lock
            where dosdt.NoIdt = doset.NoIdt:
            /*--> Creation de l'entete de l'appel */
            if dosdt.cdapp = ? or dosdt.cdapp = ""
            then do:
                create ttAppelDeFond.
                assign
                    ttAppelDeFond.CRUD               = 'R'
                    ttAppelDeFond.iNumeroIdentifiant = dosdt.NoIdt
                    ttAppelDeFond.iNumeroAppel       = dosdt.NoApp
                    ttAppelDeFond.cLibelleAppel      = dosdt.LbApp[1]
                    ttAppelDeFond.dMontantAppel      = dosdt.MtApp
                    ttAppelDeFond.dtTimestamp        = datetime(dosdt.dtmsy, dosdt.Hemsy)
                    ttAppelDeFond.rRowid             = rowid(dosdt)
                    vdeMontantTotalAppel             = vdeMontantTotalAppel + dosdt.mtapp
                .
            end.
            /*--> Creation de la repartition de l'appel */
            else do:
                /*--> Repartition par cle */
                if doset.tpsur = "00001"       // TODO variable preproc ??????-??????
                then do:
                    create ttAppelDeFondRepCle.
                    assign
                        ttAppelDeFondRepCle.CRUD               = 'R'
                        ttAppelDeFondRepCle.iNumeroIdentifiant = dosdt.NoIdt
                        ttAppelDeFondRepCle.iNumeroAppel       = dosdt.NoApp
                        ttAppelDeFondRepCle.cCodeCle           = dosdt.CdApp
                        ttAppelDeFondRepCle.cLibelleAppel[1]   = dosdt.LbApp[1]
                        ttAppelDeFondRepCle.cLibelleAppel[2]   = dosdt.LbApp[2]
                        ttAppelDeFondRepCle.cLibelleAppel[3]   = dosdt.LbApp[3]
                        ttAppelDeFondRepCle.cLibelleAppel[4]   = dosdt.LbApp[4]
                        ttAppelDeFondRepCle.cLibelleAppel[5]   = dosdt.LbApp[5]
                        ttAppelDeFondRepCle.cLibelleAppel[6]   = dosdt.LbApp[6]
                        ttAppelDeFondRepCle.cLibelleAppel[7]   = dosdt.LbApp[7]
                        ttAppelDeFondRepCle.cLibelleAppel[8]   = dosdt.LbApp[8]
                        ttAppelDeFondRepCle.cLibelleAppel[9]   = dosdt.LbApp[9]
                        ttAppelDeFondRepCle.dMontantAppel      = dosdt.MtApp
                        ttAppelDeFondRepCle.dtTimestamp        = datetime(dosdt.dtmsy, dosdt.HeMsy)
                        ttAppelDeFondRepCle.rRowid             = rowid(dosdt)
                    .
                end.
                /*--> Repartion par copropriétaire */
                else do:
                    create ttAppelDeFondRepMat.
                    assign
                        ttAppelDeFondRepMat.CRUD               = 'R'
                        ttAppelDeFondRepMat.iNumeroIdentifiant = dosdt.NoIdt
                        ttAppelDeFondRepMat.iNumeroAppel       = dosdt.NoApp
                        ttAppelDeFondRepMat.iNumeroCopro       = integer(entry(1, dosdt.CdApp, separ[1]))
                        ttAppelDeFondRepMat.iNumeroLot         = integer(entry(2, dosdt.CdApp, separ[1]))
                        ttAppelDeFondRepMat.cLibelleAppel[1]   = dosdt.LbApp[1]
                        ttAppelDeFondRepMat.cLibelleAppel[2]   = dosdt.LbApp[2]
                        ttAppelDeFondRepMat.cLibelleAppel[3]   = dosdt.LbApp[3]
                        ttAppelDeFondRepMat.cLibelleAppel[4]   = dosdt.LbApp[4]
                        ttAppelDeFondRepMat.cLibelleAppel[5]   = dosdt.LbApp[5]
                        ttAppelDeFondRepMat.cLibelleAppel[6]   = dosdt.LbApp[6]
                        ttAppelDeFondRepMat.cLibelleAppel[7]   = dosdt.LbApp[7]
                        ttAppelDeFondRepMat.cLibelleAppel[8]   = dosdt.LbApp[8]
                        ttAppelDeFondRepMat.cLibelleAppel[9]   = dosdt.LbApp[9]
                        ttAppelDeFondRepMat.dMontantAppel      = dosdt.MtApp
                        ttAppelDeFondRepMat.dtTimestamp        = datetime(dosdt.dtmsy, dosdt.HeMsy)
                        ttAppelDeFondRepCle.rRowid             = rowid(dosdt)
                    .
                    // ttAppelDeFondRepMat.cNomCop    = FRMTIE1("00008",ttAppelDeFondRepMat.NoCop).
                end.
            end.
        end. /* FOR EACH dosdt */
        /*--> Calcul de l'ecart */
        ttEnteteAppelDeFond.dMontantEcart = round(ttEnteteAppelDeFond.dMontantAppel - vdeMontantTotalAppel, 2).
    end.

    /*--> Chargement du calendrier des appels */
    for each dosap no-lock
        where dosap.TpCon = vcTypeMandat
          and dosap.NoCon = viNumeroMandat
          and dosap.NoDos = viNumeroDossierTravaux:
        for each ttAppelDeFond
            where ttAppelDeFond.iNumeroAppel = dosap.NoApp:
            assign
                ttAppelDeFond.lFlagEmis       = dosap.fgemi
                ttAppelDeFond.daDateAppel     = dosap.dtapp
                ttAppelDeFond.dMontantTotal   = dosap.mttot
                ttAppelDeFond.cModeTraitement = dosap.modeTrait
                ttAppelDeFond.cCodeTraitement = if ttAppelDeFond.lFlagEmis = no
                                                then "N" /*Non traité*/
                                                else if ttAppelDeFond.cModeTraitement = "M" then "M" /*traité manuel*/
                                                else "O" /*traité auto*/
            .
        end.
        /*create ttDateAppelDeFond.
        assign
            ttDateAppelDeFond.CRUD               = 'R'
            ttDateAppelDeFond.iNumeroAppel       = dosap.NoApp
            ttDateAppelDeFond.iNumeroContrat     = dosap.nocon
            ttDateAppelDeFond.cTypeContrat       = dosap.tpcon
            ttDateAppelDeFond.iNumeroDossierTrav = dosap.NoDos
            ttDateAppelDeFond.cCodeTraitement    = if ttDateAppelDeFond.lFlagEmit = no
                                                   then "N"
                                                   else if ttDateAppelDeFond.cModeTrait = "M" then "M" else "O"
            ttDateAppelDeFond.dtTimestamp        = datetime(dosap.dtmsy, dosap.HeMsy)
        .*/
        /*****************************************
        /* chargement du détail des appels de fonds par type appel/clé/lot/copro */
        define variable daDateDeTransfert      as date      no-undo.
        define buffer trfpm for trfpm.
        define buffer apbco for apbco.
        for each apbco no-lock
            where apbco.tpbud = {&TYPEBUDGET-travaux}
              and apbco.nobud = integer(string(viNumeroMandat) + string(viNumeroDossierTravaux, "99999"))
              and apbco.tpapp = {&TYPEAPPEL-dossierTravaux}
              and apbco.noapp = dosap.noapp
              and apbco.nomdt = viNumeroMandat:
            /* recherche de la date d'emission */
            daDateDeTransfert = ?.
            find first trfpm no-lock
                where trfpm.nomdt = viNumeroMandat
                  and trfpm.TpTrf = {&TYPETRANSFERT-appel}
                  and Trfpm.TpApp = apbco.tpapp
                  and Trfpm.noexe = viNumeroDossierTravaux
                  and Trfpm.noapp = apbco.noapp no-error.
            if available trfpm then daDateDeTransfert = trfpm.Dttrf.
            // todo create ttAppelDeFondDetail
            create TbAppDet.
            buffer-copy apbco to TbAppDet.
            if daDateDeTransfert <> ? then TbAppDet.dtems = daDateDeTransfert.
            if vcTypeAppel <> "" and TbAppDet.typapptrx = "" then TbAppDet.typapptrx = vcTypeAppel.
        end.
        **************************************/
    end.
    /** 0508/0072 : Gestion de l'antériorité **/
    for each ttEnteteAppelDeFond where ttEnteteAppelDeFond.cRepriseAppel = "":
        assign
            vlModeTraitementManuel = false
            vlModeTraitementAuto   = false
        .
        /*for each ttAppelDeFond
            where ttAppelDeFond.iNumeroIdentifiant = ttEnteteAppelDeFond.iNumeroIdentifiant
          , first ttDateAppelDeFond
            where ttDateAppelDeFond.iNumeroAppel = ttAppelDeFond.iNumeroAppel:
            if ttDateAppelDeFond.cModeTrait = "M" then vlModeTraitementManuel = true. else vlModeTraitementAuto = true.
        end.*/
        for each ttAppelDeFond
            where ttAppelDeFond.iNumeroIdentifiant = ttEnteteAppelDeFond.iNumeroIdentifiant:
            if ttAppelDeFond.cModeTrait = "M"
            then vlModeTraitementManuel = true.
            else vlModeTraitementAuto = true.
        end.
        if vlModeTraitementManuel then ttEnteteAppelDeFond.cRepriseAppel = "P".
        if not vlModeTraitementManuel and vlModeTraitementAuto then ttEnteteAppelDeFond.cRepriseAppel = "N".
        // TODO : IL MANQUE UN CAS ?! if not vlModeTraitementManuel and not vlModeTraitementAuto

    end.
    run creationttDossierAppelDeFond (poCollection).
    run calculdossier.

end procedure.

procedure ValidDetailAppel:
    /*------------------------------------------------------------------------------
    Purpose: controle ecran detail appel de fond
    Notes  : Service externe (beAppelDeFond.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttError.
    define input-output parameter table for ttDossierTravaux.
    define input-output parameter table for ttEnteteAppelDeFond.
    define input-output parameter table for ttAppelDeFond.
    define input-output parameter table for ttAppelDeFondRepCle.
    define input-output parameter table for ttAppelDeFondRepMat.
    define input-output parameter table for ttInfoSaisieAppelDeFond.
    define input-output parameter table for ttRepartitionCle.
    define input-output parameter table for ttRepartitionCopro.
    define input-output parameter table for ttRepartitionPourcentage.
    define input-output parameter table for ttDossierAppelDeFond.

    define variable vlRetCtrl  as logical   no-undo.
    define variable vcCdSenUse as character no-undo.

message "gga ValidDetailAppel debut ".

    find first ttDossierTravaux no-error.
    if not available ttDossierTravaux
    then do:
        mError:createError({&error}, 4000011).    // Table ttDossierTravaux inexistante
        return.
    end.

    find first ttInfoSaisieAppelDeFond no-error.
    if not available ttInfoSaisieAppelDeFond
    then do:
        mError:createError({&error}, 4000021).    // Table ttInfoSaisieAppelDeFond inexistante
        return.
    end.

message "gga ValidDetailAppel parametres "
        " ttDossierTravaux.cCodeTypeMandat " ttDossierTravaux.cCodeTypeMandat
        " ttDossierTravaux.iNumeroMandat " ttDossierTravaux.iNumeroMandat
        " ttDossierTravaux.iNumeroDossierTravaux " ttDossierTravaux.iNumeroDossierTravaux
        " ttDossierTravauxi.NumeroImmeuble " ttDossierTravaux.iNumeroImmeuble.

    find first ttEnteteAppelDeFond
        where lookup(ttEnteteAppelDeFond.CRUD, 'C,U') > 0 no-error.
    if not available ttEnteteAppelDeFond
    then do:
        mError:createError({&error}, 4000010).    // Aucun enregistrement en maj
        return.
    end.
    if ttEnteteAppelDeFond.CRUD = "C" then vcCdSenUse = "NEWENT".
    if ttEnteteAppelDeFond.CRUD = "U" then vcCdSenUse = "MAJENT".

message "gga ValidDetailAppel type trt : " vcCdSenUse.

    run ValidDetailAppel-01(
        vcCdSenUse,
        buffer ttDossierTravaux,
        buffer ttInfoSaisieAppelDeFond,
        buffer ttEnteteAppelDeFond,
        output vlRetCtrl
    ).
    if vlRetCtrl then run validDetailAppel-02(vcCdSenUse, ttEnteteAppelDeFond.iNumeroIdentifiant, buffer ttDossierTravaux).

end procedure.

procedure validDetailAppel-01 private:
    /*------------------------------------------------------------------------------
    Purpose: correspond a fonction CtrlValEnt dans visdoapp.p
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcCdSenUse as character no-undo.
    define parameter buffer ttDossierTravaux        for ttDossierTravaux.
    define parameter buffer ttInfoSaisieAppelDeFond for ttInfoSaisieAppelDeFond.
    define parameter buffer ttEnteteAppelDeFond     for ttEnteteAppelDeFond.
    define output parameter plCtrlOk   as logical   no-undo.

message "gga ValidDetailAppel-01 debut ".

    define variable vdMtTotRep as decimal no-undo.
    define variable vdMtTempo  as decimal no-undo.
    define variable vdMtTempo2 as decimal no-undo.
    define variable viNoAppUse as integer no-undo.
    define variable vlFgModRep as logical no-undo.
    define variable vdMtRepCop as decimal no-undo.
    define variable vdMtRepCle as decimal no-undo.
    define variable vhProcTva  as handle  no-undo.
    define variable vdMtTotApp as decimal no-undo.
    define variable viCpUseInc as integer no-undo.
    define variable viSociete  as integer no-undo.

    define buffer vbttEnteteAppelDeFond for ttEnteteAppelDeFond.
    define buffer ifdparam for ifdparam.
    define buffer agest    for agest.
    define buffer ietab    for ietab.
    define buffer cecrsai  for cecrsai.
    define buffer dosap    for dosap.

    if ttEnteteAppelDeFond.cCodeTypeAppel = {&TYPEAPPEL2FONDS-travaux}
    and ttEnteteAppelDeFond.iNumeroIntervention = 0
    then do:
        mError:createError({&error}, 108125).    // Intervention obligatoire
        return.
    end.
    viSociete = mtoken:getSociete(ttDossierTravaux.cCodeTypeMandat).
    /*--> Impossible de faire des appels d'honoraire en comptabilisation par OD, La Comptabilité doit-être par ACHAT */
    if ttEnteteAppelDeFond.cCodeTypeAppel = {&TYPEAPPEL2FONDS-honoraire}
    and not can-find(first ifdparam no-lock
        where ifdparam.soc-dest = viSociete
          and ifdparam.fg-od <> true)
    then do:
        mError:createError({&error}, 4000012).
        return.
    end.

    /*--> Re-calcul du montant ttc à partir du ht pour les honoraires, sinon ecart lors de la comptabilisation */
    if ttEnteteAppelDeFond.cCodeTypeAppel = {&TYPEAPPEL2FONDS-honoraire}
    then do:
        /* gga 17/04/03 code executé seulement si modification montant appel */
        if pcCdSenUse = "NEWENT"
        or (pcCdSenUse = "MODIF"
            and can-find (first doset no-lock
                          where doset.tpcon = ttDossierTravaux.cCodeTypeMandat
                            and doset.NoCon = ttDossierTravaux.iNumeroMandat
                            and doset.NoDos = ttDossierTravaux.iNumeroDossierTravaux
                            and doset.noidt = ttEnteteAppelDeFond.iNumeroIdentifiant
                            and doset.MtApp <> ttEnteteAppelDeFond.dMontantAppel))
        then do:
            /* recalcul */
            run compta/outilsTVA.p persistent set vhProcTva.
            run getTokenInstance in vhProcTva(mToken:JSessionId).
            assign
                vdMtTempo  = ttEnteteAppelDeFond.dMontantAppel - ttEnteteAppelDeFond.dMontantTva
                vdMtTempo2 = vdMtTempo + dynamic-function("calculTVAdepuisHT" in vhProcTva, ttEnteteAppelDeFond.iCodeTva, vdMtTempo)
            .
            run destroy in vhProcTva.

message "gga ValidDetailAppel-01 apres recalcul tva " vdMtTempo2 ttEnteteAppelDeFond.dMontantAppel.

            if ttEnteteAppelDeFond.dMontantAppel <> truncate(vdMtTempo2, 2)
            then do:
                /* Modification de la zone de saisie et de l'écart */
                ttEnteteAppelDeFond.dMontantAppel = vdMtTempo2.
                /* recalcul de l'ecart */     /*gga todo voir si faire une fonction en se basant sur ON "LEAVE" OF TbTmpCle.MtCle IN BROWSE HwBrwCle DO: */
                for each ttRepartitionCle
                    where ttRepartitionCle.lAff:
                    vdMtTotApp = vdMtTotApp + ttRepartitionCle.dMontantCle.
                end.
                ttEnteteAppelDeFond.dMontantEcart = ttEnteteAppelDeFond.dMontantAppel - vdMtTotApp.
                /* Modification de la répartition */
                for first ttRepartitionCle:
                    ttRepartitionCle.dMontantCle = ttRepartitionCle.dMontantCle + ttEnteteAppelDeFond.dMontantEcart.
message "gga ValidDetailAppel-01 apres modif repartition " ttRepartitionCle.dMontantCle.
                end.
                /* message d'avertissement, Le montant TTC a été recalculé à partir du montant HT */
                mError:createError({&information}, 4000013). /*gga todo revoir pour completer ce message (preciser ligne modifiee) */
            end.
        end.
    end. /* if ttEnteteAppelDeFond.cCodeTypeAppel = {&TYPEAPPEL2FONDS-honoraire} */

    /*--> Impossible de créer des doublons d'appel honoraire */
    if ttEnteteAppelDeFond.cCodeTypeAppel = {&TYPEAPPEL2FONDS-honoraire}
    and pcCdSenUse = "NEWENT"
    then for first vbttEnteteAppelDeFond
        where vbttEnteteAppelDeFond.cCodeTypeAppel    = {&TYPEAPPEL2FONDS-honoraire}
          and vbttEnteteAppelDeFond.cCodeTypeAppelSur = ttEnteteAppelDeFond.cCodeTypeAppelSur
          and vbttEnteteAppelDeFond.iNumeroOrdre <> ttEnteteAppelDeFond.iNumeroOrdre:
        mError:createError({&error}, 4000014, ttEnteteAppelDeFond.cLibelleAppelSur).    // Vous ne pouvez pas créer deux appels de fonds honoraires (&1)
        return.
    end.

    if ttEnteteAppelDeFond.cCodeTypeAppel <> {&TYPEAPPEL2FONDS-travaux}
    and (ttEnteteAppelDeFond.cLibelleIntervention = ? or ttEnteteAppelDeFond.cLibelleIntervention = "")
    then do:
        mError:createError({&error}, 108126).
        return.
    end.

    if ttEnteteAppelDeFond.cCodeFournisseur = {&NOFOURNISSEUR-VIDE}
    and ttEnteteAppelDeFond.cCodeTypeAppel = {&TYPEAPPEL2FONDS-dommageOuvrage}
    then do:
        mError:createError({&error}, 108127).    // Fournisseur obligatoire
        return.
    end.

    /*--> Montant obligatoirement négatif pour emprunt - subvention - indemnité */
    if (ttEnteteAppelDeFond.cCodeTypeAppel = {&TYPEAPPEL2FONDS-emprunt}
    or ttEnteteAppelDeFond.cCodeTypeAppel = {&TYPEAPPEL2FONDS-subvention}
    or ttEnteteAppelDeFond.cCodeTypeAppel = {&TYPEAPPEL2FONDS-indemniteAssurance})
    and ttEnteteAppelDeFond.dMontantAppel > 0
    then do:
        mError:createError({&error}, 4000015).   // Le montant à appeler doit être négatif ou nul
        return.
    end.

    /*--> 0306/0215 - Financement Fd rlt/res -> à déduire, obligatoirement négatif */
    if ttEnteteAppelDeFond.cCodeTypeAppel = {&TYPEAPPEL2FONDS-financementRoulement}
    or ttEnteteAppelDeFond.cCodeTypeAppel = {&TYPEAPPEL2FONDS-financementReserve}
    or ttEnteteAppelDeFond.cCodeTypeAppel = {&TYPEAPPEL2FONDS-fondtravauxAlur}
    then do:
        if ttEnteteAppelDeFond.dMontantAppel > 0
        then do:
            mError:createError({&error}, 4000016).    // Le montant du financement à déduire doit être négatif
            return.
        end.
        /**Ajout OF le 26/08/16**/
        if ttEnteteAppelDeFond.cCodeTypeAppel = {&TYPEAPPEL2FONDS-fondtravauxAlur}
        and available ttInfoSaisieAppelDeFond
        and ttInfoSaisieAppelDeFond.lSaisieFondAlur = yes
        and absolute(ttEnteteAppelDeFond.dMontantAppel) > absolute(ttEnteteAppelDeFond.dMontantFondTravauxAlur)
        then do:
            /* recherche si retour de la vue avec reponse a non pour la question 'Le montant du financement est supérieur au solde bancaire du compte travaux ALUR'.
            dans ce cas passe ce controle */
            find first ttError
                where ttError.iType = {&question}
                  and lookup(entry(1, ttError.cComplement, ":"), "4000017") > 0
                  and ttError.lYesNo = yes no-error.
/*gga todo a voir avec nicolas pour voir le retour de la question
            and num-entries(ttError.cComplement, ":") > 1
            and entry(2, ttError.cComplement, ":") = "oui":
gga*/
            if not available ttError
            then do:
                mError:createError({&question}, 4000017).   // Le montant du financement est supérieur au solde bancaire du compte travaux ALUR. Confirmez-vous?
                return.
            end.
            else delete ttError.
        end.
    end. /*if ttEnteteAppelDeFond.cCodeTypeAppel = {&TYPEAPPEL2FONDS-financementRoulement}  */

    if ttEnteteAppelDeFond.iNombreAppel = 0
    then do:
        mError:createError({&error}, 108128).    // Au moins sur un appel
        return.
    end.

    /**Ajout OF le 13/09/11**/
    /*En gérance, on ne saisit pas la répartition par clé
      -> Création automatique sur la clé "" avec le montant total à appeler*/
    if ttDossierTravaux.cCodeTypeMandat = {&TYPECONTRAT-mandat2Gerance}
    and not can-find(first ttRepartitionCle)
    then do:
        create ttRepartitionCle.
        assign
            ttRepartitionCle.cCodeCle    = ""
            ttRepartitionCle.dMontantCle = ttEnteteAppelDeFond.dMontantAppel
            ttRepartitionCle.lAff        = true
        .
    end.
    /*--> Le montant total de la repartion doit etre egal au montant à appeler */
    if ttEnteteAppelDeFond.cCodeTypeAppelSur = "00001"
    or ttEnteteAppelDeFond.cCodeTypeAppelSur = ?
    or ttEnteteAppelDeFond.cCodeTypeAppelSur = ""
    then for each ttRepartitionCle:

message "gga ValidDetailAppel-01 boucle ttrepartitioncle " ttRepartitionCle.dMontantCle.

        assign
            vdMtTotRep = vdMtTotRep + ttRepartitionCle.dMontantCle
            vdMtRepCle = 0
        .
        /*--> On regarde s'il y a modification de la repartition */
        for each ttAppelDeFondRepCle
            where ttAppelDeFondRepCle.cCodeCle = ttRepartitionCle.cCodeCle:
            vdMtRepCle = ttAppelDeFondRepCle.dMontantAppel.
        end.
        if not vlFgModRep
        then vlFgModRep = not (vdMtRepCle = ttRepartitionCle.dMontantCle).
    end.
    else for each ttRepartitionCopro:
        /*--> On regarde s'il y a modification de la repartition */
        assign
            vdMtTotRep = vdMtTotRep + ttRepartitionCopro.dMontantCopro
            vdMtRepCop = 0
        .
        for each ttAppelDeFondRepMat
            where ttAppelDeFondRepMat.iNumeroCopro = ttRepartitionCopro.iNumeroCopro
              and ttAppelDeFondRepMat.iNumeroLot = ttRepartitionCopro.iNumeroLot:
            vdMtRepCop = ttAppelDeFondRepMat.dMontantAppel.
        end.
        if not vlFgModRep
        then vlFgModRep = not (vdMtRepCop = ttRepartitionCopro.dMontantCopro).
    end.

    if vdMtTotRep <> ttEnteteAppelDeFond.dMontantAppel
    then do:
        mError:createError({&error}, 108129).
        return.
    end.

    /*--> Le total des échéances doit faire 100% (ou 0 si répartition automatique) */
    vdMtTotRep = 0.
    for each ttRepartitionPourcentage:
        vdMtTotRep = vdMtTotRep + ttRepartitionPourcentage.dPourcentageEcheance.
    end.
    if vdMtTotRep > 0 and vdMtTotRep < 100
    then do:
        mError:createError({&error}, 4000018).    // Le total des échéances ne fait pas 100%
        return.
    end.

    if pcCdSenUse = "MAJENT"
    then do:
        /*--> s'il y a ecart ou s'il y a modification du parametrage de repartition */
        if ttEnteteAppelDeFond.dMontantEcart <> 0 or vlFgModRep
        then do:
            viCpUseInc = 0.
            for each ttAppelDeFond
                where ttAppelDeFond.iNumeroIdentifiant = ttEnteteAppelDeFond.iNumeroIdentifiant
                  and ttAppelDeFond.lFlagEmis = true:
                if ttAppelDeFond.cCodeTraitement <> "M"
                or (ttAppelDeFond.cCodeTraitement = "M" /*gga todo and ttAppelDeFond.FgRepDef ggg champ jamais initialise (dans ce cas virer le test sur ttAppelDeFond.cCodeTraitement */ )
                then assign
                    viCpUseInc = viCpUseInc + 1
                    viNoAppUse = ttAppelDeFond.iNumeroAppel
                .
            end.
            if viCpUseInc >= ttEnteteAppelDeFond.iNombreAppel
            then do:
                if ttDossierTravaux.cCodeTypeMandat = {&TYPECONTRAT-mandat2Gerance}
                then do:
                    for first dosap no-lock
                        where dosap.tpcon = ttDossierTravaux.cCodeTypeMandat
                          and dosap.nocon = ttDossierTravaux.iNumeroMandat
                          and dosap.nodos = ttDossierTravaux.iNumeroDossierTravaux
                          and dosap.noapp = viNoAppUse
                      , first cecrsai no-lock
                        where cecrsai.soc-cd    = integer(entry(2, dosap.lbdiv1, "@"))
                          and cecrsai.etab-cd   = integer(entry(3, dosap.lbdiv1, "@"))
                          and cecrsai.jou-cd    = entry(4, dosap.lbdiv1, "@")
                          and cecrsai.prd-cd    = integer(entry(5, dosap.lbdiv1, "@"))
                          and cecrsai.prd-num   = integer(entry(6, dosap.lbdiv1, "@"))
                          and cecrsai.piece-int = integer(entry(7, dosap.lbdiv1, "@")):
                        find first ietab no-lock
                            where ietab.soc-cd  = cecrsai.soc-cd
                              and ietab.etab-cd = cecrsai.etab-cd no-error.
                        find first agest no-lock
                            where agest.soc-cd = ietab.soc-cd
                              and agest.gest-cle = ietab.gest-cle no-error.
                        if available agest and cecrsai.dacompta >= agest.dadeb
                        then do:
                            if not can-find(first ttError
                                where ttError.iType = {&question}
                                  and lookup(entry(1, ttError.cComplement, ":"), "4000019") > 0
                                  and ttError.cError matches "*comptable*"
                                  and num-entries(ttError.cComplement, ":") > 1
                                  and entry(2, ttError.cComplement, ":") = "oui")
/*gga todo test apres creation du message */
                            then do:
                                /* La pièce comptable correspondant à l'appel de fonds à modifier va être supprimée. Confirmez-vous ? */
                                mError:createError({&error}, 4000019).
                                return.
                            end.
                        end.
                        else do:
                            /*Votre modification ne peut être effectuée car l'ensemble des appels sont emis. Augmenter le nombre d'appel.*/
                            mError:createError({&error}, 108131).
                            return.
                        end.
                    end.
                end.
                else do:
                    if ttEnteteAppelDeFond.dMontantEcart <> 0
                    then mError:createError({&error}, 108130). /*L'écart ne peut-être réparti car l'ensemble des appels sont emis. Augmentez le nombre d'appel.*/
                    else mError:createError({&error}, 108131). /*Votre modification ne peut être effectuée car l'ensemble des appels sont emis. Augmenter le nombre d'appel.*/
                    return.
                end.
            end.
        end.

        /*--> Le nombre d'appel ne peut être inférieur au nombre d'appel émis sur l'entete */
        viCpUseInc = 0.
        for each ttAppelDeFond
            where ttAppelDeFond.iNumeroIdentifiant = ttEnteteAppelDeFond.iNumeroIdentifiant
              and ttAppelDeFond.lFlagEmis:
            if ttAppelDeFond.cCodeTraitement <> "M"
            or (ttAppelDeFond.cCodeTraitement = "M" /*gga and ttAppelDeFond.FgRepDef gga champ jamais initialise */ )
            then viCpUseInc = viCpUseInc + 1.
        end.
        if viCpUseInc > ttEnteteAppelDeFond.iNombreAppel
        then do:
            mError:createError({&error}, 108132).    // Le nombre d'appel à émettre ne peut être inférieur au nombre d'appel déjà émis
            return.
        end.
    end.
    plCtrlOk = yes.

end procedure.

procedure ValidDetailAppel-02 private:
    /*------------------------------------------------------------------------------
    Purpose: correspond a procedure ValEnt dans visdoapp.p
    Notes  : appel a plusieurs procedure dans gesdossi.p
    ------------------------------------------------------------------------------*/
    define input parameter pcCdSenUse      as character no-undo.
    define input parameter piNoIdentifiant as integer   no-undo.
    define parameter buffer ttDossierTravaux for ttDossierTravaux.

    define variable viNoIdtUse as integer   no-undo.
    define variable vcTpAppUse as character no-undo.
    define variable vcTpColUse as character no-undo.
    define variable vcTpSurUse as character no-undo.
    define variable viNoIntUse as integer   no-undo.
    define variable vcNoFouUse as character no-undo.
    define variable vcLbTypUse as character no-undo.
    define variable vcLbSurUse as character no-undo.
    define variable vcNmFouUse as character no-undo.
    define variable vcLbIntUse as character no-undo.
    define variable viNbAppUse as integer   no-undo.
    define variable vdMtAppUse as decimal   no-undo.
    define variable vcLbTvaUse as character no-undo.
    define variable vdMtTvaUse as decimal   no-undo.
    define variable vdMtEcaUse as decimal   no-undo.
    define variable viNoPreApp as integer   no-undo.
    define variable vcCdTypEnt as character no-undo.
    define variable vcLbEchUse as character no-undo.
    define variable viCdTvaUSe as integer   no-undo.

message "gga ValidDetailAppel-02 debut " piNoIdentifiant.

    {&_proparse_ prolint-nowarn(noerror)}
    find first ttEnteteAppelDeFond
        where ttEnteteAppelDeFond.iNumeroIdentifiant = piNoIdentifiant.       /* gga existe controle dans procedure precedente */
    assign
        viNoIdtUse = if pcCdSenUse = "MAJENT" then ttEnteteAppelDeFond.iNumeroIdentifiant else 0
        vcTpAppUse = ttEnteteAppelDeFond.cCodeTypeAppel
        vcTpColUse = if lookup(ttEnteteAppelDeFond.cCodeTypeAppel, substitute("&1,&2,&3", {&TYPEAPPEL2FONDS-financementRoulement}, {&TYPEAPPEL2FONDS-financementReserve}, {&TYPEAPPEL2FONDS-fondtravauxAlur})) > 0
                     then ttEnteteAppelDeFond.cCodeCollectifFinancement /*gga ttEnteteAppelDeFond.cCodeCollectifFour ???? */
                     else ""
        vcTpSurUse = ttEnteteAppelDeFond.cCodeTypeAppelSur
        viNoIntUse = ttEnteteAppelDeFond.iNumeroIntervention
        vcNoFouUse = ttEnteteAppelDeFond.cCodeFournisseur
        vcLbTypUse = ttEnteteAppelDeFond.cLibelleTypeAppel
        vcLbSurUse = ttEnteteAppelDeFond.cLibelleAppelSur
        vcNmFouUse = ttEnteteAppelDeFond.cLibelleFournisseur
        vcLbIntUse = ttEnteteAppelDeFond.cLibelleIntervention
        viNbAppUse = ttEnteteAppelDeFond.iNombreAppel
        vdMtAppUse = ttEnteteAppelDeFond.dMontantAppel
        vcLbTvaUse = string(ttEnteteAppelDeFond.dTauxTVA)
        vdMtTvaUse = ttEnteteAppelDeFond.dMontantTva
        vdMtEcaUse = ttEnteteAppelDeFond.dMontantEcart
        viNoPreApp = ttEnteteAppelDeFond.iNumeroPremierAppel /*integer(HwFilPar:SCREEN-VALUE). */
        /*gga ??????????????? ttEnteteAppelDeFond.cRepriseAppel mais contien le libelle pas ma valeur n p ou e
           vcCdTypEnt = HwRadTypEnt:SCREEN-VALUE
        gga*/
        viCdTvaUSe = ttEnteteAppelDeFond.iCodeTva
    .
    for each ttRepartitionPourcentage
        where ttRepartitionPourcentage.dPourcentageEcheance <> 0:
        vcLbEchUse = vcLbEchUse + "," + string(ttRepartitionPourcentage.dPourcentageEcheance).
    end.
    vcLbEchUse = trim(vcLbEchUse, ",").
    empty temp-table ttRepartitionPourcentage.
    run validDetailAppel-03(
        pcCdSenUse,  /*- Creation / Modification -*/
        viNoIdtUse,  /*- Identifiant entete      -*/
        vcTpAppUse,  /*- Type d'Appel            -*/
        vcTpSurUse,  /*- Imm/Matricule           -*/
        viNoIntUse,  /*- N° Entete               -*/
        vcNoFouUse,  /*- N° fournisseur          -*/
        vcLbTypUse,  /*- libelle Type d'Appel    -*/
        vcLbSurUse,  /*- Libelle Imm/Matricule   -*/
        vcNmFouUse,  /*- Libelle fournisseur     -*/
        vcLbIntUse,  /*- Libelle appel           -*/
        viNbAppUse,  /*- Nombre d'appel de fonds -*/
        vdMtAppUse,  /*- Montant de l'appel      -*/
        viCdTvaUSe,  /*- Code TVA                -*/
        vcLbTvaUse,  /*- Libelle TVA             -*/
        vdMtTvaUse,  /*- Montant TVA             -*/
        vdMtEcaUse,  /*- Montant Ecart           -*/
        viNoPreApp,  /*- N° du 1er appel         -*/
        vcTpColUse,  /*- Coll Fd rlt/rés         -*/
        vcCdTypEnt,  /*- Type de l'entête de l'appel-*/
        vcLbEchUse,   /*- Liste des échéances en %-*/
        buffer ttDossierTravaux
    ).
    run calAppHono (buffer ttDossierTravaux).
    run calculdossier.

end procedure.

procedure CalculDossier private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vdMtTotApp as decimal no-undo.
    define variable vdMtTotDos as decimal no-undo.
    define variable viNbTotApp as integer no-undo.

    for each ttAppelDeFond
        break by ttAppelDeFond.iNumeroIdentifiant
              by ttAppelDeFond.iNumeroAppel:
       if first-of(ttAppelDeFond.iNumeroAppel) then vdMtTotApp = 0.
       assign
           vdMtTotDos = vdMtTotDos + ttAppelDeFond.dMontantAppel
           vdMtTotApp = vdMtTotApp + ttAppelDeFond.dMontantAppel
       .
       if last-of(ttAppelDeFond.iNumeroAppel) then ttAppelDeFond.dMontantTotal = vdMtTotApp.
    end.
    for each ttAppelDeFond
        break by ttAppelDeFond.iNumeroAppel:
       if first-of(ttAppelDeFond.iNumeroAppel) then viNbTotApp = viNbTotApp + 1.
    end.
    for first ttDossierAppelDeFond:
        assign
            ttDossierAppelDeFond.dMontantTravaux = vdMtTotDos
            ttDossierAppelDeFond.iNbrAppel       = viNbTotApp
        .
    end.

end procedure.

procedure getInfoSaisieAppelDeFond:
    /*------------------------------------------------------------------------------
    Purpose: en maj appel, appel de cette procedure pour retourner les informations dependantes du type
    Notes  : Service externe (beAppelDeFond.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter poCollection as collection no-undo.
    define output parameter table for ttInfoSaisieAppelDeFond.
    define output parameter table for ttDossierAppelDeFond.
    define output parameter table for ttCombo.

    define variable viSociete              as integer   no-undo.
    define variable vcTypeMandat           as character no-undo.
    define variable viNumeroMandat         as int64     no-undo.
    define variable viNumeroDossierTravaux as integer   no-undo.
    define variable vcTypeAppel            as character no-undo.
    define variable vcTypeDemande          as character no-undo.
    define variable vhProcSoldeCompte      as handle    no-undo.

    define buffer ijou    for ijou.
    define buffer aetabln for aetabln.

    assign
        vcTypeMandat           = poCollection:getCharacter("cTypeMandat")
        viNumeroMandat         = poCollection:getInteger("iNumeroMandat")
        viNumeroDossierTravaux = poCollection:getInteger("iNumeroDossierTravaux")
        vcTypeAppel            = poCollection:getCharacter("cTypeAppel")
        vcTypeDemande          = poCollection:getCharacter("cTypeDemande")
        viSociete              = mtoken:getSociete(vcTypeMandat)
    .

 message "gga getInfoSaisieAppelDeFond " vcTypeMandat "//" viNumeroMandat "//" viNumeroDossierTravaux "//" vcTypeAppel "//" vcTypeDemande.

    if vcTypeDemande = "infodossierappel" then run creationttDossierAppelDeFond (poCollection).

    if vcTypeDemande = "seltypeappel"
    then do:
        empty temp-table ttInfoSaisieAppelDeFond.
        empty temp-table ttSoldeCompte.
        create ttInfoSaisieAppelDeFond.
        assign
            ttInfoSaisieAppelDeFond.lSaisieFondAlur = no
            ttInfoSaisieAppelDeFond.dMontantFondAlur = 0
        .
        if vcTypeAppel = {&TYPEAPPEL2FONDS-fondtravauxAlur}
        then for first aetabln no-lock
            where aetabln.soc-cd  = viSociete
              and aetabln.etab-cd = viNumeroMandat
              and aetabln.fg-tvx  = true
          , first ijou no-lock
            where ijou.soc-cd = aetabln.soc-cd
              and ijou.etab-cd = aetabln.etab-cd
              and ijou.jou-cd = aetabln.jou-cd:
            ttInfoSaisieAppelDeFond.lSaisieFondAlur = yes.
            run compta/soldecompte.p persistent set vhProcSoldeCompte.
            run getTokenInstance in vhProcSoldeCompte(mToken:JSessionId).
            run getSoldeCompte in vhProcSoldeCompte(vcTypeMandat, viNumeroMandat, ijou.cpt-cd, "S", output table ttSoldeCompte by-reference).
            run destroy in vhProcSoldeCompte.
            for first ttSoldeCompte:
                ttInfoSaisieAppelDeFond.dMontantFondAlur = - ttSoldeCompte.dSolde.
            end.
        end. /* if pcTypeAppel = {&TYPEAPPEL2FONDS-fondtravauxAlur} */
        if vcTypeAppel = {&TYPEAPPEL2FONDS-travaux}
        or vcTypeAppel = {&TYPEAPPEL2FONDS-architecte}
        or vcTypeAppel = {&TYPEAPPEL2FONDS-dommageOuvrage}
        then run chgCmbInt (poCollection).
    end.

end procedure.

procedure ChgCmbInt private:
    /*------------------------------------------------------------------------------
    Purpose: init liste des interventions disponibles en fonction du type de travaux
    Notes  : extrait de visdoapp.p ChgCmbInt
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as collection no-undo.

    define variable vcTypeMandat     as character no-undo.
    define variable viNumeroMandat   as int64     no-undo.
    define variable viDossierTravaux as integer   no-undo.
    define variable vcTypeAppel      as character no-undo.
    define variable vhIntervention   as handle    no-undo.
    define variable vcTpUrgUse       as character no-undo.
    define variable vcTpTrxUse       as character no-undo.
    define variable vcLbArtUse       as character no-undo.
    define variable vccdtvaUse       as character no-undo.
    define variable vlFgVen100       as logical   no-undo.
    define variable vcNorubUse       as character no-undo.
    define variable vcNossrUse       as character no-undo.
    define variable vcNoFisUse       as character no-undo.
    define variable vccdcolUse       as character no-undo.
    define variable vcNoCptUse       as character no-undo.
    define variable vcNoScpUse       as character no-undo.

    define buffer trdos for trdos.

    assign
        vcTypeMandat     = poCollection:getCharacter("cTypeMandat")
        viNumeroMandat   = poCollection:getInteger("iNumeroMandat")
        viDossierTravaux = poCollection:getInteger("iNumeroDossierTravaux")
        vcTypeAppel      = poCollection:getCharacter("cTypeAppel")
    .
    poCollection:set('cCodeStatutIntervention', "") no-error.
    run travaux/intervention/intervention.p persistent set vhIntervention.
    run getTokenInstance      in vhIntervention (mToken:JSessionId).
    run getListeInterventions in vhIntervention(poCollection, output table ttListeIntervention by-reference).
    run destroy in vhIntervention.

    vcTpUrgUse = "".
    for first trdos no-lock
        where trdos.tpcon = vcTypeMandat
          and trdos.nocon = viNumeroMandat
          and trdos.nodos = viDossierTravaux:
        vcTpUrgUse = trdos.tpurg.
    end.

    /*--> Lister les interventions encore disponible */
boucle:
    for each ttListeIntervention
        break by ttListeIntervention.iNumeroIntervention
              by ttListeIntervention.cCodeTraitement
              by ttListeIntervention.iNumeroTraitement:

        if last-of(ttListeIntervention.iNumeroTraitement)
        then do:
            /*--> Prendre les OS et les reponses votés*/
            if ttListeIntervention.cCodeTraitement <> {&TYPEINTERVENTION-ordre2service}
            and ttListeIntervention.cCodeTraitement <> {&TYPEINTERVENTION-reponseDevis} then next boucle.

            if ttListeIntervention.cCodeTraitement = {&TYPEINTERVENTION-reponseDevis}
            and ttListeIntervention.cCodeStatut <> {&STATUTINTERVENTION-vote}
            and ttListeIntervention.cCodeStatut <> {&STATUTINTERVENTION-voteResp}
            and ttListeIntervention.cCodeStatut <> {&STATUTINTERVENTION-VoteProp}
            and ttListeIntervention.cCodeStatut <> {&STATUTINTERVENTION-voteCS}
            and ttListeIntervention.cCodeStatut <> {&STATUTINTERVENTION-voteAG} then next boucle.

            run prmArtic(
                vcTypeMandat,
                vcTpUrgUse,
                yes,
                ttListeIntervention.cCodeArticle,
                output vcLbArtUse,
                output vccdtvaUse,
                output vlFgVen100,
                output vcNorubUse,
                output vcNossrUse,
                output vcNoFisUse,
                output vccdcolUse,
                output vcNoCptUse,
                output vcNoScpUse,
                output vcTpTrxUse
            ).
            if (vcTpTrxUse = vcTypeAppel
             or integer(ttListeIntervention.cCodeArticle) = 0
             or (vcTypeAppel = {&TYPEAPPEL2FONDS-travaux} and (vcTpTrxUse = ? or vcTpTrxUse = "")))
            and not can-find(first ttEnteteAppelDeFond /*--> Cette intervention a-t-elle déjà une entete d'appel */
                             where ttEnteteAppelDeFond.iNumeroIdentifiant = ttListeIntervention.iNumeroIntervention)
            then createttCombo('TYPE-INTERVENTION', string(ttListeIntervention.iNumeroIntervention), ttListeIntervention.cLibelleIntervention).
        end.
    end.

end procedure.

procedure PrmArtic private:
    /*------------------------------------------------------------------------------
    Purpose: recherche parametrage associe a article travaux
    Notes  :extrait gidev/comm/prmartic.i
    ------------------------------------------------------------------------------*/
    define input  parameter pctpconUse-IN as character    no-undo.
    define input  parameter pcTpUrgUse-IN as character    no-undo.
    define input  parameter plFgDosUse-IN as logical      no-undo.
    define input  parameter pcCdArtUse-IN as character    no-undo.
    define output parameter pcLbArtUse-OU as character    no-undo.
    define output parameter pcCdtvaUse-OU as character    no-undo.
    define output parameter plFgVen100-OU as logical      no-undo.
    define output parameter pcNorubUse-OU as character    no-undo.
    define output parameter pcNossrUse-OU as character    no-undo.
    define output parameter pcNoFisUse-OU as character    no-undo.
    define output parameter pccdcolUse-OU as character    no-undo.
    define output parameter pcNoCptUse-OU as character    no-undo.
    define output parameter pcNoScpUse-OU as character    no-undo.
    define output parameter pcTpTravau-OU as character    no-undo.

    define variable viSociete  as integer no-undo.

    define buffer artic     for artic.
    define buffer csscptcol for csscptcol.
    define buffer prmar     for prmar.
    define buffer prmtv     for prmtv.
    define buffer prmrg     for prmrg.
    define buffer PrmAna    for PrmAna.

    viSociete = mtoken:getSociete(pctpconUse-IN).
    /*--> Recherche du parametrage article */
    for first artic no-lock
        where artic.cdart = pcCdArtUse-IN:
        assign
            pcLbArtUse-OU = artic.lbart
            pcCdtvaUse-OU = string(artic.CdTva)
        .
        /*--> affichage des zones de saisie detail du regroupement et du type de contrat selectionnes */
        if artic.cdrgt = "00000" or artic.cdrgt = ? or artic.cdrgt = ""
        then for first prmar no-lock   /*--> pas de regroupement pour l'article => chargement du parametrage propre a l'article */
            where prmar.cdart = pcCdArtUse-IN
              and prmar.tpcon = pctpconUse-IN
              and prmar.fgdos = plFgDosUse-IN
              and integer(prmar.tpurg) = integer(pcTpUrgUse-IN):
            assign
                pccdcolUse-OU = prmar.CdCol
                pcNorubUse-OU = trim(prmar.NoRub)
                pcNossrUse-OU = trim(prmar.NoSsr)
                pcNoFisUse-OU = trim(prmar.NoFis)
                plFgVen100-OU = not prmar.fgven
            .
            if prmar.CdCol = ? or prmar.CdCol = ""
            then assign
                pcNoCptUse-OU = substring(prmar.CptCd, 1, 4, 'character')
                pcNoScpUse-OU = substring(prmar.CptCd, 5, 5, 'character')
            .
            else for first csscptcol no-lock
                where csscptcol.soc-cd     = viSociete
                  and csscptcol.etab-cd    > 0
                  and csscptcol.sscoll-cle = prmar.CdCol:
                assign
                    pcNoCptUse-OU = csscptcol.sscoll-cpt
                    pcNoScpUse-OU = "00000"
                .
            end.
/****************
                /*--> Ventilation */
                if prmar.fgven then do:
                    /* tableau => impossible de retrouver le type de travaux */
                end.
****************/
        end.
        else for first prmtv no-lock        /*--> article lie a un regroupement => chargement des details du regroupement */
            where prmtv.tppar = "REGRT"
              and prmtv.cdpar = artic.cdrgt
          , first prmrg no-lock
            where prmrg.cdrgt = prmtv.cdpar
              and prmrg.tpcon = pctpconUse-IN
              and prmrg.fgdos = plFgDosUse-IN
              and integer(prmrg.tpurg) = integer(pcTpUrgUse-IN):
            assign
                pccdcolUse-OU = prmrg.CdCol
                pcNorubUse-OU = trim(prmrg.NoRub)
                pcNossrUse-OU = trim(prmrg.NoSsr)
                pcNoFisUse-OU = trim(prmrg.NoFis)
                plFgVen100-OU = not prmrg.fgven
            .
            if prmrg.CdCol = ? or prmrg.CdCol = ""
            then assign
                pcNoCptUse-OU = substring(prmrg.CptCd, 1, 4, 'character')
                pcNoScpUse-OU = substring(prmrg.CptCd, 5, 5, 'character')
            .
            else for first csscptcol no-lock
                where csscptcol.soc-cd = viSociete
                  and csscptcol.etab-cd > 0
                  and csscptcol.sscoll-cle = prmrg.CdCol:
                assign
                    pcNoCptUse-OU = csscptcol.sscoll-cpt
                    pcNoScpUse-OU = "00000"
                .
            end.
/*************************
            /*--> Ventilation */
            if prmrg.fgven then do:
                /* tableau => impossible de retrouver le type de travaux */
            end.
*************************/
        end.

        if pcNorubUse-OU > ""
        then do:
            find first prmAna no-lock         /* recherche paramétrage type de travaux - analytique */
                where prmAna.tppar = "ANATX"
                  and prmAna.tpcon = pctpconUse-IN
                  and prmAna.fgdos = plFgDosUse-IN
                  and integer(prmAna.tpurg) = integer(pcTpUrgUse-IN)
                  and prmAna.norub = pcNorubUse-OU
                  and prmAna.nossr = pcNossrUse-OU no-error.
            pcTpTravau-OU = if available prmana then prmAna.cdpar else "00001".  /* par défaut : travaux */
        end.
    end. /* for first artic */

end procedure.

procedure ValidDetailAppel-03 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Note   :  extrait de gesdossi.p procedure ValAppel
    -------------------------------------------------------------------------------*/
    define input parameter pcCdSenUse as character no-undo.  /*- Creation / Modification -*/
    define input parameter piNoIdtUse as integer   no-undo.  /*- Identifiant entete      -*/
    define input parameter pcTpAppUse as character no-undo.  /*- Type d'Appel            -*/
    define input parameter pcTpSurUse as character no-undo.  /*- Imm/Matricule           -*/
    define input parameter piNoIntUse as integer   no-undo.  /*- N° Entete               -*/
    define input parameter pcNoFouUse as character no-undo.  /*- N° fournisseur          -*/
    define input parameter pcLbTypUse as character no-undo.  /*- libelle Type d'Appel    -*/
    define input parameter pcLbSurUse as character no-undo.  /*- Libelle Imm/Matricule   -*/
    define input parameter pcNmFouUse as character no-undo.  /*- Libelle fournisseur     -*/
    define input parameter pcLbIntUse as character no-undo.  /*- Libelle appel           -*/
    define input parameter piNbAppUse as integer   no-undo.  /*- Nombre d'appel de fond  -*/
    define input parameter pdMtAppUse as decimal   no-undo.  /*- Montant de l'appel      -*/
    define input parameter piCdTvaUse as integer   no-undo.  /*- code TVA                -*/
    define input parameter pcLbTvaUse as character no-undo.  /*- Libelle TVA             -*/
    define input parameter pdMtTvaUse as decimal   no-undo.  /*- Montant TVA             -*/
    define input parameter pdMtEcaUse as decimal   no-undo.  /*- Montant Ecart           -*/
    define input parameter piNoPreApp as integer   no-undo.  /*- N° du 1er appel         -*/
    define input parameter pcTpColUse as character no-undo.  /*- Collectif Fond rlt/rés  -*/
    define input parameter pcCdTypEnt as character no-undo.  /*- Type de l'entète de l'appel -*/
    define input parameter pcLbEchEnt as character no-undo.  /*- Liste des échéances en %-*/  /**Ajout OF le 22/08/11**/
    /** N : Appels GI uniquement **/
    /** P : Appels GI + des reprises d'appels **/
    /** E : Exclusivement des reprises d'appels **/
    define parameter buffer ttDossierTravaux for ttDossierTravaux.

    define variable viNoOrdUse   as integer   no-undo.
    define variable viNbTotApp   as integer   no-undo.
    define variable viNoDerEmi   as integer   no-undo.
    define variable viNoDerApp   as integer   no-undo.
    define variable vdMtCleEmi   as decimal   no-undo.
    define variable vdMtCleRep   as decimal   no-undo.
    define variable vdMtRepUse   as decimal   no-undo.
    define variable vdMtTotEnt   as decimal   no-undo.
    define variable vdMtTotApp   as decimal   no-undo.
    define variable viI          as integer   no-undo.
    define variable viJ          as integer   no-undo.
    define variable vdTotRepUse  as decimal   no-undo.
    define variable vcLbTmpPdt   as character no-undo.
    define variable viCpUseInc   as integer   no-undo.

    define buffer vbttEnteteAppelDeFond for ttEnteteAppelDeFond.
    define buffer vbttAppelDeFond       for ttAppelDeFond.
    define buffer apbco                 for apbco.

message "gga ValidDetailAppel-03 debut appel depuis " program-name(1) program-name(2) program-name(3)  piNoPreApp.

    /*--ENTETE D'APPEL---------------------------------------------------------------------------------------------------------*/
    /*--> Creation modification de l'entete */
    if pcCdSenUse = "NEWENT"
    then do:
        find first ttEnteteAppelDeFond
            where ttEnteteAppelDeFond.iNumeroIdentifiant = piNoIdtUse no-error.
        if not available ttEnteteAppelDeFond
        then do:
            create ttEnteteAppelDeFond.
            assign
                ttEnteteAppelDeFond.CRUD               = 'C'
                ttEnteteAppelDeFond.iNumeroIdentifiant = piNoIdtUse
            .
        end.
        find first vbttEnteteAppelDeFond
            where vbttEnteteAppelDeFond.iNumeroIdentifiant < 0 no-error.
        piNoIdtUse = if available vbttEnteteAppelDeFond then vbttEnteteAppelDeFond.iNumeroIdentifiant - 1 else -1.
        {&_proparse_ prolint-nowarn(use-index)}
        find last vbttEnteteAppelDeFond use-index idxiNumeroOrdre no-error.
        assign
            viNoOrdUse = if available vbttEnteteAppelDeFond then vbttEnteteAppelDeFond.iNumeroOrdre + 1 else 1
            ttEnteteAppelDeFond.iNumeroIdentifiant  = piNoIdtUse
            ttEnteteAppelDeFond.iNumeroOrdre        = viNoOrdUse
            ttEnteteAppelDeFond.iNumeroIntervention = if lookup(pcTpAppUse , substitute("&1,&2,&3", {&TYPEAPPEL2FONDS-travaux}, {&TYPEAPPEL2FONDS-architecte}, {&TYPEAPPEL2FONDS-dommageOuvrage})) > 0
                                                      then piNoIntUse
                                                      else 0
            ttEnteteAppelDeFond.cCodeTypeAppel      = pcTpAppUse
            ttEnteteAppelDeFond.cCodeCollectifFinancement = pcTpColUse
            ttEnteteAppelDeFond.cCodeTypeAppelSur   = pcTpSurUse
            ttEnteteAppelDeFond.cLibelleAppelSur    = pcLbSurUse
            ttEnteteAppelDeFond.cLibelleTypeAppel   = outilTraduction:getLibelleParam("TPDOS", pcTpAppUse)  /*gga todo a voir pour les 2 derniers champs */
        .
    end. /* if pcCdSenUse = "NEWENT" */

    {&_proparse_ prolint-nowarn(noerror)}
    find first ttEnteteAppelDeFond
        where ttEnteteAppelDeFond.iNumeroIdentifiant = piNoIdtUse.             /*gga doit exister */
    assign
        ttEnteteAppelDeFond.cCodeFournisseur     = pcNoFouUse
        ttEnteteAppelDeFond.cLibelleFournisseur  = pcNmFouUse
        ttEnteteAppelDeFond.cLibelleIntervention = pcLbIntUse
        ttEnteteAppelDeFond.iNombreAppel  = piNbAppUse
        ttEnteteAppelDeFond.dMontantAppel = pdMtAppUse
        ttEnteteAppelDeFond.iCodeTva      = piCdTvaUse
        ttEnteteAppelDeFond.dTauxTVA      = decimal(pcLbTvaUse)
        ttEnteteAppelDeFond.dMontantTva   = pdMtTvaUse
        ttEnteteAppelDeFond.dMontantEcart = pdMtEcaUse
        ttEnteteAppelDeFond.lbcom         = pcCdTypEnt
    .
    /*--SUPPRESSION DES APPELS NON EMIS----------------------------------------------------------------------------------------*/
    for each ttAppelDeFond
        where ttAppelDeFond.iNumeroIdentifiant = piNoIdtUse
          and ( (ttAppelDeFond.lFlagEmis = false and ttAppelDeFond.cModeTraitement <> "M")
             or (ttAppelDeFond.lFlagEmis = true  and ttAppelDeFond.cModeTraitement = "M"
               /*gga AND TbTmpDat.fgrepdef = FALSE   gga a quoi correspond ce champ ???*/
               and not can-find(first apbco no-lock
                                where apbco.nomdt = ttDossierTravaux.iNumeroMandat
                                  and apbco.tpapp = {&TYPEAPPEL-dossierTravaux}
                                  and apbco.nobud = ttDossierTravaux.iNumeroMandat * 100000 + ttDossierTravaux.iNumeroDossierTravaux  // integer(string(ttDossierTravaux.iNumeroMandat , "9999") + string(ttDossierTravaux.iNumeroDossierTravaux , "99999"))
                                  and apbco.noapp = ttAppelDeFond.iNumeroAppel)) ):
        delete ttAppelDeFond.
    end.
    for each ttAppelDeFondRepCle
        where ttAppelDeFondRepCle.iNumeroIdentifiant = piNoIdtUse  /** AND TbTmpApp.noapp > viNoDerEmi **/
      , first ttAppelDeFond
        where ttAppelDeFond.iNumeroIdentifiant = ttAppelDeFondRepCle.iNumeroIdentifiant
          and ttAppelDeFond.iNumeroAppel = ttAppelDeFondRepCle.iNumeroAppel
          and ( (ttAppelDeFond.lFlagEmis = false and ttAppelDeFond.cModeTraitement <> "M")
             or (ttAppelDeFond.lFlagEmis = true  and ttAppelDeFond.cModeTraitement = "M"
               /*gga AND TbTmpDat.fgrepdef = FALSE   gga a quoi correspond ce champ ???*/
               and not can-find (first apbco no-lock
                                 where apbco.nomdt = ttDossierTravaux.iNumeroMandat
                                   and apbco.tpapp = {&TYPEAPPEL-dossierTravaux}
                                   and apbco.nobud = ttDossierTravaux.iNumeroMandat * 100000 + ttDossierTravaux.iNumeroDossierTravaux  // integer( string(ttDossierTravaux.iNumeroMandat , "9999") + STRING(ttDossierTravaux.iNumeroDossierTravaux , "99999") )
                                   and apbco.noapp = ttAppelDeFond.iNumeroAppel)) ):
        delete ttAppelDeFondRepCle.
    end.
    for each ttAppelDeFondRepMat
        where ttAppelDeFondRepMat.iNumeroIdentifiant = piNoIdtUse
      , first ttAppelDeFond
        where ttAppelDeFond.iNumeroIdentifiant = ttAppelDeFondRepMat.iNumeroIdentifiant
          and ttAppelDeFond.iNumeroAppel = ttAppelDeFondRepMat.iNumeroAppel
          and ( (ttAppelDeFond.lFlagEmis = false and ttAppelDeFond.cModeTraitement <> "M")
             or (ttAppelDeFond.lFlagEmis = true  and ttAppelDeFond.cModeTraitement = "M"
               /*gga AND TbTmpDat.fgrepdef = FALSE   gga a quoi correspond ce champ ???*/
               and not can-find (first apbco no-lock
                                 where apbco.nomdt = ttDossierTravaux.iNumeroMandat
                                   and apbco.tpapp = {&TYPEAPPEL-dossierTravaux}
                                   and apbco.nobud = ttDossierTravaux.iNumeroMandat * 100000 + ttDossierTravaux.iNumeroDossierTravaux   // integer(string(ttDossierTravaux.iNumeroMandat, "9999") + string(ttDossierTravaux.iNumeroDossierTravaux, "99999"))
                                   and apbco.noapp = ttAppelDeFond.iNumeroAppel)) ):
        delete ttAppelDeFondRepMat.
    end.

    /*--POINTEURS--------------------------------------------------------------------------------------------------------------*/
    /*--> Nombre total d'appel à émettre */
    viNbTotApp = piNbAppUse.
    /*--> On recherche le dernier appel emis sur le dossier */
    if ttEnteteAppelDeFond.lbcom <> "E"
    then for last ttAppelDeFond
        where ttAppelDeFond.lFlagEmis
          and ttAppelDeFond.iNumeroAppel < 50:
        viNoDerEmi = ttAppelDeFond.iNumeroAppel.
    end.
    else do:
        find last ttAppelDeFond
            where ttAppelDeFond.lFlagEmis
              and ttAppelDeFond.iNumeroAppel >= 50
              and can-find (first apbco no-lock
                            where apbco.nomdt = ttDossierTravaux.iNumeroMandat
                              and apbco.tpapp = {&TYPEAPPEL-dossierTravaux}
                              and apbco.nobud = integer(string(ttDossierTravaux.iNumeroMandat, "9999") + string(ttDossierTravaux.iNumeroDossierTravaux, "99999") )
                              and apbco.noapp = ttAppelDeFond.iNumeroAppel) no-error.
        viNoDerEmi = if available ttAppelDeFond then ttAppelDeFond.iNumeroAppel else 49.
    end.
    assign
        viNoDerApp = viNbTotApp + piNoPreApp - 1          /*--> On calcule le dernier appel */
        piNoPreApp = maximum(piNoPreApp, viNoDerEmi + 1)  /*--> On calcule le premier appel */
    .
    /*--CALENDRIER DES APPELS--------------------------------------------------------------------------------------------------*/
    /*--> Creation de la liste des appels */
    do viI = piNoPreApp to viNoDerApp:
        /*--> Creation / modification de l'appel / Creation de l'appel sur le dossier*/
        find first ttAppelDeFond
            where ttAppelDeFond.iNumeroIdentifiant = piNoIdtUse
              and ttAppelDeFond.iNumeroAppel = viI no-error.
        if not available ttAppelDeFond
        then do:
            create ttAppelDeFond.
            assign
                ttAppelDeFond.iNumeroIdentifiant = piNoIdtUse
                ttAppelDeFond.iNumeroAppel       = viI
                ttAppelDeFond.CRUD               = 'C'
                ttAppelDeFond.lFlagEmis          = no
            .
            for first vbttAppelDeFond
                where vbttAppelDeFond.iNumeroIdentifiant <> piNoIdtUse
                  and vbttAppelDeFond.iNumeroAppel = viI:
                ttAppelDeFond.daDateAppel = vbttAppelDeFond.daDateAppel.
            end.
        end.
        ttAppelDeFond.cLibelleAppel = substitute("App n°&1 : ", viI, ttEnteteAppelDeFond.cLibelleIntervention).
    end.

    /*--REPARTITION PAR CLE----------------------------------------------------------------------------------------------------*/
    if pcTpSurUse = "00001"
    then do:
        /*--> Repartion des appels */
        for each ttRepartitionCle:
            assign
                vdMtCleEmi = 0
                vdMtCleRep = 0
            .
            /*--> Cumul des appels déjà emis */
            for each ttAppelDeFond
                where ttAppelDeFond.iNumeroIdentifiant = piNoIdtUse
                  and ttAppelDeFond.lFlagEmis
              , first ttAppelDeFondRepCle
                where ttAppelDeFondRepCle.iNumeroIdentifiant = piNoIdtUse
                  and ttAppelDeFondRepCle.iNumeroAppel = ttAppelDeFond.iNumeroAppel
                  and ttAppelDeFondRepCle.cCodeCle = ttRepartitionCle.cCodeCle:
                vdMtCleEmi = vdMtCleEmi + ttAppelDeFondRepCle.dMontantAppel.
            end.
            /*--> Montant à repartir */
            assign
                vdMtCleRep  = ttRepartitionCle.dMontantCle - vdMtCleEmi
                vdMtRepUse  = vdMtCleRep / (viNoDerApp - piNoPreApp + 1)
                /*--> On parcourt les appels non emis */
                vdTotRepUse = 0
            .
boucle:
            do viI = piNoPreApp to viNoDerApp:
                find first ttAppelDeFond
                    where ttAppelDeFond.iNumeroAppel = viI no-error.
                if available ttAppelDeFond /** 0508/0072 AND TbTmpDat.fgemi = TRUE  **/
                and ((ttAppelDeFond.lFlagEmis = false and ttAppelDeFond.cModeTraitement <> "M")
                  or (ttAppelDeFond.lFlagEmis = true  and ttAppelDeFond.cModeTraitement = "M"
                         /*gga and ttAppelDeFond.fgrepdef = true ce champ ne semble jamais initialise */
                      ) ) then next boucle.
                /*--> Creation / modification de la repartition */
                find first ttAppelDeFondRepCle
                    where ttAppelDeFondRepCle.iNumeroIdentifiant = piNoIdtUse
                      and ttAppelDeFondRepCle.iNumeroAppel       = viI
                      and ttAppelDeFondRepCle.cCodeCle           = ttRepartitionCle.cCodeCle no-error.
                if not available ttAppelDeFondRepCle
                then do:
                    create ttAppelDeFondRepCle.
                    assign
                        ttAppelDeFondRepCle.iNumeroIdentifiant = piNoIdtUse
                        ttAppelDeFondRepCle.iNumeroAppel       = viI
                        ttAppelDeFondRepCle.cCodeCle           = ttRepartitionCle.cCodeCle
                        ttAppelDeFondRepCle.CRUD               = 'C'
                    .
                end.
                vcLbTmpPdt = LBAPP(ttEnteteAppelDeFond.cCodeFournisseur, ttEnteteAppelDeFond.cLibelleIntervention, ttDossierTravaux.cCodeTypeMandat).
                do viJ = 1 to 9:
                    ttAppelDeFondRepCle.cLibelleAppel[viJ] = entry(viJ, vcLbTmpPdt, SEPAR[1]).
                end.
                if viI < viNoDerApp
                then assign
                    /*ttAppelDeFondRepCle.MtApp = TRUNCATE(vdMtRepUse,2).*/ /**Modif OF le 22/08/11**/
                    ttAppelDeFondRepCle.dMontantAppel = truncate(if pcLbEchEnt > "" then vdMtCleRep * decimal(entry(viI, pcLbEchEnt)) / 100 else vdMtRepUse, 2)
                    vdTotRepUse                       = vdTotRepUse + ttAppelDeFondRepCle.dMontantAppel
                .
                else ttAppelDeFondRepCle.dMontantAppel = vdMtCleRep - vdTotRepUse /** 0508/0072 (TRUNCATE(vdMtRepUse,2) * (viNoDerApp - piNoPreApp)) **/.
            end.
        end.
        /*--> Cumul des appels */
        for each ttAppelDeFond
            where ttAppelDeFond.iNumeroIdentifiant = piNoIdtUse:
            vdMtTotApp = 0.
            for each ttAppelDeFondRepCle
                where ttAppelDeFondRepCle.iNumeroIdentifiant = piNoIdtUse
                  and ttAppelDeFondRepCle.iNumeroAppel = ttAppelDeFond.iNumeroAppel:
                vdMtTotApp = vdMtTotApp + ttAppelDeFondRepCle.dMontantAppel.
                /*--> Suppression des appels à 0 */
                if ttAppelDeFondRepCle.dMontantAppel = 0 then delete ttAppelDeFondRepCle.
            end.
            if ttDossierTravaux.cCodeTypeMandat <> {&TYPECONTRAT-mandat2Gerance} or ttAppelDeFond.lFlagEmis = false
            then ttAppelDeFond.dMontantAppel = vdMtTotApp.

            vdMtTotEnt = vdMtTotEnt + vdMtTotApp.
            /*--> Suppression des appels sans répartitions */
            if ttDossierTravaux.cCodeTypeMandat <> {&TYPECONTRAT-mandat2Gerance}
            and not can-find(first ttAppelDeFondRepCle             /**Ajout du test par OF le 13/09/11**/
                             where ttAppelDeFondRepCle.iNumeroIdentifiant = piNoIdtUse
                               and ttAppelDeFondRepCle.iNumeroAppel = ttAppelDeFond.iNumeroAppel)
            then delete ttAppelDeFond.
        end.

        /*--> Recalcul du nombre d'appel de fond */
        find first ttAppelDeFond
            where ttAppelDeFond.iNumeroIdentifiant = piNoIdtUse no-error.
        viCpUseInc = if available ttAppelDeFond then ttAppelDeFond.iNumeroAppel else 0.
        find last ttAppelDeFond
            where ttAppelDeFond.iNumeroIdentifiant = piNoIdtUse no-error.
        assign
            viCpUseInc                        = if available ttAppelDeFond then (ttAppelDeFond.iNumeroAppel - viCpUseInc + 1) else 0
            ttEnteteAppelDeFond.iNombreAppel  = viCpUseInc
            /*--> Calcul de l'écart sur l'entete */
            ttEnteteAppelDeFond.dMontantEcart = ttEnteteAppelDeFond.dMontantAppel - vdMtTotEnt
        .
        /*--> Suppression de l'entete si aucune répartition */
        find first ttAppelDeFond
            where ttAppelDeFond.iNumeroIdentifiant = piNoIdtUse no-error.
        if not available ttAppelDeFond then delete ttEnteteAppelDeFond.
    end. /* if pcTpSurUse = "00001" */

    /*--REPARTITION PAR MATRICULE----------------------------------------------------------------------------------------------*/
    else do:
        /*--> Repartion des appels */
        for each ttRepartitionCopro:
            assign
                vdMtCleEmi = 0
                vdMtCleRep = 0
            .
            /*--> Cumul des appels déjà emis */
            for each ttAppelDeFond
                where ttAppelDeFond.iNumeroIdentifiant = piNoIdtUse
                  and ttAppelDeFond.lFlagEmis
              , first ttAppelDeFondRepMat
                where ttAppelDeFondRepMat.iNumeroIdentifiant = piNoIdtUse
                  and ttAppelDeFondRepMat.iNumeroAppel = ttAppelDeFond.iNumeroAppel
                  and ttAppelDeFondRepMat.iNumeroCopro = ttRepartitionCopro.iNumeroCopro
                  and ttAppelDeFondRepMat.iNumeroLot = ttRepartitionCopro.iNumeroLot:
                vdMtCleEmi = vdMtCleEmi + ttAppelDeFondRepMat.dMontantAppel.
            end.
            /*--> Montant à repartir */
            assign
                vdMtCleRep  = ttRepartitionCopro.dMontantCopro - vdMtCleEmi
                vdMtRepUse  = vdMtCleRep / (viNoDerApp - piNoPreApp + 1)
                vdTotRepUse = 0
            .
            /*--> On parcourt les appels non emis */
boucle:
            do viI = piNoPreApp to viNoDerApp:
                find first ttAppelDeFond
                    where ttAppelDeFond.iNumeroAppel = viI no-error.
                if available ttAppelDeFond                  /** 0508/0072 AND TbTmpDat.fgemi = TRUE  **/
                and ( (ttAppelDeFond.lFlagEmis = false and ttAppelDeFond.cModeTraitement <> "M")
                   or (ttAppelDeFond.lFlagEmis = true  and ttAppelDeFond.cModeTraitement = "M"
                         /*gga and ttAppelDeFond.fgrepdef = true ce champ ne semble jamais initialise */
                      )) then next boucle.

                /*--> Creation / modification de la repartition */
                find first ttAppelDeFondRepMat
                    where ttAppelDeFondRepMat.iNumeroIdentifiant = piNoIdtUse
                      and ttAppelDeFondRepMat.iNumeroAppel       = viI
                      and ttAppelDeFondRepMat.iNumeroCopro       = ttRepartitionCopro.iNumeroCopro
                      and ttAppelDeFondRepMat.iNumeroLot         = ttRepartitionCopro.iNumeroLot no-error.
                if not available ttAppelDeFondRepMat
                then do:
                    create ttAppelDeFondRepMat.
                    assign
                        ttAppelDeFondRepMat.iNumeroIdentifiant = piNoIdtUse
                        ttAppelDeFondRepMat.iNumeroAppel       = viI
                        ttAppelDeFondRepMat.iNumeroCopro       = ttRepartitionCopro.iNumeroCopro
                        ttAppelDeFondRepMat.iNumeroLot         = ttRepartitionCopro.iNumeroLot
                        ttAppelDeFondRepMat.CRUD               = 'C'
                    .
                end.
                assign
                    ttAppelDeFondRepMat.cNomCopro = outilFormatage:getNomTiers("000008", ttRepartitionCopro.iNumeroCopro)
                    vcLbTmpPdt                    = LBAPP(ttEnteteAppelDeFond.cCodeFournisseur,
                                                          ttEnteteAppelDeFond.cLibelleIntervention,
                                                          ttDossierTravaux.cCodeTypeMandat).
                do viJ = 1 to 9:
                    ttAppelDeFondRepMat.cLibelleAppel[viJ] = entry(viJ, vcLbTmpPdt, SEPAR[1]).
                end.
                if viI < viNoDerApp
                then assign
                    ttAppelDeFondRepMat.dMontantAppel = truncate(if pcLbEchEnt > "" then vdMtCleRep * decimal(entry(viI, pcLbEchEnt)) / 100 else vdMtRepUse, 2)
                    vdTotRepUse                       = vdTotRepUse + ttAppelDeFondRepMat.dMontantAppel
                .
                else ttAppelDeFondRepMat.dMontantAppel = vdMtCleRep - vdTotRepUse.
            end.
        end.

        /*--> Cumul des appels */
        for each ttAppelDeFond
            where ttAppelDeFond.iNumeroIdentifiant = piNoIdtUse:
            vdMtTotApp = 0.
            for each ttAppelDeFondRepMat
                where ttAppelDeFondRepMat.iNumeroIdentifiant = piNoIdtUse
                  and ttAppelDeFondRepMat.iNumeroAppel = ttAppelDeFond.iNumeroAppel:
                vdMtTotApp = vdMtTotApp + ttAppelDeFondRepMat.dMontantAppel.
                /*--> Suppression des appels à 0 */
                if ttAppelDeFondRepMat.dMontantAppel = 0 then delete ttAppelDeFondRepMat.
            end.
            assign
                ttAppelDeFond.dMontantAppel = vdMtTotApp
                vdMtTotEnt                  = vdMtTotEnt + vdMtTotApp
            .
            /*--> Suppression des appels sans répartitions */
            find first ttAppelDeFondRepMat
                where ttAppelDeFondRepMat.iNumeroIdentifiant = piNoIdtUse
                  and ttAppelDeFondRepMat.iNumeroAppel = ttAppelDeFond.iNumeroAppel no-error.
            if not available ttAppelDeFondRepMat then delete ttAppelDeFond.
        end.
        /*--> Calcul de l'écart sur l'entete */
        ttEnteteAppelDeFond.dMontantEcart = ttEnteteAppelDeFond.dMontantAppel - vdMtTotEnt.
        /*--> Suppression de l'entete si aucune répartition */
        find first ttAppelDeFondRepMat
            where ttAppelDeFondRepMat.iNumeroIdentifiant = piNoIdtUse no-error.
        if not available ttAppelDeFondRepMat then delete ttEnteteAppelDeFond.
    end. /* else do: */

    /** 0508/0072 **/
    if available ttEnteteAppelDeFond and ttEnteteAppelDeFond.lbcom = "E"
    then for each ttAppelDeFond
        where ttAppelDeFond.iNumeroIdentifiant = ttEnteteAppelDeFond.iNumeroIdentifiant:
        assign
            ttAppelDeFond.lFlagEmis       = true
            ttAppelDeFond.cModeTraitement = "M"
            ttAppelDeFond.cCodeTraitement = "M"
        .
    end.

end procedure.

procedure CalAppHonoExterne:
    /*------------------------------------------------------------------------------
    Purpose: procedure pour gerer appel procedure CalAppHono depuis autre programme
    Notes  : Service externe (beAppelDeFond.cls)
    ------------------------------------------------------------------------------*/
    define input-output parameter table for ttDossierTravaux.
    define input-output parameter table for ttEnteteAppelDeFond.
    define input-output parameter table for ttAppelDeFond.
    define input-output parameter table for ttAppelDeFondRepCle.
    define input-output parameter table for ttAppelDeFondRepMat.
    define input-output parameter table for ttInfoSaisieAppelDeFond.
    define input-output parameter table for ttRepartitionCle.
    define input-output parameter table for ttRepartitionCopro.
    define input-output parameter table for ttDossierAppelDeFond.

    find first ttDossierTravaux no-error.
    if not available ttDossierTravaux
    then do:
        mError:createError({&information}, 4000011).
        return.
    end.
    run calAppHono(buffer ttDossierTravaux).

end procedure.

procedure calAppHono private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttDossierTravaux for ttDossierTravaux.

    define variable vcCdSenUse    as character    no-undo.
    define variable viNoIdtUse    as integer      no-undo.
    define variable viNbAppUse    as integer      no-undo.
    define variable viNoPreApp    as integer      no-undo.
    define variable vdMtTotCle    as decimal      no-undo.
    define variable vdMtAppUse    as decimal      no-undo.
    define variable vdMtRepUse    as decimal      no-undo.
    define variable vdMtCleUSe    as decimal      no-undo.
    define variable viCdTvaUse    as integer      no-undo.
    define variable vcLbTvaUse    as character    no-undo.
    define variable vdMtTvaUse    as decimal      no-undo.
    define variable viNoHon       as integer      no-undo.

    define buffer trdos for trdos.

    viNoHon = 0.
    find first ttDossierAppelDeFond no-error.
    if not available ttDossierAppelDeFond
    then do:
        mError:createError({&information}, 4000022).    // Table ttDossierAppelDeFond inexistante
        return.
    end.
    viNoHon = ttDossierAppelDeFond.iBarHon.

    if ttDossierAppelDeFond.CRUD = "U"
    then do:
        ttDossierAppelDeFond.CRUD = "R".
        find first trdos no-lock
            where trdos.tpcon = ttDossierTravaux.cCodeTypeMandat
              and trdos.nocon = ttDossierTravaux.iNumeroMandat
              and trdos.nodos = ttDossierTravaux.iNumeroDossierTravaux no-error.
        if not available trdos then return.                 /* todo normalement impossible mais voir pour msg erreur */

        if viNoHon <> trdos.nohon
        then do:
            find first trdos exclusive-lock
                where trdos.tpcon = ttDossierTravaux.cCodeTypeMandat
                  and trdos.nocon = ttDossierTravaux.iNumeroMandat
                  and trdos.nodos = ttDossierTravaux.iNumeroDossierTravaux no-wait no-error.
            if outils:isUpdated(buffer trdos:handle
                              , 'dossier travaux '
                              , substitute('type mandat: &1, mandat: &2, dossier: &3', ttDossierTravaux.cCodeTypeMandat, ttDossierTravaux.iNumeroMandat, ttDossierTravaux.iNumeroDossierTravaux)
                              , ttDossierAppelDeFond.dtTimestamp) then return.

            assign
                trdos.cdmsy = mToken:cUser
                trdos.dtmsy = today
                trdos.Hemsy = mtime
                ttDossierAppelDeFond.dtTimestamp = datetime(trdos.dtmsy, trdos.hemsy)
                trdos.nohon = viNoHon
            .
       end.
    end.
    if viNoHon = 0 then return.

/*--REPARTITION PAR CLE----------   ------------------------------------------------------------------------------------------*/
    /*--> Creation ou modification appel de fond honoraires sur repartition par clé */
    find first ttEnteteAppelDeFond
        where ttEnteteAppelDeFond.cCodeTypeAppel = {&TYPEAPPEL2FONDS-honoraire}
          and ttEnteteAppelDeFond.cCodeTypeAppelSur = "00001" no-error.     /*todo crer code + parametre pour la combo */
    if available ttEnteteAppelDeFond
    then do:
        assign
            viNoIdtUse = ttEnteteAppelDeFond.iNumeroIdentifiant
            vcCdSenUse = "MAJENT"
            viNoPreApp = 1
        .
        for first ttAppelDeFond
            where ttAppelDeFond.iNumeroIdentifiant = ttEnteteAppelDeFond.iNumeroIdentifiant:
            viNoPreApp = ttAppelDeFond.iNumeroAppel.
        end.
    end.
    else do:
        assign
            viNoIdtUse = 0
            vcCdSenUse = "NEWENT"
            viNoPreApp = 1
        .
        find first ttAppelDeFond
            where not ttAppelDeFond.lFlagEmis no-error.
        if available ttAppelDeFond
        then viNoPreApp = ttAppelDeFond.iNumeroAppel.
        else for last ttAppelDeFond
            where ttAppelDeFond.lFlagEmis:
            viNoPreApp = ttAppelDeFond.iNumeroAppel + 1.
        end.
    end.

    /*--> Honoraire sur repartition par clé */
    empty temp-table ttRepartitionCle.
    vdMtTotCle = 0.
    for each ttEnteteAppelDeFond
        where ttEnteteAppelDeFond.cCodeTypeAppel <> {&TYPEAPPEL2FONDS-honoraire}
          and ttEnteteAppelDeFond.cCodeTypeAppel <> {&TYPEAPPEL2FONDS-emprunt}
          and ttEnteteAppelDeFond.cCodeTypeAppel <> {&TYPEAPPEL2FONDS-subvention}
          and ttEnteteAppelDeFond.cCodeTypeAppel <> {&TYPEAPPEL2FONDS-indemniteAssurance}
          and ttEnteteAppelDeFond.cCodeTypeAppelSur = "00001"  /* todo creer code */
      , each ttAppelDeFondRepCle
        where ttAppelDeFondRepCle.iNumeroIdentifiant = ttEnteteAppelDeFond.iNumeroIdentifiant
        break by ttAppelDeFondRepCle.cCodeCle:

        if first-of(ttAppelDeFondRepCle.cCodeCle) then vdMtRepUse = 0.

        vdMtRepUse = vdMtRepUse + ttAppelDeFondRepCle.dMontantAppel.

        if last-of(ttAppelDeFondRepCle.cCodeCle)
        then do:
            find first ttRepartitionCle
                where ttRepartitionCle.cCodeCle = ttAppelDeFondRepCle.cCodeCle no-error.
            if not available ttRepartitionCle
            then do:
                create ttRepartitionCle.
                ttRepartitionCle.cCodeCle = ttAppelDeFondRepCle.cCodeCle.
            end.
            assign
                ttRepartitionCle.dMontantCle = ttRepartitionCle.dMontantCle + vdMtRepUse
                vdMtTotCle                   = vdMtTotCle + vdMtRepUse
            .
        end.
    end.

    /*--> Calcul du montant total d'honoraires */
    run calHono("00001", viNoHon, output vdMtAppUse, output viCdTvaUse, output vcLbTvaUse).
    assign
        vdMtTvaUse = round(vdMtAppUse * decimal(vcLbTvaUse) / 100, 2)
        vdMtAppUse = vdMtAppUse + vdMtTvaUse
        /*--> Repartition par clé du montant d'honoraires */
        vdMtRepUse = 0
    .
    for each ttRepartitionCle
        break by ttRepartitionCle.cCodeCle:
        if last(ttRepartitionCle.cCodeCle)
        then vdMtCleUSe = vdMtAppUse - vdMtRepUse.
        else assign
            vdMtCleUSe = round(vdMtAppUse * ttRepartitionCle.dMontantCle / vdMtTotCle, 2)
            vdMtRepUse = vdMtRepUse + vdMtCleUSe
        .
        ttRepartitionCle.dMontantCle = vdMtCleUSe.
    end.

    /*--> Nombre d'appel de fond */
    viNbAppUse = 1.
    for last ttAppelDeFond /** JEJE **/
        where ttAppelDeFond.cCodeTraitement <> "M":
        viNbAppUse = ttAppelDeFond.iNumeroAppel - viNoPreApp + 1.
        if ttAppelDeFond.lFlagEmis then viNbAppUse = viNbAppUse + 1.
    end.
    if viNbAppUse < 1 then viNbAppUse = 1.

    /*--> Creation / Modification de l'appel de fond honoraire */
    run validDetailAppel-03(
        vcCdSenUse,                   /*- Creation / Modification -*/
        viNoIdtUse,                   /*- Identifiant entete      -*/
        {&TYPEAPPEL2FONDS-honoraire}, /*- Type Appel = Honoraire  -*/
        "00001",                      /*- Répartition = Imm       -*/
        0,                            /*- N° Entete = aucune      -*/
        0,                            /*- N° fournisseur = aucun  -*/
        "Honoraire",                  /*- libelle Type d'Appel    -*/
        "Imm",                        /*- Libelle Imm/Matricule   -*/
        "Cabinet",                    /*- Libelle fournisseur     -*/
        "Honoraires Cabinet",         /*- Libelle appel           -*/
        viNbAppUse,                   /*- Nombre d'appel de fond  -*/
        vdMtAppUse,                   /*- Montant de l'appel      -*/
        viCdTvaUse,                   /*- Code TVA                -*/
        vcLbTvaUse,                   /*- Libelle TVA             -*/
        vdMtTvaUse,                   /*- Montant TVA             -*/
        0,                            /*- Montant Ecart           -*/
        viNoPreApp,                   /*- N° du 1er appel         -*/
        "",                           /*- Collectif-sans objet ici-*/
        "",                           /*- Type de l'entête de l'appel-*/
        "",                           /*- Liste des échéances en %-*/
        buffer ttDossierTravaux
     ).

/*--REPARTITION AU MATRICULE-----------------------------------------------------------------------------------------------*/
    /*--> Creation ou modification appel de fond honoraires sur repartition par clé */
    find first ttEnteteAppelDeFond
        where ttEnteteAppelDeFond.cCodeTypeAppel = {&TYPEAPPEL2FONDS-honoraire}
          and ttEnteteAppelDeFond.cCodeTypeAppelSur = "00002" no-error.    /*todo creer code */
    if available ttEnteteAppelDeFond
    then do:
        assign
            viNoIdtUse = ttEnteteAppelDeFond.iNumeroIdentifiant
            vcCdSenUse = "MAJENT"
            viNoPreApp = 1
        .
        for first ttAppelDeFond
            where ttAppelDeFond.iNumeroIdentifiant = ttEnteteAppelDeFond.iNumeroIdentifiant:
            viNoPreApp = ttAppelDeFond.iNumeroAppel.
        end.
    end.
    else do:
        assign
            viNoIdtUse = 0
            vcCdSenUse = "NEWENT"
        .
        find first ttAppelDeFond
            where not ttAppelDeFond.lFlagEmis no-error.
        if available ttAppelDeFond
        then viNoPreApp = ttAppelDeFond.iNumeroAppel.
        else do:
            find last ttAppelDeFond where ttAppelDeFond.lFlagEmis no-error.
            viNoPreApp = if available ttAppelDeFond then (ttAppelDeFond.iNumeroAppel + 1) else 1.
        end.
    end.

    /*--> Honoraire sur repartition par clé */
    empty temp-table ttRepartitionCopro.
    vdMtTotCle = 0.
    for each ttEnteteAppelDeFond
        where ttEnteteAppelDeFond.cCodeTypeAppel <> {&TYPEAPPEL2FONDS-honoraire}
          and ttEnteteAppelDeFond.cCodeTypeAppel <> {&TYPEAPPEL2FONDS-emprunt}
          and ttEnteteAppelDeFond.cCodeTypeAppel <> {&TYPEAPPEL2FONDS-subvention}
          and ttEnteteAppelDeFond.cCodeTypeAppel <> {&TYPEAPPEL2FONDS-indemniteAssurance}
          and ttEnteteAppelDeFond.cCodeTypeAppelSur = "00002"   /*todo creer code */
      , each ttAppelDeFondRepMat
        where ttAppelDeFondRepMat.iNumeroIdentifiant = ttEnteteAppelDeFond.iNumeroIdentifiant
        break by ttAppelDeFondRepMat.iNumeroCopro
              by ttAppelDeFondRepMat.iNumeroLot:

        if first-of(ttAppelDeFondRepMat.iNumeroLot) then vdMtRepUse = 0.

        vdMtRepUse = vdMtRepUse + ttAppelDeFondRepMat.dMontantAppel.

        if last-of(ttAppelDeFondRepMat.iNumeroLot)
        then do:
            find first ttRepartitionCopro
                where ttRepartitionCopro.iNumeroCopro = ttAppelDeFondRepMat.iNumeroCopro
                and ttRepartitionCopro.iNumeroLot = ttAppelDeFondRepMat.iNumeroLot no-error.
            if not available ttRepartitionCopro
            then do:
                create ttRepartitionCopro.
                assign
                    ttRepartitionCopro.iNumeroCopro = ttAppelDeFondRepMat.iNumeroCopro
                    ttRepartitionCopro.iNumeroLot   = ttAppelDeFondRepMat.iNumeroLot
                .
            end.
            assign
                ttRepartitionCopro.dMontantCopro = ttRepartitionCopro.dMontantCopro + vdMtRepUse
                vdMtTotCle                       = vdMtTotCle + vdMtRepUse
            .
        end.
    end.

    /*--> Calcul du montant total d'honoraires */
    run calHono("00002", viNoHon, output vdMtAppUse, output viCdTvaUse, output vcLbTvaUse).
    assign
        vdMtTvaUse = round(vdMtAppUse * decimal(vcLbTvaUse) / 100, 2)
        vdMtAppUse = vdMtAppUse + vdMtTvaUse
        /*--> Repartition par clé du montant d'honoraires */
        vdMtRepUse = 0
    .
    for each ttRepartitionCopro
        break by ttRepartitionCopro.iNumeroCopro
              by ttRepartitionCopro.iNumeroLot:
        if last(ttRepartitionCopro.iNumeroLot)
        then vdMtCleUSe = vdMtAppUse - vdMtRepUse.
        else assign
            vdMtCleUSe = round(vdMtAppUse * ttRepartitionCopro.dMontantCopro / vdMtTotCle, 2)
            vdMtRepUse = vdMtRepUse + vdMtCleUSe
        .
        ttRepartitionCopro.dMontantCopro = vdMtCleUSe.
    end.

    /*--> Nombre d'appel de fond */
    viNbAppUse = 1.
    for last ttAppelDeFond:
        viNbAppUse = ttAppelDeFond.iNumeroAppel - viNoPreApp + 1.
        if ttAppelDeFond.lFlagEmis then viNbAppUse = viNbAppUse + 1.
    end.
    if viNbAppUse < 1 then viNbAppUse = 1.

    /*--> Creation / Modification de l'appel de fond honoraire */
    run validDetailAppel-03(
        vcCdSenUse,                   /*- Creation / Modification -*/
        viNoIdtUse,                   /*- Identifiant entete      -*/
        {&TYPEAPPEL2FONDS-honoraire}, /*- Type Appel = Honoraire  -*/
        "00002",                      /*- Répartition = Imm       -*/
        0,                            /*- N° Entete = aucune      -*/
        0,                            /*- N° fournisseur = aucun  -*/
        "Honoraire",                  /*- libelle Type d'Appel    -*/
        "Imm",                        /*- Libelle Imm/Matricule   -*/
        "Cabinet",                    /*- Libelle fournisseur     -*/
        "Honoraires Cabinet",         /*- Libelle appel           -*/
        viNbAppUse,                   /*- Nombre d'appel de fond  -*/
        vdMtAppUse,                   /*- Montant de l'appel      -*/
        viCdTvaUse,                   /*- Code TVA                -*/
        vcLbTvaUse,                   /*- Libelle TVA             -*/
        vdMtTvaUse,                   /*- Montant TVA             -*/
        0,                            /*- Montant Ecart           -*/
        viNoPreApp,                   /*- N° du 1er appel         -*/
        "",                           /*- Collectif-sans objet ici-*/
        "",                           /*- Type de l'entête de l'appel-*/
        "",                           /*- Liste des échéances en %-*/
        buffer ttDossierTravaux
    ).
    run calculdossier.     /*--> Calcul sur le dossier */

end procedure.

procedure calHono private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcTpAppUse as character no-undo.
    define input  parameter piNoHon    as integer   no-undo.
    define output parameter pdMtTotHon as decimal   no-undo.
    define output parameter piCdTvaUSe as integer   no-undo.
    define output parameter pcLbTvaUse as character no-undo.

    define variable vdMtTotTtc as decimal no-undo.
    define variable vdMtTotHht as decimal no-undo.
    define variable vdMtTotTvx as decimal no-undo. /**Ajout OF le 26/02/13**/
    define variable vdMtBasUse as decimal no-undo.
    define variable vhProcTva  as handle  no-undo.

    define buffer honor for honor.
    define buffer trhon for trhon.

    for each ttEnteteAppelDeFond
        where ttEnteteAppelDeFond.cCodeTypeAppel <> {&TYPEAPPEL2FONDS-honoraire}
          and ttEnteteAppelDeFond.cCodeTypeAppel <> {&TYPEAPPEL2FONDS-emprunt}
          and ttEnteteAppelDeFond.cCodeTypeAppel <> {&TYPEAPPEL2FONDS-subvention}
          and ttEnteteAppelDeFond.cCodeTypeAppel <> {&TYPEAPPEL2FONDS-indemniteAssurance}
          and ttEnteteAppelDeFond.cCodeTypeAppelSur = pcTpAppUse:
        assign
            vdMtTotTtc = vdMtTotTtc + ttEnteteAppelDeFond.dMontantAppel
            vdMtTotHht = vdMtTotHht + (ttEnteteAppelDeFond.dMontantAppel - ttEnteteAppelDeFond.dMontantTva)
        .
        if ttEnteteAppelDeFond.cCodeTypeAppel = {&TYPEAPPEL2FONDS-travaux}
        then vdMtTotTvx = vdMtTotTvx + (ttEnteteAppelDeFond.dMontantAppel - ttEnteteAppelDeFond.dMontantTva). /**Ajout OF le 26/02/13**/
    end.

    for first honor no-lock
        where honor.nohon = piNoHon:
        case honor.bshon:
            when {&baseHonoraire-ttc} then vdMtBasUse = vdMtTotTtc.
            when {&baseHonoraire-hht} then vdMtBasUse = vdMtTotHht.
            when {&baseHonoraire-tvx} then vdMtBasUse = vdMtTotTvx. /**Ajout OF le 26/02/13**/
            otherwise         vdMtBasUse = vdMtTotHht.
        end case.
        case honor.cdtva:
            when {&codeTVA-5}  then piCdTvaUSe = 5.
            when {&codeTVA-1}  then piCdTvaUSe = 1.
            when {&codeTVA-6}  then piCdTvaUSe = 6.
            when {&codeTVA-8}  then piCdTvaUSe = 8.
            when {&codeTVA-7}  then piCdTvaUSe = 7.     /* Ajout SY le 06/12/2011 TVA 7% */
            when {&codeTVA-20} then piCdTvaUSe = 20.    /* TVA 20% */   /* SY 1013/0167 */
            when {&codeTVA-10} then piCdTvaUSe = 10.    /* TVA 10% */   /* SY 1013/0167 */
            otherwise          piCdTvaUSe = 0.
        end case.

        /*gga todo a revoir
        pcLbTvaUse = LBTVA(piCdTvaUSe).
        gga*/

        run compta/outilsTVA.p persistent set vhProcTva.
        run getTokenInstance in vhProcTva(mToken:JSessionId).
        pcLbTvaUse = dynamic-function("getTauxTva" in vhProcTva, piCdTvaUSe).
        run destroy in vhProcTva.

        for each trhon no-lock
            where trhon.tphon = honor.tphon
              and trhon.nohon = honor.cdhon
              and trhon.vlmin <= vdMtBasUse
            by trhon.vlmin:
            case honor.nthon:
                /*--> Honoraire au forfait */
                when {&NATUREHONORAIRE-forfaitaire} then pdMtTotHon = pdMtTotHon + trhon.mttrc.
                /*--> Honoraire au taux */
                when {&NATUREHONORAIRE-taux} then pdMtTotHon = pdMtTotHon + ((minimum(trhon.vlmax, vdMtBasUse) - trhon.vlmin) * trhon.mttrc / 100).
            end case.
        end.
    end.
    pdMtTotHon = round(pdMtTotHon, 2).

end procedure.

procedure creationttDossierAppelDeFond private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as collection no-undo.

    define variable vcTypeMandat     as character no-undo.
    define variable viNumeroMandat   as int64     no-undo.
    define variable viDossierTravaux as integer   no-undo.

    define buffer trdos for trdos.

    empty temp-table ttDossierAppelDeFond.
    assign
        vcTypeMandat     = poCollection:getCharacter("cTypeMandat")
        viNumeroMandat   = poCollection:getInteger("iNumeroMandat")
        viDossierTravaux = poCollection:getInteger("iNumeroDossierTravaux")
    .
    for first trdos no-lock
        where trdos.tpcon = vcTypeMandat
          and trdos.nocon = viNumeroMandat
          and trdos.nodos = viDossierTravaux:
        create ttDossierAppelDeFond.
        assign
            ttDossierAppelDeFond.cPresAppelCod = trdos.cdpre
            ttDossierAppelDeFond.cPresAppelLib = outilTraduction:getLibelleParam("PRTRV", trdos.cdpre)
            ttDossierAppelDeFond.iNbrEchPrel   = trdos.nbech
            ttDossierAppelDeFond.iBarHon       = trdos.nohon
            ttDossierAppelDeFond.lPresAppel    = no
            ttDossierAppelDeFond.CRUD          = 'R'
            ttDossierAppelDeFond.dtTimestamp   = datetime(trdos.dtmsy, trdos.HeMsy)
            ttDossierAppelDeFond.rRowid        = rowid(trdos)
        .
    end.

end procedure.

procedure ValidDossierAppel:
    /*------------------------------------------------------------------------------
    Purpose: correspond a procedure gesdossi.p/Validation pour la partie appel de fond
    Notes  : Service externe (beAppelDeFond.i)
    ------------------------------------------------------------------------------*/
    define input-output parameter table for ttDossierTravaux.
    define input-output parameter table for ttEnteteAppelDeFond.
    define input-output parameter table for ttAppelDeFond.
    define input-output parameter table for ttAppelDeFondRepCle.
    define input-output parameter table for ttAppelDeFondRepMat.
    define input-output parameter table for ttInfoSaisieAppelDeFond.
    define input-output parameter table for ttRepartitionCle.
    define input-output parameter table for ttRepartitionCopro.
    define input-output parameter table for ttDossierAppelDeFond.

    define variable vlRetCtrl as logical no-undo.

message "gga ValidDossierAppel ".

    find first ttDossierTravaux no-error.
    if not available ttDossierTravaux
    then do:
        mError:createError({&information}, 999999).   /*todo creer message enregistrement doit exister*/
        return.
    end.

message "gga ValidDossierAppel parametres "
        " ttDossierTravaux.cCodeTypeMandat " ttDossierTravaux.cCodeTypeMandat
        " ttDossierTravaux.iNumeroMandat " ttDossierTravaux.iNumeroMandat
        " ttDossierTravaux.iNumeroDossierTravaux " ttDossierTravaux.iNumeroDossierTravaux
        " ttDossierTravauxi.NumeroImmeuble " ttDossierTravaux.iNumeroImmeuble.

    run ctrlValidationInfoAppelPrivate(buffer ttDossierTravaux, output vlRetCtrl).
    if not vlRetCtrl then return.

    run validationInfoAppelPrivate(buffer ttDossierTravaux, output vlRetCtrl).
    return.

end procedure.

procedure ctrlValidationInfoAppel:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service appel externe (dossiertravaux.p)
    ------------------------------------------------------------------------------*/
    define parameter buffer ttDossierTravaux for ttDossierTravaux.
    define input        parameter table for ttError.
    define input-output parameter table for ttEnteteAppelDeFond.
    define input-output parameter table for ttAppelDeFond.
    define input-output parameter table for ttAppelDeFondRepCle.
    define input-output parameter table for ttAppelDeFondRepMat.
    define input-output parameter table for ttInfoSaisieAppelDeFond.
    define input-output parameter table for ttRepartitionCle.
    define input-output parameter table for ttRepartitionCopro.
    define input-output parameter table for ttDossierAppelDeFond.
    define output parameter plCtrlOk as logical no-undo.

    run ctrlValidationInfoAppelPrivate(buffer ttDossierTravaux, output plCtrlOk).

end procedure.

procedure ctrlValidationInfoAppelPrivate private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : correspond a gesdossi/CtrlValidation pour la partie appel de fond
    ------------------------------------------------------------------------------*/
    define parameter buffer ttDossierTravaux for ttDossierTravaux.
    define output parameter plCtrlOk as logical no-undo.

    define variable voCollection    as class collection no-undo.
    define variable vhProc          as handle     no-undo.
    define variable vdaAppel        as date       no-undo.
    define variable vdMtAppUse      as decimal    no-undo.
    define variable vlFgAffMsg      as logical    no-undo initial true.
    define variable vdaAppelPourNum as date       no-undo.

    define buffer dosap   for dosap.
    define buffer cecrsai for cecrsai.

message "CtrlValidationInfoAppelPrivate" .

    voCollection = new collection().
    if ttDossierTravaux.cCodeTypeMandat = {&TYPECONTRAT-mandat2Syndic}
    then do:
        /* Validité des dates d'appels */
        /*--> Appels dont le N° est inférieur à 50: Appels GI purs ou Appels GI avec des reprises (manuels) */
        vdaAppel = 01/01/0001.
        for each ttAppelDeFond
            where ttAppelDeFond.iNumeroAppel < 50
            break by ttAppelDeFond.iNumeroAppel:
            if ttAppelDeFond.daDateAppel = ?
            then do:
                mError:createError({&error}, 108046).
                return.
            end.
            /*gga todo a revoir par rapport a gesdossi.p */
            if first-of(ttAppelDeFond.iNumeroAppel)
            then do:
                vdaAppelPourNum = ttAppelDeFond.daDateAppel.
                if vdaAppel >= ttAppelDeFond.daDateAppel
                then do:
                    mError:createError({&error}, 108136).    // suite non logique de date d'appel
                    return.
                end.
            end.
            else if vdaAppelPourNum <> ttAppelDeFond.daDateAppel
            then do:
                mError:createError({&error}, 4000008).    // La date doit etre identique pour 1 appel
                return.
            end.
            if ttDossierTravaux.daDateDebut > ttAppelDeFond.daDateAppel
            then do:
                mError:createError({&error}, 4000007).    // La date de début du Dossier doit être inférieure à vos appels de fonds
                return.
            end.
            vdaAppel = ttAppelDeFond.daDateAppel.
        end.

        /*--> Appels dont le N° est >= à 50: Appels avec des reprises (manuels) uniquement */
        vdaAppel = 01/01/0001.
        for each ttAppelDeFond
            where ttAppelDeFond.iNumeroAppel >= 50
            break by ttAppelDeFond.iNumeroAppel:
            if ttAppelDeFond.daDateAppel = ?
            then do:
                mError:createError({&error}, 108046).
                return.
            end.
            /*gga todo a revoir par rapport a gesdossi.p */
            if first-of(ttAppelDeFond.iNumeroAppel)
            then do:
                vdaAppelPourNum = ttAppelDeFond.daDateAppel.
                if vdaAppel >= ttAppelDeFond.daDateAppel
                then do:
                    mError:createError({&error}, 108136).
                    return.
                end.
            end.
            else if vdaAppelPourNum <> ttAppelDeFond.daDateAppel
            then do:
                mError:createError({&error}, 4000008).
                return.
            end.
            if ttDossierTravaux.daDateDebut > ttAppelDeFond.daDateAppel
            then do:
                mError:createError({&error}, 4000007).
                return.
            end.
            vdaAppel = ttAppelDeFond.daDateAppel.
        end.
        if ttDossierTravaux.iNombreEcheance <= 0 or ttDossierTravaux.iNombreEcheance > 12
        then do:
            mError:createError({&error}, 4000009).       // Le nombre d'échéances doit être compris entre 1 et 12
            return.
        end.
        for first ttEnteteAppelDeFond
            where ttEnteteAppelDeFond.dMontantEcart <> 0:
            mError:createError({&error}, 108117).        // L'ensemble des entetes d'appels ne sont pas reparties
            return.
        end.
        for first ttAppelDeFondRepCle
            where ttAppelDeFondRepCle.dMontantAppel = 0
              and ttAppelDeFondRepCle.iNumeroAppel < 50: // Pour les reprises d'antériorités en migration
            mError:createError({&error}, 108118).        // Il y a des appels de fond à zero
            return.
        end.
        for first ttAppelDeFondRepMat
            where ttAppelDeFondRepMat.dMontantAppel = 0:
            mError:createError({&error}, 108119).
            return.
        end.
        for each ttAppelDeFond:
            if  not can-find(first ttAppelDeFondRepCle
                where ttAppelDeFondRepCle.iNumeroIdentifiant = ttAppelDeFond.iNumeroIdentifiant
                  and ttAppelDeFondRepCle.iNumeroAppel = ttAppelDeFond.iNumeroAppel)
            and not can-find(first ttAppelDeFondRepMat
                where ttAppelDeFondRepMat.iNumeroIdentifiant = ttAppelDeFond.iNumeroIdentifiant
                  and ttAppelDeFondRepMat.iNumeroAppel = ttAppelDeFond.iNumeroAppel)
            then do:
                mError:createError({&error}, 108120).
                return.
            end.
        end.
    end. /* if pcTypeContrat = {&TYPECONTRAT-mandat2Syndic} */
    else if can-find(first ttAppelDeFond) then do:
        run compta/souspgm/cptaprov.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        voCollection:set('cTypeTrait', "MODIF") no-error.
        for each ttAppelDeFond
            break by ttAppelDeFond.iNumeroIdentifiant:
    
            if first-of(ttAppelDeFond.iNumeroIdentifiant) then vdMtAppUse = 0.
    
            /*Si l'échéance a déjà été comptabilisée, on la modifie si elle est n'a pas été transférée (GI ou SCI),
              on annule la modification sinon*/
            for first dosap no-lock
                where dosap.FgEmi = true
                  and dosap.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and dosap.nocon = ttDossierTravaux.iNumeroMandat
                  and dosap.nodos = ttDossierTravaux.iNumeroDossierTravaux
                  and dosap.NoApp = ttAppelDeFond.iNumeroAppel
                  and dosap.mttot <> ttAppelDeFond.dMontantAppel
              , first cecrsai no-lock
                where cecrsai.soc-cd    = integer(entry(2, dosap.lbdiv1, "@"))
                  and cecrsai.etab-cd   = integer(entry(3, dosap.lbdiv1, "@"))
                  and cecrsai.jou-cd    = entry(4, dosap.lbdiv1, "@")
                  and cecrsai.prd-cd    = integer(entry(5, dosap.lbdiv1, "@"))
                  and cecrsai.prd-num   = integer(entry(6, dosap.lbdiv1, "@"))
                  and cecrsai.piece-int = integer(entry(7, dosap.lbdiv1, "@")):
                if cecrsai.dadoss = ? and cecrsai.daaff = ?
                then do:
                    voCollection:set('rRowidPiece', rowid(cecrsai)) no-error.
                    voCollection:set('dMtApp', ttAppelDeFond.dMontantAppel) no-error.
                    run cptaprovMajOdProv in vhProc(voCollection, table ttTmpProv by-reference).  // modifProv, car cTypeTrait = "MODIF"
                end.
                else do:
                    if vlFgAffMsg then mError:createError({&error}, 108131).
                    assign
                        vlFgAffMsg                  = false
                        ttAppelDeFond.dMontantAppel = dosap.mttot /*Modification interdite -> on remet l'ancien montant*/
                    .
                end.
            end.
    
     /*gga une seule table alors find dans for each ?????????????
                find first TbTmpDat
                where ttAppelDeFond.iNumeroAppel = TbTmpApp.NoApp
                no-lock no-error.
                if available TbTmpDat
                then TbTmpDat.mttot = TbTmpApp.MtApp.
                vdMtAppUse = vdMtAppUse + TbTmpApp.MtApp.
    gga*/
            if last-of(ttAppelDeFond.iNumeroIdentifiant)
            then for first ttEnteteAppelDeFond
                where ttEnteteAppelDeFond.iNumeroIdentifiant = ttAppelDeFond.iNumeroIdentifiant:
                assign
                    ttEnteteAppelDeFond.dMontantAppel = vdMtAppUse
                    ttEnteteAppelDeFond.dMontantEcart = 0
                .
            end.
        end.
    end.

    if can-find(first ttAppelDeFond where ttAppelDeFond.cCodeTraitement = "S") then do:
        voCollection:set('cTypeTrait', "SUPPR") no-error.
        if not valid-handle(vhProc) then do:    // déjà lancé dans appel de fond, pas mandat2Syndic
            run compta/souspgm/cptaprov.p persistent set vhProc.
            run getTokenInstance in vhProc(mToken:JSessionId).
        end.
        /*Echéances d'appels de fonds supprimées*/
        for each ttAppelDeFond
            where ttAppelDeFond.cCodeTraitement = "S":
            find first dosap no-lock
                where dosap.FgEmi = true
                  and dosap.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and dosap.nocon = ttDossierTravaux.iNumeroMandat
                  and dosap.nodos = ttDossierTravaux.iNumeroDossierTravaux
                  and dosap.NoApp = ttAppelDeFond.iNumeroAppel no-error.
            if available dosap
            then do:
                find first cecrsai no-lock
                    where cecrsai.soc-cd    = integer(entry(2, dosap.lbdiv1, "@"))
                      and cecrsai.etab-cd   = integer(entry(3, dosap.lbdiv1, "@"))
                      and cecrsai.jou-cd    = entry(4, dosap.lbdiv1, "@")
                      and cecrsai.prd-cd    = integer(entry(5, dosap.lbdiv1, "@"))
                      and cecrsai.prd-num   = integer(entry(6, dosap.lbdiv1, "@"))
                      and cecrsai.piece-int = integer(entry(7, dosap.lbdiv1, "@")) no-error.
                if available cecrsai then do:
                    voCollection:set('rRowidPiece', rowid(cecrsai)) no-error.
                    run cptaprovMajOdProv in vhProc (voCollection, table ttTmpProv by-reference).   // delProv, car cTypeTrait = "SUPPR"
                end.
                delete ttAppelDeFond.
            end.
        end.
    end.
    if valid-handle(vhProc) then run destroy in vhProc.
    plCtrlOk = yes.

end procedure.

procedure validationInfoAppel:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service appel externe (dossiertravaux.p)
    ------------------------------------------------------------------------------*/
    define parameter buffer ttDossierTravaux for ttDossierTravaux.
    define input-output parameter table for ttEnteteAppelDeFond.
    define input-output parameter table for ttAppelDeFond.
    define input-output parameter table for ttAppelDeFondRepCle.
    define input-output parameter table for ttAppelDeFondRepMat.
    define input-output parameter table for ttInfoSaisieAppelDeFond.
    define input-output parameter table for ttRepartitionCle.
    define input-output parameter table for ttRepartitionCopro.
    define input-output parameter table for ttDossierAppelDeFond.
    define input-output parameter table for ttError.
    define output parameter plValidOk as logical no-undo.

    run validationInfoAppelPrivate (buffer ttDossierTravaux, output plValidOk).

end procedure.

procedure validationInfoAppelPrivate private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : correspond a gesdossi/CtrlValidation pour la partie appel de fond
    ------------------------------------------------------------------------------*/
    define parameter buffer ttDossierTravaux for ttDossierTravaux.
    define output parameter plValidOk as logical no-undo.

    define variable vlErreur   as logical   no-undo.

message "gga validationInfoAppelPrivate parametres "
        " ttDossierTravaux.cCodeTypeMandat " ttDossierTravaux.cCodeTypeMandat
        " ttDossierTravaux.iNumeroMandat " ttDossierTravaux.iNumeroMandat
        " ttDossierTravaux.iNumeroDossierTravaux " ttDossierTravaux.iNumeroDossierTravaux
        " ttDossierTravauxi.NumeroImmeuble " ttDossierTravaux.iNumeroImmeuble.

    run calendrierAppel(buffer ttDossierTravaux, output vlErreur).
    if vlErreur then return.

    run enteteAppelFond(buffer ttDossierTravaux, output vlErreur).
    if vlErreur then return.

    run appelFond(buffer ttDossierTravaux, output vlErreur).
    if vlErreur then return.

    if ttDossierTravaux.cCodeTypeMandat <> {&TYPECONTRAT-mandat2Gerance}
    then do:
        run repartitionCle(buffer ttDossierTravaux, output vlErreur).
        if vlErreur then return.
        run repartitionMatricule(buffer ttDossierTravaux, output vlErreur).
        if vlErreur then return.
    end.
    plValidOk = yes.

end procedure.

procedure calendrierAppel private:
    /*------------------------------------------------------------------------------
    Purpose: CALENDRIER DES APPELS
    Notes: Creation / modification / Suppression
    ------------------------------------------------------------------------------*/
    define parameter buffer ttDossierTravaux for ttDossierTravaux.
    define output parameter plErreur as logical no-undo.

    define variable viNumeroBudget as int64  no-undo.

    define buffer dosap for dosap.
    define buffer apbco for apbco.
    define buffer trfpm for trfpm.
    define buffer trfev for trfev.

    for each ttAppelDeFond:
        find first dosap exclusive-lock
            where dosap.tpcon = ttDossierTravaux.cCodeTypeMandat
              and dosap.nocon = ttDossierTravaux.iNumeroMandat
              and dosap.nodos = ttDossierTravaux.iNumeroDossierTravaux
              and dosap.Noapp = ttAppelDeFond.iNumeroAppel no-error.
        if not available dosap
        then do:
            create Dosap.
            assign
                dosap.tpcon = ttDossierTravaux.cCodeTypeMandat
                dosap.nocon = ttDossierTravaux.iNumeroMandat
                dosap.nodos = ttDossierTravaux.iNumeroDossierTravaux
                dosap.NoApp = ttAppelDeFond.iNumeroAppel
                dosap.cdcsy = mToken:cUser
                dosap.dtcsy = today
                dosap.HeCsy = mtime
            .
        end.
/*gga todo a voir ce qu il faut copier attention 1 table pour 2
            BUFFER-COPY TbTmpDat EXCEPT tpcon nocon nodos TO Dosap. /** 0306/0215 **/
gga*/
        assign
            dosap.DtApp    = ttAppelDeFond.daDateAppel
            dosap.MtTot    = ttAppelDeFond.dMontantTotal
            dosap.cdmsy    = mToken:cUser
            dosap.dtmsy    = today
            dosap.Hemsy    = mtime
            /* Si reprise d'antériorité , Maj apbco */
            viNumeroBudget = ttDossierTravaux.iNumeroMandat * 100000 + ttDossierTravaux.iNumeroDossierTravaux
        .
        /** 0306/0215 **/
        if dosap.fgemi and dosap.ModeTrait = "M"
        then do:
            for each apbco  exclusive-lock
                where apbco.tpbud = {&TYPEBUDGET-travaux}
                  and apbco.nobud = viNumeroBudget
                  and apbco.tpapp = {&TYPEAPPEL-dossierTravaux}
                  and apbco.noapp = dosap.noapp
                  and apbco.nomdt = ttDossierTravaux.iNumeroMandat:
                delete apbco.
            end.
/*gga todo table TbAppDet correspond a quoi ?
            FOR EACH TbAppDet
            WHERE TbAppDet.tpbud = {&TYPEBUDGET-travaux}
            AND   TbAppDet.nobud = NoBudUse
            AND   TbAppDet.tpapp = {&TYPEAPPEL-dossierTravaux}
            AND   TbAppDet.noapp = DosAp.NoApp
            AND   TbAppDet.nomdt = piNumeroContrat:
                CREATE apbco.
                BUFFER-COPY TbAppDet TO apbco.
                ASSIGN
                    apbco.noimm = NoImmUse
                    apbco.dtmsy = TODAY
                    apbco.hemsy = TIME
                    apbco.cdmsy = mToken:cUser
                    .
            END.
gga*/
        end.
    end.

    for each dosap exclusive-lock
        where dosap.tpcon = ttDossierTravaux.cCodeTypeMandat
          and dosap.nocon = ttDossierTravaux.iNumeroMandat
          and dosap.nodos = ttDossierTravaux.iNumeroDossierTravaux
          and not can-find(first ttAppelDeFond where ttAppelDeFond.iNumeroAppel = dosap.NoApp):
        /* Ajout SY le 24/03/2014 Fiche 0314/0147 */
        viNumeroBudget = ttDossierTravaux.iNumeroMandat * 100000 + ttDossierTravaux.iNumeroDossierTravaux.  // int64(string(ttDossierTravaux.iNumeroMandat, "99999") + string(ttDossierTravaux.iNumeroDossierTravaux,"99999")).
        if dosap.fgemi and dosap.ModeTrait = "M"
        then for each apbco exclusive-lock
            where apbco.tpbud = {&TYPEBUDGET-travaux}
              and apbco.nobud = viNumeroBudget
              and apbco.tpapp = {&TYPEAPPEL-dossierTravaux}
              and apbco.noapp = dosap.noapp
              and apbco.nomdt = ttDossierTravaux.iNumeroMandat:
            delete apbco.
        end.
        /* Ajout SY le 29/03/2010 Suppression des traces de transfert */
        for each trfpm exclusive-lock
            where trfpm.tptrf = {&TYPETRANSFERT-appel}
              and trfpm.tpapp = {&TYPEAPPEL-dossierTravaux}
              and trfpm.nomdt = ttDossierTravaux.iNumeroMandat
              and trfpm.noexe = ttDossierTravaux.iNumeroDossierTravaux
              and trfpm.noapp = dosap.noapp:
            delete trfpm.
        end.
        for each trfev exclusive-lock
            where trfev.tptrf = {&TYPETRANSFERT-appel}
              and trfev.tpapp = {&TYPEAPPEL-dossierTravaux}
              and trfev.nomdt = ttDossierTravaux.iNumeroMandat
              and trfev.noexe = ttDossierTravaux.iNumeroDossierTravaux
              and trfev.noapp = dosap.noapp:
            delete trfev.
        end.
        delete dosap.
    end.

end procedure.

procedure enteteAppelFond private:
    /*------------------------------------------------------------------------------
    Purpose: ENTETE APPELS DE FOND
    Notes: Creation / modification / Suppression
    ------------------------------------------------------------------------------*/
    define parameter buffer ttDossierTravaux for ttDossierTravaux.
    define output parameter plErreur as logical no-undo.

    define variable viNumeroDossier as integer   no-undo.

    define buffer doset for doset.
    define buffer dosdt for dosdt.

    /*gga todo ne traiter que les enregistrements avec crud <> r ????? */
    for each ttEnteteAppelDeFond
        where ttEnteteAppelDeFond.iNumeroIdentifiant <> 99999:
        find first doset no-lock
            where doset.NoIdt = ttEnteteAppelDeFond.iNumeroIdentifiant no-error.
        if not available doset
        then do:
            /*--> Recherche du prochaine n° libre */
            {&_proparse_ prolint-nowarn(wholeindex)}
            find last DosEt no-lock no-error.
            viNumeroDossier = if available doset then doset.noidt + 1 else 1.
            create DosEt.
            assign
                doset.NoIdt = viNumeroDossier
                doset.tpcon = ttDossierTravaux.cCodeTypeMandat
                doset.nocon = ttDossierTravaux.iNumeroMandat
                doset.nodos = ttDossierTravaux.iNumeroDossierTravaux
                doset.TpApp = ttEnteteAppelDeFond.cCodeTypeAppel
                doset.sscoll-cle = ttEnteteAppelDeFond.cCodeCollectifFinancement  /* 0306/0215 - coll financement fd rlt/res */
                doset.TpSur = ttEnteteAppelDeFond.cCodeTypeAppelSur
                doset.NoInt = ttEnteteAppelDeFond.iNumeroIntervention
                doset.cdcsy = mToken:cUser
                doset.dtcsy = today
                doset.HeCsy = mtime
            .
            /*--> Mise à jour de l'identifiant */
            for each ttAppelDeFond
                where ttAppelDeFond.iNumeroIdentifiant = ttEnteteAppelDeFond.iNumeroIdentifiant:
                ttAppelDeFond.iNumeroIdentifiant = viNumeroDossier.
            end.
            for each ttAppelDeFondRepCle
                where ttAppelDeFondRepCle.iNumeroIdentifiant = ttEnteteAppelDeFond.iNumeroIdentifiant:
                ttAppelDeFondRepCle.iNumeroIdentifiant = viNumeroDossier.
            end.
            for each ttAppelDeFondRepMat
                where ttAppelDeFondRepMat.iNumeroIdentifiant = ttEnteteAppelDeFond.iNumeroIdentifiant:
                ttAppelDeFondRepMat.iNumeroIdentifiant = viNumeroDossier.
            end.
            ttEnteteAppelDeFond.iNumeroIdentifiant = viNumeroDossier.
        end. /* if not available doset  */
        else do:
            find first doset exclusive-lock
                where doset.NoIdt = ttEnteteAppelDeFond.iNumeroIdentifiant no-wait no-error.
            if outils:isUpdated(buffer doset:handle, 'dossier: ', string(ttEnteteAppelDeFond.iNumeroIdentifiant), ttEnteteAppelDeFond.dtTimestamp)
            then do:
                plErreur = true.
                return.
            end.
            assign
                doset.cdmsy = mToken:cUser
                doset.dtmsy = today
                doset.Hemsy = mtime
                ttEnteteAppelDeFond.dtTimestamp = datetime(doset.dtmsy, doset.hemsy)
            .
        end.
        assign
            doset.NoOrd    = ttEnteteAppelDeFond.iNumeroOrdre
            doset.LbInt[1] = ttEnteteAppelDeFond.cLibelleIntervention
            doset.NoFou    = integer(ttEnteteAppelDeFond.cCodeFournisseur)
            doset.MtNet    = ttEnteteAppelDeFond.dMontantAppel - ttEnteteAppelDeFond.dMontantTva
            doset.CdTva    = ttEnteteAppelDeFond.iCodeTva
            doset.MtTva    = ttEnteteAppelDeFond.dMontantTva
            doset.MtApp    = ttEnteteAppelDeFond.dMontantAppel
            doset.NbApp    = ttEnteteAppelDeFond.iNombreAppel
            doset.lbcom    = ttEnteteAppelDeFond.lbcom
        .
    end. /* for each ttEnteteAppelDeFond   */

    for each doset exclusive-lock
        where doset.tpcon = ttDossierTravaux.cCodeTypeMandat
          and doset.nocon = ttDossierTravaux.iNumeroMandat
          and doset.nodos = ttDossierTravaux.iNumeroDossierTravaux
          and not can-find(first ttEnteteAppelDeFond where ttEnteteAppelDeFond.iNumeroIdentifiant = doset.noidt):
        for each dosdt exclusive-lock
            where dosdt.NoIdt = doset.NoIdt:
            delete dosdt.
        end.
        delete doset.
    end.

end procedure.

procedure appelFond private:
    /*------------------------------------------------------------------------------
    Purpose: APPELS DE FOND
    Notes: Creation / modification / Suppression
    ------------------------------------------------------------------------------*/
    define parameter buffer ttDossierTravaux for ttDossierTravaux.
    define output parameter plErreur as logical no-undo.

    define buffer vbDosdt for dosdt.
    define buffer dosdt   for dosdt.
    define buffer doset   for doset.

    for each ttAppelDeFond
        where ttAppelDeFond.iNumeroIdentifiant <> 99999:
        find first dosdt no-lock
            where dosdt.noIdt = ttAppelDeFond.iNumeroIdentifiant
              and dosdt.noApp = ttAppelDeFond.iNumeroAppel
              and dosdt.cdApp = "" no-error.
        if not available dosdt
        then do:
            create DosDt.
            assign
                dosdt.noIdt = ttAppelDeFond.iNumeroIdentifiant
                dosdt.noApp = ttAppelDeFond.iNumeroAppel
                dosdt.cdcsy = mToken:cUser
                dosdt.dtcsy = today
                dosdt.HeCsy = mtime
            .
        end.
        else do:
            find first dosdt exclusive-lock
                where dosdt.noIdt = ttAppelDeFond.iNumeroIdentifiant
                  and dosdt.noApp = ttAppelDeFond.iNumeroAppel
                  and dosdt.cdApp = "" no-wait no-error.
            if outils:isUpdated(buffer dosdt:handle, 'dossier: ', string(ttAppelDeFond.iNumeroIdentifiant), ttAppelDeFond.dtTimestamp)
            then do:
                plErreur = true.
                return.
            end.
            assign
                dosdt.cdmsy = mToken:cUser
                dosdt.dtmsy = today
                dosdt.Hemsy = mtime
            .
        end.
        assign
            dosdt.LbApp[1] = ttAppelDeFond.cLibelleAppel
            dosdt.MtApp = ttAppelDeFond.dMontantAppel
        .
    end.

    for each doset no-lock
        where doset.tpcon = ttDossierTravaux.cCodeTypeMandat
          and doset.nocon = ttDossierTravaux.iNumeroMandat
          and doset.nodos = ttDossierTravaux.iNumeroDossierTravaux
      , each dosdt exclusive-lock
        where dosdt.NoIdt = doset.NoIdt
          and dosdt.CdApp = ""
          and not can-find(first ttAppelDeFond
                           where ttAppelDeFond.iNumeroIdentifiant = dosdt.noIdt
                             and ttAppelDeFond.iNumeroAppel       = dosdt.noApp):
        for each vbDosdt exclusive-lock
            where vbDosdt.noIdt = dosdt.noIdt
              and vbDosdt.cdApp <> "":
            delete vbDosdt.
        end.
        delete dosdt.
    end.

end procedure.

procedure repartitionCle private:
    /*------------------------------------------------------------------------------
    Purpose: REPARTITION PAR CLE
    Notes: Creation / modification / Suppression
    ------------------------------------------------------------------------------*/
    define parameter buffer ttDossierTravaux for ttDossierTravaux.
    define output parameter plErreur as logical no-undo.

    define buffer dosdt   for dosdt.
    define buffer doset   for doset.

    for each ttAppelDeFondRepCle:
        find first dosdt no-lock
            where DosDt.NoIdt = ttAppelDeFondRepCle.iNumeroIdentifiant
              and dosdt.noApp = ttAppelDeFondRepCle.iNumeroAppel
              and dosdt.cdApp = ttAppelDeFondRepCle.cCodeCle no-error.
        if not available dosdt
        then do:
            create dosdt.
            assign
                dosdt.NoIdt = ttAppelDeFondRepCle.iNumeroIdentifiant
                dosdt.NoApp = ttAppelDeFondRepCle.iNumeroAppel
                dosdt.CdApp = ttAppelDeFondRepCle.cCodeCle
                dosdt.cdcsy = mToken:cUser
                dosdt.dtcsy = today
                dosdt.HeCsy = mtime
            .
        end.
        else do:
            find first dosdt exclusive-lock
                where DosDt.NoIdt = ttAppelDeFondRepCle.iNumeroIdentifiant
                  and dosdt.NoApp = ttAppelDeFondRepCle.iNumeroAppel
                  and dosdt.CdApp = ttAppelDeFondRepCle.cCodeCle no-wait no-error.
            if outils:isUpdated(buffer dosdt:handle, 'dossier: ', string(ttAppelDeFondRepCle.iNumeroIdentifiant), ttAppelDeFondRepCle.dtTimestamp)
            then do:
                plErreur = true.
                return.
            end.
            assign
                dosdt.cdmsy = mToken:cUser
                dosdt.dtmsy = today
                dosdt.Hemsy = mtime
            .
        end.
        assign
            dosdt.LbApp[1] = ttAppelDeFondRepCle.cLibelleAppel[1]
            dosdt.LbApp[2] = ttAppelDeFondRepCle.cLibelleAppel[2]
            dosdt.LbApp[3] = ttAppelDeFondRepCle.cLibelleAppel[3]
            dosdt.LbApp[4] = ttAppelDeFondRepCle.cLibelleAppel[4]
            dosdt.LbApp[5] = ttAppelDeFondRepCle.cLibelleAppel[5]
            dosdt.LbApp[6] = ttAppelDeFondRepCle.cLibelleAppel[6]
            dosdt.LbApp[7] = ttAppelDeFondRepCle.cLibelleAppel[7]
            dosdt.LbApp[8] = ttAppelDeFondRepCle.cLibelleAppel[8]
            dosdt.LbApp[9] = ttAppelDeFondRepCle.cLibelleAppel[9]
            dosdt.MtApp    = ttAppelDeFondRepCle.dMontantAppel
        .
    end. /* for each ttAppelDeFondRepCle: */

    for each doset no-lock
        where DosEt.TpCon = ttDossierTravaux.cCodeTypeMandat
          and doset.nocon = ttDossierTravaux.iNumeroMandat
          and doset.nodos = ttDossierTravaux.iNumeroDossierTravaux
          and doset.TpSur = "00001"    // todo   c'est quoi cette valeur???
      , each dosdt exclusive-lock
        where DosDt.NoIdt = DosEt.NoIdt
          and dosdt.CdApp <> ""
          and not can-find(first ttAppelDeFondRepCle
              where ttAppelDeFondRepCle.iNumeroIdentifiant = dosdt.noidt
                and ttAppelDeFondRepCle.iNumeroAppel       = dosdt.noapp
                and ttAppelDeFondRepCle.cCodeCle           = dosdt.CdApp):
        delete dosdt.
    end.

end procedure.

procedure repartitionMatricule private:
    /*------------------------------------------------------------------------------
    Purpose: REPARTITION PAR MATRICULE
    Notes: Creation / modification / Suppression
    ------------------------------------------------------------------------------*/
    define parameter buffer ttDossierTravaux for ttDossierTravaux.
    define output parameter plErreur as logical no-undo.

    define buffer dosdt   for dosdt.
    define buffer doset   for doset.

    for each ttAppelDeFondRepMat:
        find first dosdt no-lock
            where DosDt.NoIdt = ttAppelDeFondRepMat.iNumeroIdentifiant
              and dosdt.NoApp = ttAppelDeFondRepMat.iNumeroAppel
              and dosdt.CdApp = string(ttAppelDeFondRepMat.iNumeroCopro) + SEPAR[1] + string(ttAppelDeFondRepMat.iNumeroLot) no-error.
        if not available dosdt
        then do:
            create dosdt.
            assign
                dosdt.noIdt = ttAppelDeFondRepMat.iNumeroIdentifiant
                dosdt.noApp = ttAppelDeFondRepMat.iNumeroAppel
                dosdt.cdApp = string(ttAppelDeFondRepMat.iNumeroCopro) + SEPAR[1] + string(ttAppelDeFondRepMat.iNumeroLot)
                dosdt.cdcsy = mToken:cUser
                dosdt.dtcsy = today
                dosdt.heCsy = mtime
            .
        end.
        else do:
            find first dosdt exclusive-lock
                where dosdt.noIdt = ttAppelDeFondRepMat.iNumeroIdentifiant
                  and dosdt.noApp = ttAppelDeFondRepMat.iNumeroAppel
                  and dosdt.cdApp = string(ttAppelDeFondRepMat.iNumeroCopro) + SEPAR[1] + string(ttAppelDeFondRepMat.iNumeroLot) no-wait no-error.
            if outils:isUpdated(buffer dosdt:handle, 'dossier: ', string(ttAppelDeFondRepMat.iNumeroIdentifiant), ttAppelDeFondRepMat.dtTimestamp)
            then do:
                plErreur = true.
                return.
            end.
            assign
                dosdt.cdmsy = mToken:cUser
                dosdt.dtmsy = today
                dosdt.Hemsy = mtime
            .
        end.
        assign
            dosdt.LbApp[1] = ttAppelDeFondRepMat.cLibelleAppel[1]
            dosdt.LbApp[2] = ttAppelDeFondRepMat.cLibelleAppel[2]
            dosdt.LbApp[3] = ttAppelDeFondRepMat.cLibelleAppel[3]
            dosdt.LbApp[4] = ttAppelDeFondRepMat.cLibelleAppel[4]
            dosdt.LbApp[5] = ttAppelDeFondRepMat.cLibelleAppel[5]
            dosdt.LbApp[6] = ttAppelDeFondRepMat.cLibelleAppel[6]
            dosdt.LbApp[7] = ttAppelDeFondRepMat.cLibelleAppel[7]
            dosdt.LbApp[8] = ttAppelDeFondRepMat.cLibelleAppel[8]
            dosdt.LbApp[9] = ttAppelDeFondRepMat.cLibelleAppel[9]
            dosdt.MtApp    = ttAppelDeFondRepMat.dMontantAppel
        .
    end.

    for each doset no-lock
        where DosEt.TpCon = ttDossierTravaux.cCodeTypeMandat
          and doset.nocon = ttDossierTravaux.iNumeroMandat
          and doset.nodos = ttDossierTravaux.iNumeroDossierTravaux
          and doset.tpSur = "00002"    // todo   c'est quoi cette valeur???
      , each dosdt exclusive-lock
        where DosDt.NoIdt = DosEt.NoIdt
          and dosdt.cdapp > ""
          and not can-find(first ttAppelDeFondRepMat
            where ttAppelDeFondRepMat.iNumeroIdentifiant = DosDt.NoIdt
              and ttAppelDeFondRepMat.iNumeroAppel       = dosdt.noapp
              and ttAppelDeFondRepMat.iNumeroCopro       = integer(entry(1, dosdt.CdApp, SEPAR[1]))
              and ttAppelDeFondRepMat.iNumeroLot         = integer(entry(2, dosdt.CdApp, SEPAR[1]))):
        delete dosdt.
    end.

end procedure.
