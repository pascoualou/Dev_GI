/*------------------------------------------------------------------------
File        : tacheRefacturationDepense.p
Purpose     :
Author(s)   : DM 2017/11/27
Notes       : à partir de adb/src/tache/prmmtrfl.p
derniere revue: 2018/05/25 - DMI: OK
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/categorie2bail.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{application/include/error.i}
{tache/include/tacheRefacturationDepense.i}
{adblib/include/cttac.i}
{tache/include/tache.i}
{adblib/include/dtfinmdt.i}    // procedure dtFinMdt

function controleRefacturationLocataire returns logical private:
    /*------------------------------------------------------------------------------
    Purpose: controle une ligne de ttRefacturationRubrique et ttrefacturationlocataire
    Notes  :
    ------------------------------------------------------------------------------*/
    if available ttRefacturationLocataire and ttRefacturationLocataire.dPourcentageLocataire > 100
    then do:
        mError:createError({&error}, 1000374). // 1000374 "L'affectation locataire ne peut pas dépasser 100%"
        return false.
    end.
    return true.
end function.

function controleRefacturationRubrique returns logical private:
    /*------------------------------------------------------------------------------
    Purpose: controle une ligne de ttRefacturationRubrique et ttrefacturationlocataire
    Notes  :
    ------------------------------------------------------------------------------*/
    if available ttRefacturationRubrique and ttRefacturationRubrique.dPourcentageLocataire > 100
    then do:
        mError:createError({&error}, 1000374). // 1000374 "L'affectation locataire ne peut pas dépasser 100%"
        return false.
    end.
    return true.
end function.

