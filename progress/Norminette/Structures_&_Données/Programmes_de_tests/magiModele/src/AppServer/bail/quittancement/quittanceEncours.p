/*------------------------------------------------------------------------
File        : quittanceEncours.p
Purpose     : 
Author(s)   : kantena  --  2017/11/22 
Notes       : vient des programmes chglocqt_ext.p et chglocq1_ext.p
              Chargement d'une quittance d'un locataire a partir de la table EQUIT,
              dans les tables temporaires TmQtt et TmRub
------------------------------------------------------------------------*/
{preprocesseur/type2role.i}
{preprocesseur/type2contrat.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{bail/include/equit.i &nomtable=ttqtt}
{bail/include/tmprub.i}

procedure getQuittance:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes: Utilisée par quittancemen.p
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeRole        as character no-undo.
    define input  parameter piNumeroRole      as integer   no-undo.
    define input  parameter piNumeroQuittance as integer   no-undo.
    define output parameter table for ttQtt.
    define output parameter table for ttRub.

    define variable vlChargeQuittance as logical   no-undo.
    define variable vhProc            as handle    no-undo.

    define buffer pquit for pquit.
    define buffer equit for equit.

    if pcTypeRole = {&TYPEROLE-candidatLocataire} then do:
        /* Recherche de la quittance du candidat */
        find first pquit no-lock
             where pquit.NoLoc = piNumeroRole
               and pquit.NoQtt = piNumeroQuittance no-error.
        if not available Pquit then return.
    end.
    else do:
        /* Recherche de la quittance du locataire */
        find first equit no-lock
             where equit.NoLoc = piNumeroRole
               and equit.NoQtt = piNumeroQuittance no-error.
        if not available equit then return.
    end.
    /* Quittance deja chargee ?*/
    find first ttQtt
         where ttQtt.NoLoc = piNumeroRole
           and ttQtt.NoQtt = piNumeroQuittance no-error.
    if available ttQtt then do:
        /* La quittance n'a pas deja ete chargée */
        if ttQtt.CdMaj <> 0
        then do:
            /* Elle est modifiee, Suppression de tous les enreg concernant la quittance dans ttQtt et ttRub */
            delete ttQtt no-error.
            for each ttRub 
               where ttRub.NoLoc = piNumeroRole
                 and ttRub.NoQtt = piNumeroQuittance:
                delete ttRub no-error.
            end.
            vlChargeQuittance = true.
        end.
    end. /* Quittance deja chargee */
    else vlChargeQuittance = true. // Quittance non chargee 

    if vlChargeQuittance then do:
        run bail/quittancement/cretmpqt.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        if pcTypeRole = {&TYPEROLE-candidatLocataire}
        then run copieToTmp in vhProc(input buffer pquit:handle, output table ttQtt by-reference, output table ttRub by-reference).
        else run copieToTmp in vhProc(input buffer equit:handle, output table ttQtt by-reference, output table ttRub by-reference).
        if valid-handle(vhProc) then run destroy in vhProc.
    end.

    /* Module de lancement de tous les modules de calcul d'une rubrique */
    /*
    {RunPgExp.i
        &Path       = RpRunQtt
        &Prog       = "'CreRubCa_ext.p'"
        &Parameter  = "
                  INPUT TpCttUse,
                  INPUT ttQtt.NoLoc,
                  INPUT ttQtt.ntbai,
                  INPUT ttQtt.Noqtt,
                  INPUT ttQtt.dtdpr,
                  INPUT ttQtt.dtfpr,
                  INPUT ttQtt.dtdeb,
                  INPUT ttQtt.DtFin,
                  INPUT INTEGER(SUBSTRING(ttQtt.PdQtt,1,3)),
                  OUTPUT CdREtUse
                  "}
    */
    /* Ajout Sy le 04/06/2009 */
    if pcTypeRole = {&TYPEROLE-candidatLocataire} then do:
        /*
        {RunPgExp.i
                    &Path       = RpRunQtt
                    &Expert     = Yes
                    &Prog       = "'CreRolQt_ext.p'"
                    &Parameter  = "INPUT TpRolUse
                                , INPUT NoRolUse
                                , OUTPUT CdRetour"}
        */
    end.
end procedure.
 
procedure getListeQuittance:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:  Utilisée par quittancement
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeRole   as character no-undo.
    define input  parameter piNumeroRole as integer   no-undo.
    define input  parameter poGlobalCollection as class collection no-undo.    
    define output parameter table for ttQtt.
    define output parameter table for ttRub.

    define variable viGlMoiMdf as integer no-undo.
    define variable viGlMoiMEc as integer no-undo.

    define variable vlBailFlo         as logical no-undo.
    define variable vlChargeQuittance as logical no-undo.
    define variable vhProc            as handle  no-undo.

    define buffer ctrat for ctrat.
    define buffer pquit for pquit.
    define buffer equit for equit.

    run bail/quittancement/cretmpqt.p persistent set vhProc.
    run getTokenInstance in vhProc (mToken:JSessionId).
    assign 
        viGlMoiMdf = poGlobalCollection:getInteger("giGlMoiMdf")
        viGlMoiMEc = poGlobalCollection:getInteger("giGlMoiMEc")
    .
    if pcTypeRole = {&TYPEROLE-candidatLocataire}
    then for each pquit no-lock            // Parcours des quittances provisoires
        where pquit.NoLoc = piNumeroRole:
        // Quittance deja chargee ?
        find first ttQtt
            where ttQtt.NoLoc = piNumeroRole
              and ttQtt.NoQtt = pquit.NoQtt no-error.
        if available ttQtt then do:
            // La quittance a déjà été chargée
            if ttQtt.CdMaj = 0
            then vlChargeQuittance = false. /* Elle n'a pas été modifiée */
            else do:                        /* Suppression de tous les enreg concernant la quittance dans ttQtt et ttRub */
                delete ttQtt no-error.
                for each ttRub
                    where ttRub.NoLoc = piNumeroRole
                      and ttRub.NoQtt = pquit.NoQtt:
                    delete ttRub no-error.
                end.
                vlChargeQuittance = true.
            end.
        end.
        else vlChargeQuittance = true.      // Quittance non chargee

        if vlChargeQuittance // Chargement de ttQtt
        then run copieToTmp in vhProc(input buffer pquit:handle, output table ttQtt by-reference, output table ttRub by-reference).
    end.
    else do:
        /* Recherche Nature du Mandat bail Fournisseur de Loyer ? */
        for first ctrat no-lock
            where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and ctrat.nocon = integer(truncate(piNumeroRole / 100000, 0)):
            vlBailFlo = ctrat.fgfloy.
        end.
        // Parcours des quittances en cours du locataire
        for each equit no-lock
            where equit.NoLoc = piNumeroRole
              and equit.msqtt >= (if vlBailFlo then viGlMoiMdf else viGlMoiMEc):
            /* AJout SY le 12/01/2015 pour ne pas prendre les Avis d'échéance périmés (Pb plantage PEC, equit non historisé) */
            // Quittance deja chargée ?
            find first ttQtt 
                where ttQtt.NoLoc = piNumeroRole
                  and ttQtt.NoQtt = equit.NoQtt no-error.
            if available ttQtt then do:
                /* La quittance a deja ete chargee*/
                if ttQtt.CdMaj = 0
                then vlChargeQuittance = false. // Elle n'a pas ete modifiee
                else do:                        /* Suppression de tous les enreg concernant la quittance dans ttQtt et ttRub */
                    delete ttQtt no-error.
                    for each ttRub  
                        where ttRub.NoLoc = piNumeroRole
                          and ttRub.NoQtt = equit.NoQtt:
                        delete ttRub no-error.
                    end.
                    vlChargeQuittance = true.
                end.
            end.
            else vlChargeQuittance = true.       // Quittance non chargée
            if vlChargeQuittance    /* Chargement de ttQtt*/
            then run copieToTmp in vhProc(input buffer equit:handle, output table ttQtt by-reference, output table ttRub by-reference).
        end.
    end.
    if valid-handle(vhproc) then run destroy in vhProc.
/*
    /* Ajout SY  20/06/2006 : Gestion des changement de période pour les calendrier d'evolution */
    ChArgPrg =  "N|0|CHGQTT".
/*    {RunPgExp.i
        &Path   = RpRunQtt
        &Prog   = "'MajLoyQt_ext.p'"
        &Parameter = " INPUT TpCttUse
                   ,INPUT NoRolUse-IN
                   ,INPUT-OUTPUT ChArgPrg
                   ,OUTPUT CdRetUse"}
*/                 
    for each ttQtt where ttQtt.NoLoc = piNumeroRole:
        if vlARevis = "00" then do:
            // Module pour savoir si revision ou non
/*
            {RunPgExp.i
                &Path       = RpRunQtt
                &Prog       = "'IsRevLoy_ext.p'"
                &Parameter  = "INPUT TpCttUse,
                          INPUT ttQtt.NoLoc,
                          INPUT ttQtt.NoQtt,
                          INPUT ttQtt.DtDpr,
                          INPUT ttQtt.DtFpr,
                          INPUT ttQtt.DtDeb,
                          INPUT ttQtt.DtFin"}
 */
        end.        
        if vlAIndex = "00" then do:
            // Module pour savoir si indexation ou non
            /*
            {RunPgExp.i
                &Path       = RpRunQtt
                &Prog       = "'IsIndLoy_ext.p'"
                &Parameter  = "INPUT TpCttUse,
                          INPUT ttQtt.NoLoc,
                          INPUT ttQtt.NoQtt,
                          INPUT ttQtt.DtDpr,
                          INPUT ttQtt.DtFpr,
                          INPUT ttQtt.DtDeb,
                          INPUT ttQtt.DtFin"}
            */
        end.
        /*
          Module de lancement de tous les modules       
          de calcul d'une rubrique                      
        */
        /*{RunPgExp.i
            &Path       = RpRunQtt
            &Prog       = "'CreRubCa_ext.p'"
            &Parameter  = "INPUT  TpCttUse,
                       INPUT  ttQtt.NoLoc,
                       INPUT  ttQtt.ntbai,
                       INPUT  ttQtt.Noqtt,
                       INPUT  ttQtt.dtdpr,
                       INPUT  ttQtt.dtfpr,
                       INPUT  ttQtt.dtdeb,
                       INPUT  ttQtt.DtFin,
                       INPUT  INTEGER(SUBSTRING(ttQtt.PdQtt,1,3)),
                       OUTPUT CdRetUse"}
        */
        if vlARevis = "01" then assign vlARevis = "02".
        if vlAIndex = "01" then assign vlAIndex = "02".
    end.

    if pcTypeRole = {&TYPEROLE-locataire} then do:
            /*
               08/09/98-LG/SC:Mettre systematiquement a jour
               equit a partir de ttQtt/ttRub meme si pas de  
               revision effectuee (ttQtt.cdmaj reste bon).   
            */
        /*
        {RunPgExp.i
            &Path       = RpRunQtt
            &Prog       = "'MajLocQt_ext.p'"
            &Parameter  = "OUTPUT LbTmpPdt"}
        */
        assign 
            vlARevis = "00"
            vlAindex = "00"
        .
    end.

    /* Ajout Sy le 04/06/2009 */
    if pcTypeRole = {&TYPEROLE-candidatLocataire} then do:
        /*
          {RunPgExp.i
                    &Path       = RpRunQtt
                    &Expert     = Yes
                    &Prog       = "'CreRolQt_ext.p'"
                    &Parameter  = "INPUT TpRolUse
                                , INPUT NoRolUse
                                , OUTPUT CdRetour"}
        */
    end.
*/
end procedure.
 
procedure creeQuittanceLocataire:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:  todo  procédure non utilisée ???
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroLocataire as integer   no-undo.
    define output parameter vcCodeRetour      as character no-undo initial "00".

    define variable viNumeroLocataire as integer no-undo.
    define variable viNumeroMandat    as integer no-undo.
    define variable viNumeroInterne   as integer no-undo.
    define variable viNumeroRubrique  as integer no-undo.
    define buffer equit for equit.
    define buffer rubqt for rubqt.

    assign
        viNumeroLocataire = piNumeroLocataire
        viNumeroMandat    = integer(substring(string(viNumeroLocataire, "9999999999"), 1, 5, "character"))
    .
    /* Suppression des quit. du locataire dans Equit */
    for each equit exclusive-lock 
        where equit.NoLoc = viNumeroLocataire:
        delete Equit no-error.
    end.
    /* Recherche du prochain n° interne de Equit */
    find last Equit no-lock no-error.
    if available equit then viNumeroInterne = equit.NoInt.

CREQUIT:
    do transaction:
        /* Parcours des quit. du locataire dans ttQtt */
        for each ttQtt 
            where ttQtt.NoLoc = viNumeroLocataire:
            create Equit no-error.
            if error-status:error then do:
                vcCodeRetour = "01".
                undo CREQUIT, leave CREQUIT.
            end.
            assign
                viNumeroInterne = viNumeroInterne + 1
                Equit.NoInt     = viNumeroInterne
            no-error.
            if error-status:error then do:
                vcCodeRetour = "01".
                delete Equit no-error.
                undo CREQUIT, leave CREQUIT.
            end.
            assign
                Equit.NoLoc = viNumeroLocataire
                Equit.NoQtt = ttQtt.NoQtt
                Equit.MsQtt = ttQtt.MsQtt
                Equit.MsQui = ttQtt.MsQui
                Equit.DtDeb = ttQtt.DtDeb
                Equit.DtFin = ttQtt.DtFin
                Equit.DtDpr = ttQtt.DtDpr
                Equit.DtFpr = ttQtt.DtFpr
                Equit.PdQtt = ttQtt.PdQtt
                Equit.NtBai = ttQtt.NtBai
                Equit.DuBai = ttQtt.DuBai
                Equit.UtDur = ttQtt.UtDur
                Equit.DtEff = ttQtt.DtEff
                Equit.TpIdc = ttQtt.TpIdc
                Equit.PdIdc = ttQtt.PdIdc
                Equit.NoIdc = ttQtt.NoIdc
                Equit.DtRev = ttQtt.DtRev
                Equit.DtPrv = ttQtt.DtPrv
                Equit.MdReg = ttQtt.MdReg
                Equit.CdTer = ttQtt.CdTer
                Equit.DtEnt = ttQtt.DtEnt
                Equit.DtSor = ttQtt.DtSor
                Equit.NoImm = ttQtt.NoImm
                Equit.NbRub = ttQtt.NbRub
                Equit.CdQuo = ttQtt.CdQuo
                Equit.NbNum = ttQtt.NbNum
                Equit.NbDen = ttQtt.NbDen
                Equit.CdDep = ttQtt.CdDep
                Equit.CdSol = ttQtt.CdSol
                Equit.CdRev = ttQtt.CdRev
                Equit.CdPrv = ttQtt.CdPrv
                Equit.CdPrs = ttQtt.CdPrs
                Equit.NbEdt = ttQtt.NbEdt
                Equit.CdCor = "00001"   /* texte sur Avis d'‚ch‚ance */
                Equit.FgTrf = false /* quittance non transf‚r‚e */
                Equit.nomdt = viNumeroMandat
                Equit.dtcsy = today
                Equit.hecsy = time
                Equit.cdcsy = mtoken:cUser
            no-error.
            if error-status:error then do:
                vcCodeRetour = "01".
                undo CREQUIT, leave CREQUIT.
            end.
            assign
                viNumeroRubrique = 0
                equit.mtQtt      = ttQtt.mtQtt
                //Equit.MtQtt-dev = ttQtt.MtQtt / RecTauDev()
            no-error.
            /* Parcours des quittances de ttRub */
            for each ttRub
                where ttRub.NoLoc = ttQtt.NoLoc
                  and ttRub.NoQtt = ttQtt.NoQtt:
                find first rubqt no-lock
                    where rubqt.cdrub = ttRub.NoRub
                      and rubqt.cdlib = ttRub.NoLib no-error.
                assign
                    viNumeroRubrique = viNumeroRubrique + 1
                    equit.tbFam[viNumeroRubrique] = (if available rubqt then rubqt.cdfam else ttRub.cdFam)  /* modif SY le 08/02/2013 */
                    equit.tbSfa[viNumeroRubrique] = (if available rubqt then rubqt.cdsfa else ttRub.cdSfa)  /* modif SY le 08/02/2013 */
                    equit.tbRub[viNumeroRubrique] = ttRub.noRub
                    equit.tbLib[viNumeroRubrique] = ttRub.noLib
                    equit.tbGen[viNumeroRubrique] = ttRub.cdGen
                    equit.tbSig[viNumeroRubrique] = ttRub.cdSig
                    equit.tbDet[viNumeroRubrique] = ttRub.cdDet
                    equit.tbQte[viNumeroRubrique] = ttRub.vlQte
                    equit.tbPro[viNumeroRubrique] = ttRub.cdPro
                    equit.tbNum[viNumeroRubrique] = ttRub.vlNum
                    equit.tbDen[viNumeroRubrique] = ttRub.vlDen
                    equit.tbDt1[viNumeroRubrique] = ttRub.dtDap
                    equit.tbDt2[viNumeroRubrique] = ttRub.dtFap
                    equit.tbFil[viNumeroRubrique] = ttRub.chFil
                no-error.
                if error-status:error then do:
                    vcCodeRetour = "01".
                    undo CREQUIT, leave CREQUIT.
                end.
                assign
                    equit.TbPun[viNumeroRubrique]     = ttRub.VlPun
                    equit.TbTot[viNumeroRubrique]     = ttRub.MtTot
                    equit.TbMtq[viNumeroRubrique]     = ttRub.VlMtq
                    //equit.TbPun-dev[viNumeroRubrique] = ttRub.VlPun / RecTauDev()
                    //equit.TbTot-dev[viNumeroRubrique] = ttRub.MtTot / RecTauDev()
                    //equit.TbMtq-dev[viNumeroRubrique] = ttRub.VlMtq / RecTauDev()
                .
            end.
        end.
    end.
end procedure.