procedure getTacheRefacturationDepense:
    /*------------------------------------------------------------------------------
    Purpose: Extraction de la liste des rubriques et des locataires
    Notes  : service appelé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64   no-undo.
    define output parameter table for ttTacheRefacturationDepense.
    define output parameter table for ttRefacturationRubrique.
    define output parameter table for ttRefacturationLocataire.

    run ChargeTacheRefacturationDepense(piNumeroMandat, "T", false).
end procedure.

procedure ChargeTacheRefacturationDepense private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat         as int64     no-undo.
    define input parameter pcCodeActif            as character no-undo.
    define input parameter plCommercialUniquement as logical   no-undo.

    define variable vdaResiliation as date    no-undo.
    define variable vdaOdfm        as date    no-undo.
    define variable vlResilie      as logical no-undo.

    define buffer tache for tache.

    if piNumeroMandat > 0 then do:
        run dtFinMdt({&TYPECONTRAT-mandat2Gerance}, piNumeroMandat, output vdaResiliation, output vdaOdfm).
        vlResilie = (vdaOdfm <> ? or (vdaResiliation <> ? and vdaResiliation < today)).  // Attention, valeur ? sur vdaResiliation
    end.
    create ttTacheRefacturationDepense.
    assign
        ttTacheRefacturationDepense.lModifAutorise = not vlResilie
        ttTacheRefacturationDepense.CRUD           = "R"
        ttTacheRefacturationDepense.iNumeroMandat  = piNumeroMandat
    .
    for first tache no-lock
        where Tache.tptac = {&TYPETACHE-refacturationDepMandat1}
          and Tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and Tache.nocon = piNumeroMandat:
        assign
            ttTacheRefacturationDepense.dtTimestamp = datetime(tache.dtmsy, tache.hemsy)
            ttTacheRefacturationDepense.rRowid      = rowid(tache)
        .
    end.
    run chargeRefacturationDepense  (piNumeroMandat).
    run chargeRefacturationLocataire(piNumeroMandat, pcCodeActif, plCommercialUniquement).
end procedure.

procedure chargeRefacturationDepense private:
    /*------------------------------------------------------------------------------
    Purpose: Extraction de la liste des rubriques
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64     no-undo.

    define variable vhRubrique as handle  no-undo.

    define buffer alrubhlp for alrubhlp.
    define buffer tbdet    for tbdet.
    define buffer vbtbdet  for tbdet.

    empty temp-table ttRefacturationRubrique.
    if piNumeroMandat = 0 then return.

    run bail/quittancement/rubriqueQuitt.p persistent set vhRubrique.
    run getTokenInstance in vhRubrique (mToken:JSessionId).
    for each vbtbdet no-lock
        where vbtbdet.cdent = "REFAC-CAB"
          and vbtbdet.iden1 = ""
      , first alrubhlp  no-lock
        where alrubhlp.soc-cd   = integer(mtoken:cRefGerance)
          and alrubhlp.cdlng    = mtoken:iCodeLangueReference
          and alrubhlp.rub-cd   = vbtbdet.iden2
          and alrubhlp.ssrub-cd = vbtbdet.idde1:
        create ttRefacturationRubrique.
        assign
            ttRefacturationRubrique.iNumeroMandat            = piNumeroMandat
            ttRefacturationRubrique.iCodeRubriqueDepense     = integer(alrubhlp.rub-cd)
            ttRefacturationRubrique.iCodeSousRubriqueDepense = integer(alrubhlp.ssrub-cd)
            ttRefacturationRubrique.cLibelleRubriqueDepense  = alrubhlp.libssrub
            ttRefacturationRubrique.iCodeFiscalite           = integer(vbtbdet.idde2)
            ttRefacturationRubrique.lRefacturation           = vbtbdet.fgde1
            ttRefacturationRubrique.dPourcentageLocataire    = 0 // Init
            ttRefacturationRubrique.CRUD                     = "R"
        .
        if num-entries(vbtbdet.lbde1, "." ) >= 2
        then assign
            ttRefacturationRubrique.iCodeRubriqueQuitt         = integer(entry(1, vbtbdet.lbde1, "." ))
            ttRefacturationRubrique.iCodeLibelleRubriqueQuitt  = integer(entry(2, vbtbdet.lbde1, "." ))
            ttRefacturationRubrique.cLibelleRubriqueQuitt      = dynamic-function('getLibelleRubrique' in vhRubrique // Recuperation du libelle client de la rubrique
                                                                                 , ttRefacturationRubrique.iCodeRubriqueQuitt
                                                                                 , ttRefacturationRubrique.iCodeLibelleRubriqueQuitt
                                                                                 , 0
                                                                                 , 0
                                                                                 , ? // date comptable
                                                                                 , integer(mtoken:cRefGerance)
                                                                                 , 0)
        .
        for first tbdet no-lock
            where tbdet.cdent = substitute("REFAC-&1", {&TYPECONTRAT-mandat2Gerance})
              and tbdet.iden1 = string(piNumeroMandat, "9999999999")
              and tbdet.iden2 = string(ttRefacturationRubrique.iCodeRubriqueDepense, "999")
              and tbdet.idde1 = string(ttRefacturationRubrique.iCodeSousRubriqueDepense, "999")
              and tbdet.idde2 = string(ttRefacturationRubrique.iCodeFiscalite, "9"):
            assign
                ttRefacturationRubrique.dPourcentageLocataire = tbdet.mtde1
                ttRefacturationRubrique.dtTimeStamp           = datetime(tbdet.dtmsy, tbdet.hemsy)
                ttRefacturationRubrique.rRowid                = rowid(tbdet)
            .
        end.
    end.
    delete procedure vhRubrique no-error.
end procedure.

procedure chargeRefacturationLocataire private:
    /*------------------------------------------------------------------------------
    Purpose: chargement de la liste des locataires du mandat
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat         as int64     no-undo.
    define input parameter pcCodeActif            as character no-undo.
    define input parameter plCommercialUniquement as logical   no-undo.

    define variable vlBailCommercial as logical no-undo.

    define buffer ctctt   for ctctt.
    define buffer ctrat   for ctrat.
    define buffer vbRoles for roles.
    define buffer tiers   for tiers.
    define buffer tbdet   for tbdet.

    empty temp-table ttRefacturationLocataire.
    if piNumeroMandat = 0 then return.

boucleMandat:
    for each ctctt no-lock
        where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
          and ctctt.noct1 = piNumeroMandat
          and ctctt.tpct2 = {&TYPECONTRAT-bail}
      , first ctrat no-lock
        where ctrat.tpcon =  ctctt.tpct2
          and ctrat.nocon =  ctctt.noct2
          and ctrat.ntcon <> {&NATURECONTRAT-specialVacant}            /* sauf spécial vacant prop */
          and (pcCodeActif = "T"
           or (pcCodeActif = "A" and (ctrat.dtree = ? or ctrat.dtree > today))
           or (pcCodeActif = "R" and ctrat.dtree <= today))
      , first vbRoles no-lock
        where vbRoles.tprol = ctrat.tprol
          and vbRoles.norol = ctrat.norol
      , first tiers no-lock
        where tiers.notie = vbRoles.notie:
        vlBailCommercial = can-find(first sys_pg no-lock
                                    where sys_pg.tppar = "R_CBA"
                                      and sys_pg.zone2 = ctrat.ntcon
                                      and lookup(sys_pg.zone1, substitute("&1,&2"
                                                                       , {&CATEGORIE2BAIL-Commercial}
                                                                       , {&CATEGORIE2BAIL-Professionnel})) > 0).
        if plCommercialUniquement and not vlBailCommercial then next boucleMandat.

        for each ttRefacturationRubrique:
//   Est-ce nécessaire de créer ttRefacturationLocataire si on ne trouve pas le tbdet requis plus bas ??? 
//   DMI 24/05/2018 Oui car ttRefacturationLocataire contient la liste de toutes les rubriques associées ou pas au mandat, 
//   lorsqu'elles sont associées au mandat le pourcentage , le rowid et le timestamp sont assignés.
              
            create ttRefacturationLocataire.
            assign
                ttRefacturationLocataire.iNumeroMandat            = piNumeroMandat
                ttRefacturationLocataire.iCodeRubriqueDepense     = ttRefacturationRubrique.iCodeRubriqueDepense
                ttRefacturationLocataire.iCodeSousRubriqueDepense = ttRefacturationRubrique.iCodeSousRubriqueDepense
                ttRefacturationLocataire.iCodeFiscalite           = ttRefacturationRubrique.iCodeFiscalite
                ttRefacturationLocataire.dtResiliation            = ctrat.dtree
                ttRefacturationLocataire.iNumeroLocataire         = (ctrat.nocon modulo 10000)
                ttRefacturationLocataire.cNatureContrat           = ctrat.ntcon
                ttRefacturationLocataire.iNumeroContrat           = ctrat.nocon
                ttRefacturationLocataire.cNomLocataire            = ctrat.lbnom
                ttRefacturationLocataire.dPourcentageLocataire    = ttRefacturationRubrique.dPourcentageLocataire // Initialisation
                ttRefacturationLocataire.cLibelleNatureBail       = outilTraduction:getLibelleProg("O_COT", ctrat.ntcon)
                ttRefacturationLocataire.lActif                   = (ctrat.dtree = ? or ctrat.dtree > today)
                ttRefacturationLocataire.lCommercial              = vlBailCommercial
                ttRefacturationLocataire.CRUD                     = "R"
            .
            for first tbdet no-lock
                where tbdet.cdent = substitute("REFAC-&1", {&TYPECONTRAT-bail})
                  and tbdet.iden1 = string(ctrat.nocon, "9999999999")
                  and tbdet.iden2 = string(ttRefacturationRubrique.iCodeRubriqueDepense, "999")
                  and tbdet.idde1 = string(ttRefacturationRubrique.iCodeSousRubriqueDepense, "999")
                  and tbdet.idde2 = string(ttRefacturationRubrique.iCodeFiscalite, "9"):
                assign
                    ttRefacturationLocataire.dPourcentageLocataire = tbdet.mtde1 // Taux affecté au locatire
                    ttRefacturationLocataire.dtTimeStamp           = datetime(tbdet.dtmsy, tbdet.hemsy)
                    ttRefacturationLocataire.rRowid                = rowid(tbdet)
                .
            end.
        end.
    end.
end procedure.

procedure getControleTacheRefacturationDepense :
    /*------------------------------------------------------------------------------
    Purpose: controle une ligne de ttRefacturationRubrique et ttrefacturationlocataire
    Notes  : Service appelé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheRefacturationDepense.
    define input parameter table for ttRefacturationRubrique.
    define input parameter table for ttRefacturationLocataire.

    for first ttTacheRefacturationDepense
        where lookup(ttTacheRefacturationDepense.CRUD, 'C,U') > 0:
        for first ttRefacturationRubrique
            where ttRefacturationRubrique.iNumeroMandat = ttTacheRefacturationDepense.iNumeroMandat
              and lookup(ttRefacturationRubrique.CRUD, 'C,U') > 0
              and ttRefacturationRubrique.lControle:
            if not controleRefacturationRubrique() then return.
        end.
        for each ttRefacturationLocataire
            where ttRefacturationLocataire.iNumeroMandat = ttTacheRefacturationDepense.iNumeroMandat
              and lookup(ttRefacturationLocataire.CRUD, 'C,U') > 0
              and ttRefacturationLocataire.lControle:
            controleRefacturationLocataire().
        end.
    end.
end procedure.

procedure updateTacheRefacturationDepense:
    /*------------------------------------------------------------------------------
    Purpose: Mise à jour tache Refacturation dépense mandat
    Notes  : Service appelé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheRefacturationDepense.
    define input parameter table for ttRefacturationRubrique.
    define input parameter table for ttRefacturationLocataire.
    define input parameter table for ttError.

    // si % locataire dans browse locataire => paramétrage mandat/rub doit exister
    for first ttTacheRefacturationDepense
        where lookup(ttTacheRefacturationDepense.CRUD, "U,D") > 0 transaction:
        if ttTacheRefacturationDepense.CRUD = "U"
        then for each ttRefacturationLocataire
            where ttRefacturationLocataire.iNumeroMandat = ttTacheRefacturationDepense.iNumeroMandat
              and lookup(ttRefacturationLocataire.CRUD,"C,U") > 0
          , first ttRefacturationRubrique
            where ttRefacturationRubrique.iNumeroMandat            = ttRefacturationLocataire.iNumeroMandat
              and ttRefacturationRubrique.iCodeRubriqueDepense     = ttRefacturationLocataire.iCodeRubriqueDepense
              and ttRefacturationRubrique.iCodeSousRubriqueDepense = ttRefacturationLocataire.iCodeSousRubriqueDepense
              and ttRefacturationRubrique.iCodeFiscalite           = ttRefacturationLocataire.iCodeFiscalite :
             if not controleRefacturationRubrique() or not controleRefacturationLocataire() then return.

             if ttRefacturationLocataire.dPourcentageLocataire <> 0 and ttRefacturationRubrique.dPourcentageLocataire = 0
             then do:
                 mError:createError({&error}, 1000375 // 1000375 "Vous devez saisir le paramétrage d'affectation locataire pour la rubrique &1 sous-rubrique &2 code fisc. &3"
                                  , substitute("&1&2&3&2&4"
                                             , ttRefacturationRubrique.iCodeRubriqueDepense
                                             , separ[1]
                                             , ttRefacturationRubrique.iCodeSousRubriqueDepense
                                             , ttRefacturationRubrique.iCodeFiscalite)).
                 return.
             end.
        end.
        else if outils:questionnaire(1000378, table ttError by-reference) <= 2  // 1000378 "Vous allez supprimer la tâche refacturation mandat. Confirmez-vous ?"
             then return.

        run commit_all_modifications.
        if merror:erreur() then undo, leave.
    end.
end procedure.

procedure commit_all_modifications private:
    /*------------------------------------------------------------------------------
    Purpose: enregistrement en base
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhProcTbdet as handle no-undo.  
    define buffer tbdet for tbdet.

    for each ttRefacturationRubrique where lookup(ttRefacturationRubrique.CRUD,"U,C,D") > 0 :
        ttRefacturationRubrique.cdent = substitute("REFAC-&1", {&TYPECONTRAT-mandat2Gerance}).
    end.
    for each ttRefacturationLocataire where lookup(ttRefacturationLocataire.CRUD,"U,C,D") > 0 :
        ttRefacturationLocataire.cdent = substitute("REFAC-&1", {&TYPECONTRAT-bail}).
    end.

    run adblib/tbdet_CRUD.p persistent set vhProcTbdet.
    run getTokenInstance in vhProcTbdet(mToken:JSessionId).
    run setTbdet in vhProcTbdet (table ttRefacturationRubrique  by-reference).
    run setTbdet in vhProcTbdet (table ttRefacturationLocataire by-reference).
    run destroy in vhProcTbdet.
    
    if ttTacheRefacturationDepense.CRUD = "U" then do:
        // Si ligne refacturation existe => créer la tache sinon la supprimer
        find first tbdet no-lock
            where tbdet.cdent = substitute("REFAC-&1", {&TYPECONTRAT-mandat2Gerance})
              and tbdet.iden1 = string(ttTacheRefacturationDepense.iNumeroMandat, "9999999999") no-error.
        if available tbdet then do:
            if not can-find(first tache no-lock
                where tache.tptac = {&TYPETACHE-refacturationDepMandat1}
                  and tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and tache.nocon = ttTacheRefacturationDepense.iNumeroMandat) then run creTacheRefacturation(ttTacheRefacturationDepense.iNumeroMandat).
            run creCttacBail(ttTacheRefacturationDepense.iNumeroMandat).
            run creCttacPreBail(ttTacheRefacturationDepense.iNumeroMandat).
        end.
        else do:
            run supTacheRefacturation(ttTacheRefacturationDepense.iNumeroMandat).
            mError:createError({&information}, 1000377). // 1000377 "Vous n'avez pas créé de paramétrage de refacturation des dépenses aux locataires"
        end.
    end.
    else if ttTacheRefacturationDepense.CRUD = "D" 
    then run supTacheRefacturation (ttTacheRefacturationDepense.iNumeroMandat).

end procedure.

procedure creCttacBail private:
    /*------------------------------------------------------------------------------
    Purpose: creation cttac tache/Bail
    Notes  : code issu de cretachebail
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64     no-undo.

    define variable vhProcCttac as handle    no-undo.

    empty temp-table ttCttac.
blocTrans:
    do transaction:
        for each ttRefacturationLocataire
            where ttRefacturationLocataire.iNumeroMandat = piNumeroMandat
            break by ttRefacturationLocataire.iNumeroContrat:
            if first-of(ttRefacturationLocataire.iNumeroContrat)
            and not can-find(first cttac no-lock
                             where cttac.tpcon = {&TYPECONTRAT-bail}
                               and cttac.nocon = ttRefacturationLocataire.iNumeroContrat
                               and cttac.tptac = {&TYPETACHE-refacturationDepMandat2})
            then do:
                create ttCttac.
                assign
                    ttCttac.tpcon = {&TYPECONTRAT-bail}
                    ttCttac.nocon = ttRefacturationLocataire.iNumeroContrat
                    ttCttac.tptac = {&TYPETACHE-refacturationDepMandat2}
                    ttCttac.CRUD  = "C"
                .
            end.
        end.
        if can-find(first ttCttac) then do:
            run adblib/cttac_CRUD.p persistent set vhProcCttac.
            run getTokenInstance in vhProcCttac(mToken:JSessionId).
            run setCttac in vhProcCttac (table ttCttac by-reference).
            run destroy in vhProcCttac.
            if mError:erreur() then undo blocTrans, leave blocTrans.
        end.
    end.
    error-status:error = false no-error.  // reset error-status
    return.
end procedure.

procedure creCttacPreBail private:
    /*------------------------------------------------------------------------------
    Purpose: creation cttac tache/pre-Bail
    Notes  : code issu de creCttacPreBail
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64 no-undo.

    define variable vhProcCttac as handle    no-undo.
    define buffer ctrat for ctrat.

    empty temp-table ttCttac.
blocTrans:
    do transaction:
        for each ctrat no-lock
            where ctrat.tpcon = {&TYPECONTRAT-preBail}
              and ctrat.nocon >= (piNumeroMandat * 100000 + 00101) // int64( string(piNumeroMandat, "99999") + "001" + "01" )
              and ctrat.nocon <= (piNumeroMandat * 100000 + 99999) // int64( string(piNumeroMandat, "99999") + "999" + "99" )
              and ctrat.ntcon <> {&NATURECONTRAT-specialVacant}:
            if not can-find(first cttac no-lock
                                  where cttac.tpcon = ctrat.tpcon
                                    and cttac.nocon = ctrat.nocon
                                    and cttac.tptac = {&TYPETACHE-refacturationDepMandat2})
            then do:
                create ttCttac.
                assign
                    ttCttac.tpcon = ctrat.tpcon
                    ttCttac.nocon = ctrat.nocon
                    ttCttac.tptac = {&TYPETACHE-refacturationDepMandat2}
                    ttCttac.CRUD  = "C"
                .
            end.
        end.
        if can-find(first ttCttac) then do:
            run adblib/cttac_CRUD.p persistent set vhProcCttac.
            run getTokenInstance in vhProcCttac(mToken:JSessionId).
            run setCttac in vhProcCttac(table ttCttac by-reference).
            run destroy in vhProcCttac.
            if mError:erreur() then undo blocTrans, leave blocTrans.
        end.
    end.
    error-status:error = false no-error.  // reset error-status
    return.
end procedure.

procedure supTacheRefacturation private:
    /*------------------------------------------------------------------------------
    Purpose: suppression de la tache / cttac
    Notes  : code issu de SupTache
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64 no-undo.

    define variable vhProcCttac as handle    no-undo.
    define variable vhProcTache as handle    no-undo.
    define buffer cttac for cttac.
    define buffer tache for tache.

blocTrans:
    do transaction:
        for first cttac no-lock
            where cttac.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and cttac.nocon = piNumeroMandat
              and cttac.tptac = {&TYPETACHE-refacturationDepMandat1} :
            empty temp-table ttCttac.
            create ttCttac.
            if outils:copyValidField(buffer cttac:handle, buffer ttCttac:handle) then do:
                ttCttac.CRUD  = "D".
                run adblib/cttac_CRUD.p persistent set vhProcCttac.
                run getTokenInstance in vhProcCttac(mToken:JSessionId).
                run destroy in vhProcTache.
                run setCttac in vhProcCttac(table ttCttac by-reference).
                if mError:erreur() then undo blocTrans, leave blocTrans.
            end.
        end.
        for last tache no-lock
            where tache.tptac = {&TYPETACHE-refacturationDepMandat1}
              and tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and tache.nocon = piNumeroMandat:
            create ttTache.
            if outils:copyValidField(buffer tache:handle, buffer ttTache:handle) then do:
                assign
                    ttTache.CRUD        = "D"
                    ttTache.dtTimeStamp = ttTacheRefacturationDepense.dtTimeStamp
                    ttTache.rRowid      = ttTacheRefacturationDepense.rRowid
                .
                run tache/tache.p persistent set vhProcTache.
                run getTokenInstance in vhProcTache(mToken:JSessionId).
                run destroy in vhProcCttac.
                run setTache in vhProcTache(table ttTache by-reference).
                if mError:erreur() then undo blocTrans, leave blocTrans.
            end.
        end.
        run supCttacBailPreBail(piNumeroMandat).
    end.
    error-status:error = false no-error.  // reset error-status
    return.
end procedure.

procedure supCttacBailPreBail private:
    /*------------------------------------------------------------------------------
    Purpose: suppression cttac bail / prebail
    Notes  : code issu de supCttacBailPreBail
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64 no-undo.

    define variable vhProcCttac as handle    no-undo.
    define buffer cttac for cttac.

    empty temp-table ttCttac.
blocTrans:
    do transaction:
        for each cttac exclusive-lock
            where cttac.tpcon = {&TYPECONTRAT-preBail}
              and cttac.nocon >= (piNumeroMandat * 100000 + 00101) //  int64( STRING(NoMdtSel-IN , "99999") + "001" + "01" )
              and cttac.nocon <= (piNumeroMandat * 100000 + 99999) // int64( STRING(NoMdtSel-IN , "99999") + "999" + "99" )
              and cttac.tptac = {&TYPETACHE-refacturationDepMandat2} :
            create ttCttac.
            if outils:copyValidField(buffer cttac:handle, buffer ttCttac:handle)
            then ttCttac.CRUD  = "D".
        end.
        for each cttac exclusive-lock
            where cttac.tpcon = {&TYPECONTRAT-bail}
              and cttac.nocon >= (piNumeroMandat * 100000 + 00101) // int64( STRING(NoMdtSel-IN , "99999") + "001" + "01" )
              and cttac.nocon <= (piNumeroMandat * 100000 + 99999) // int64( STRING(NoMdtSel-IN , "99999") + "999" + "99" )
              and cttac.tptac = {&TYPETACHE-refacturationDepMandat2}:
            create ttCttac.
            if outils:copyValidField(buffer cttac:handle, buffer ttCttac:handle)
            then ttCttac.CRUD  = "D".
        end.
        if can-find (first ttCttac)
        then do:
            run adblib/cttac_CRUD.p persistent set vhProcCttac.
            run getTokenInstance in vhProcCttac(mToken:JSessionId).
            run setCttac in vhProcCttac(table ttCttac by-reference).
            run destroy in vhProcCttac.
            if mError:erreur() then undo blocTrans, leave blocTrans.
        end.
    end.
    error-status:error = false no-error.  // reset error-status
    return.
end procedure.

procedure creTacheRefacturation private:
    /*------------------------------------------------------------------------------
    Purpose: création de la tache
    Notes  : code issu de CreTache
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64 no-undo.

    define variable vhProcCttac as handle    no-undo.
    define variable vhProcTache as handle    no-undo.

    run adblib/cttac_CRUD.p persistent set vhProcCttac.
    run getTokenInstance in vhProcCttac(mToken:JSessionId).
    run tache/tache.p persistent set vhProcTache.
    run getTokenInstance in vhProcTache(mToken:JSessionId).
blocTrans:
    do transaction:
        // Creation tache
        empty temp-table ttTache.
        create ttTache.
        assign
            ttTache.tpTac = {&TYPETACHE-refacturationDepMandat1}
            ttTache.tpcon = {&TYPECONTRAT-mandat2Gerance}
            ttTache.nocon = piNumeroMandat
            ttTache.CRUD  = "C"
        .
        run setTache in vhProcTache(table ttTache by-reference).
        if mError:erreur() then undo blocTrans, leave blocTrans.
        // lien contrat/tache
        empty temp-table ttCttac.
        create ttCttac.
        assign
            ttCttac.tpcon = {&TYPECONTRAT-mandat2Gerance}
            ttCttac.nocon = piNumeroMandat
            ttCttac.tptac = {&TYPETACHE-refacturationDepMandat1}
            ttCttac.CRUD  = "C"
        .
        run setCttac in vhProcCttac(table ttCttac by-reference).
        if mError:erreur() then undo blocTrans, leave blocTrans.
    end. /* transaction CreTac */
    run destroy in vhProcTache.
    run destroy in vhProcCttac.
    error-status:error = false no-error.  // reset error-status
    return.
end procedure.

procedure getEdRefacturationDepense:
    /*------------------------------------------------------------------------------
    Purpose: Edition de la liste des rubriques et des locataires
    Notes  : service appelé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat         as int64     no-undo.
    define input parameter plCommercialUniquement as logical   no-undo. // Commercial et professionnel uniquement
    define input parameter pcCodeActif            as character no-undo. // A = Actif, R = Resilie, T = Tous
    define output parameter table for ttEdRefacturationDepense.

    define variable vcNomMandant     as character no-undo.
    define variable vcAdresseMandant as character no-undo.
    define variable vdaResiliation   as date      no-undo.

    define buffer ctrat  for ctrat.
    define buffer sys_pg for sys_pg.
    define buffer alrubhlp for alrubhlp.

    empty temp-table ttEdRefacturationDepense.
    run chargeTacheRefacturationDepense(piNumeroMandat, pcCodeActif, plCommercialUniquement).
    for first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and ctrat.nocon = ttTacheRefacturationDepense.iNumeroMandat:
        assign
            vcNomMandant     = outilFormatage:getNomTiers(ctrat.tprol, ctrat.norol)
            vcAdresseMandant = outilFormatage:formatageAdresse(ctrat.tprol, ctrat.norol)
            vdaResiliation   = ctrat.dtree.
    end.
    for each ttRefacturationRubrique
        where ttRefacturationRubrique.iNumeroMandat = piNumeroMandat
          and (ttRefacturationRubrique.lRefacturation or ttRefacturationRubrique.iCodeRubriqueQuitt > 0):
        create ttEdRefacturationDepense.
        assign
            ttEdRefacturationDepense.iNumeroMandat                 = piNumeroMandat
            ttEdRefacturationDepense.cNomMandant                   = vcNomMandant
            ttEdRefacturationDepense.cAdresseMandant               = vcAdresseMandant
            ttEdRefacturationDepense.daDateResiliation             = vdaResiliation
            ttEdRefacturationDepense.iCodeRubriqueDepense          = ttRefacturationRubrique.iCodeRubriqueDepense
            ttEdRefacturationDepense.iCodeSousRubriqueDepense      = ttRefacturationRubrique.iCodeSousRubriqueDepense
            ttEdRefacturationDepense.iCodeFiscalite                = ttRefacturationRubrique.iCodeFiscalite
            ttEdRefacturationDepense.lRefacturation                = ttRefacturationRubrique.lRefacturation
            ttEdRefacturationDepense.cCodeRubriqueQuittancement    = (if not ttRefacturationRubrique.lRefacturation
                                                                      then substitute("&1.&2"
                                                                                    , string(ttRefacturationRubrique.iCodeRubriqueQuitt,"999")
                                                                                    , string(ttRefacturationRubrique.iCodeLibelleRubriqueQuitt,"99"))
                                                                      else "")
            ttEdRefacturationDepense.cLibelleRubriqueQuittancement = (if not ttRefacturationRubrique.lRefacturation
                                                                        then ttRefacturationRubrique.cLibelleRubriqueQuitt
                                                                        else "")
            ttEdRefacturationDepense.dPourcentageLocataireMandat   = ttRefacturationRubrique.dPourcentageLocataire
        .
        for first alrubhlp no-lock
            where alrubhlp.soc-cd   = integer(mtoken:cRefGerance)
              and alrubhlp.cdlng    = mtoken:iCodeLangueReference
              and alrubhlp.rub-cd   = string(ttRefacturationRubrique.iCodeRubriqueDepense,"999")
              and alrubhlp.ssrub-cd = string(ttRefacturationRubrique.iCodeSousRubriqueDepense,"999") :
            assign
                ttEdRefacturationDepense.cLibelleRubriqueDepense     = alrubhlp.librub
                ttEdRefacturationDepense.cLibelleSousRubriqueDepense = alrubhlp.libssrub
            .
        end.

        /* locataires pour cette rubrique/ssrub/fisc */
        if ttEdRefacturationDepense.dPourcentageLocataireMandat > 0
        then for each ttRefacturationLocataire
            where ttRefacturationLocataire.iNumeroMandat            = ttEdRefacturationDepense.iNumeroMandat
              and ttRefacturationLocataire.iCodeRubriqueDepense     = ttEdRefacturationDepense.iCodeRubriqueDepense
              and ttRefacturationLocataire.iCodeSousRubriqueDepense = ttEdRefacturationDepense.iCodeSousRubriqueDepense
              and ttRefacturationLocataire.iCodeFiscalite           = ttEdRefacturationDepense.iCodeFiscalite:
            create ttEdRefacturationDepense.
            assign
                ttEdRefacturationDepense.iNumeroMandat                 = piNumeroMandat
                ttEdRefacturationDepense.cNomMandant                   = vcNomMandant
                ttEdRefacturationDepense.cAdresseMandant               = vcAdresseMandant
                ttEdRefacturationDepense.daDateResiliation             = vdaResiliation
                ttEdRefacturationDepense.iCodeRubriqueDepense          = ttRefacturationRubrique.iCodeRubriqueDepense
                ttEdRefacturationDepense.iCodeSousRubriqueDepense      = ttRefacturationRubrique.iCodeSousRubriqueDepense
                ttEdRefacturationDepense.iCodeFiscalite                = ttRefacturationRubrique.iCodeFiscalite
                ttEdRefacturationDepense.lRefacturation                = ttRefacturationRubrique.lRefacturation
                ttEdRefacturationDepense.cCodeRubriqueQuittancement    = (if not ttRefacturationRubrique.lRefacturation
                                                                           then substitute("&1.&2"
                                                                                         , string(ttRefacturationRubrique.iCodeRubriqueQuitt,"999")
                                                                                         , string(ttRefacturationRubrique.iCodeLibelleRubriqueQuitt,"99"))
                                                                           else "")
                ttEdRefacturationDepense.cLibelleRubriqueQuittancement = (if not ttRefacturationRubrique.lRefacturation
                                                                            then ttRefacturationRubrique.cLibelleRubriqueQuitt
                                                                            else "")
                ttEdRefacturationDepense.dPourcentageLocataireMandat   = ttRefacturationRubrique.dPourcentageLocataire
                ttEdRefacturationDepense.iNumeroBail                   = ttRefacturationLocataire.iNumeroContrat
                ttEdRefacturationDepense.cNomLocataire                 = outilFormatage:getNomTiers({&TYPEROLE-locataire},ttRefacturationLocataire.iNumeroContrat)
                ttEdRefacturationDepense.dPourcentageLocataireBail     = ttRefacturationLocataire.dPourcentageLocataire

                ttEdRefacturationDepense.cLibelleNatureBail            = ttRefacturationLocataire.cLibelleNatureBail
            .
            for first sys_pg  no-lock
                where sys_pg.tppar = "R_CBA"
                  and sys_pg.zone2 = ttRefacturationLocataire.cNatureContrat:
                ttEdRefacturationDepense.cLibelleCategorieBail = outilTraduction:getLibelleProg("O_CBA", sys_pg.zone1).
            end.
        end. // ttEdRefacturationDepense.dPourcentageLocataireMandat > 0
    end. // for each ttRefacturationRubrique
end procedure.
