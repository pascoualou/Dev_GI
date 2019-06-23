/*------------------------------------------------------------------------
File        : paramUsagesUL.p
Purpose     : gestion des usages par UL
Author(s)   : GGA  2017/08/21
Notes       : a partir de adb/prmcl/pclcdusa.p
------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2role.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{tache/include/usageUL.i}
{tache/include/correspondanceUsageNatureUL.i}
{application/include/glbsepar.i}

procedure getUsageUL:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define output parameter table for ttUsageUL.
    define output parameter table for ttCorrespondanceUsageNatureUL.

    define buffer usage   for usage.
    define buffer vbusage for usage.

    empty temp-table ttUsageUL.
    empty temp-table ttCorrespondanceUsageNatureUL.
    for each usage no-lock
       where usage.ntapp = "00000":
        create ttUsageUL.
        assign
            ttUsageUL.cCodeUsage    = usage.cdusa
            ttUsageUL.cLibelleUsage = usage.lbusa
            ttUsageUL.CRUD          = "R"
            ttUsageUL.dtTimestamp   = datetime(usage.dtmsy, usage.hemsy)
            ttUsageUL.rRowid        = rowid(usage)
        .
        {&_proparse_ prolint-nowarn(wholeindex)}
        for each vbusage no-lock      // todo - whole index - Dauchez = 27 enregistrements - pas beaucoup!
           where vbusage.ntapp <> "00000"
             and vbusage.cdusa = usage.cdusa:
            create ttCorrespondanceUsageNatureUL.
            assign
                ttCorrespondanceUsageNatureUL.cCodeUsage       = vbusage.cdusa
                ttCorrespondanceUsageNatureUL.cCodeNatureUL    = vbusage.ntapp
                ttCorrespondanceUsageNatureUL.cLibelleNatureUL = outilTraduction:getLibelleParam("NTAPP", vbusage.ntapp)
                ttCorrespondanceUsageNatureUL.CRUD             = "R"
                ttCorrespondanceUsageNatureUL.dtTimestamp      = datetime(vbusage.dtmsy, vbusage.hemsy)
                ttCorrespondanceUsageNatureUL.rRowid           = rowid(vbusage)
            .
        end.
    end.

end procedure.

procedure setUsageUL:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttUsageUL.
    define input parameter table for ttCorrespondanceUsageNatureUL.

    define buffer usage for usage.

    //controle avant maj
    for each ttUsageUL
        where lookup(ttUsageUL.CRUD, "C,U,D") > 0:
        if ttUsageUL.CRUD = "C"
        and can-find(first usage no-lock
                     where usage.ntapp = "00000"
                       and usage.cdusa = ttUsageUL.cCodeUsage)
        then do:
            mError:createError({&error}, 1000474, ttUsageUL.cCodeUsage).  //Création code usage &1 déjà existant impossible
            return.
        end.
        if lookup(ttUsageUL.CRUD, "U,D") > 0
        and not can-find (first usage no-lock
                          where usage.ntapp = "00000"
                            and usage.cdusa = ttUsageUL.cCodeUsage)
        then do:
            mError:createError({&error}, 1000473, ttUsageUL.cCodeUsage). //modification code usage &1 inexistant impossible
            return.
        end.
        if ttUsageUL.CRUD = "D"
        and can-find(first unite no-lock    // todo - whole index - Dauchez = 50000 enregistrements
                     where unite.cdusa = ttUsageUL.cCodeUsage)
        then do:
            mError:createError({&error}, "110893").          //Impossible de supprimer cet usage car il est utilisé dans au moins 1 UL.
            return.
        end.
    end.
    for each ttCorrespondanceUsageNatureUL
        where lookup(ttCorrespondanceUsageNatureUL.CRUD, "C,D") > 0:
        if ttCorrespondanceUsageNatureUL.CRUD = "C"
        then do:
            if can-find (first usage no-lock
                         where usage.ntapp = ttCorrespondanceUsageNatureUL.cCodeNatureUL
                           and usage.cdusa = ttCorrespondanceUsageNatureUL.cCodeUsage)
            then do:
                mError:createError({&error}, 1000475, substitute("&2&1&3", separ[1], ttCorrespondanceUsageNatureUL.cCodeUsage, ttCorrespondanceUsageNatureUL.cCodeNatureUL)). //Création correspondance usage &1 nature &2 déjà existant impossible
                return.
            end.
            if not can-find(first sys_pr no-lock
                            where sys_pr.tppar = "NTAPP"
                              and sys_pr.cdpar = ttCorrespondanceUsageNatureUL.cCodeNatureUL)
            then do:
                mError:createError({&error}, 1000477, ttCorrespondanceUsageNatureUL.cCodeNatureUL). //Code nature &1 inexistant
                return.
            end.
        end.
        else if ttCorrespondanceUsageNatureUL.CRUD = "D"
        then do:
            if not can-find (first usage no-lock
                             where usage.ntapp = "00000"
                               and usage.cdusa = ttCorrespondanceUsageNatureUL.cCodeUsage)
            then do:
                mError:createError({&error}, 1000476, substitute("&2&1&3", separ[1], ttCorrespondanceUsageNatureUL.cCodeUsage, ttCorrespondanceUsageNatureUL.cCodeNatureUL)). //Suppression correspondance usage &1 nature &2 inexistant impossible
                
                return.
            end.
            if can-find(first unite no-lock      // todo - whole index - Dauchez = 50000 enregistrements
                        where unite.cdcmp = ttCorrespondanceUsageNatureUL.cCodeNatureUL
                          and unite.cdusa = ttCorrespondanceUsageNatureUL.cCodeUsage
                          and unite.noact = 0)
            then do:
                mError:createError({&error}, "110893").          //Impossible de supprimer cet usage car il est utilisé dans au moins 1 UL.
                return.
            end.
        end.
    end.

    //maj table usage
blocTrans:
    do transaction:
        for each ttUsageUL
            where lookup(ttUsageUL.CRUD, "C,U,D") > 0:
            if ttUsageUL.CRUD = "C"
            then do:
                create usage.
                assign
                    usage.ntapp = "00000"
                    usage.cdusa = ttUsageUL.cCodeUsage
                no-error.
                if error-status:error then do:
                    mError:createError({&error},  error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.
                if not outils:copyValidLabeledField(buffer usage:handle, buffer ttUsageUL:handle, 'C', mtoken:cUser)
                then undo blocTrans, leave blocTrans.
            end.
            else do:
                find first usage exclusive-lock
                    where rowid(usage) = ttUsageUl.rRowid no-wait no-error.
                if outils:isUpdated(buffer usage:handle, 'usage : ', substitute('&1', ttUsageUL.cCodeUsage), ttUsageUL.dtTimestamp)
                or (ttUsageUL.CRUD = "U"
                  and not outils:copyValidLabeledField(buffer usage:handle, buffer ttUsageUL:handle, 'U', mtoken:cUser))
                then undo blocTrans, leave blocTrans.

                if ttUsageUL.CRUD = "D"
                then do:
                    delete usage no-error.
                    if error-status:error then do:
                        mError:createError({&error},  error-status:get-message(1)).
                        undo blocTrans, leave blocTrans.
                    end.
                    {&_proparse_ prolint-nowarn(wholeindex)}
                    for each usage exclusive-lock      // todo - whole index - Dauchez = 27 enregistrements - pas beaucoup!
                        where usage.cdusa = ttUsageUL.cCodeUsage:
                        delete usage no-error.
                        if error-status:error then do:
                            mError:createError({&error},  error-status:get-message(1)).
                            undo blocTrans, leave blocTrans.
                        end.
                    end.
                end.
            end.
        end.
        for each ttCorrespondanceUsageNatureUL
            where lookup(ttCorrespondanceUsageNatureUL.CRUD, "C,D") > 0:
            if ttCorrespondanceUsageNatureUL.CRUD = "C"
            then do:
                create usage.
                assign
                    usage.ntapp = ttCorrespondanceUsageNatureUL.cCodeNatureUL
                    usage.cdusa = ttCorrespondanceUsageNatureUL.cCodeUsage
                no-error.
                if error-status:error then do:
                    mError:createError({&error},  error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.
                if not outils:copyValidLabeledField(buffer usage:handle, buffer ttCorrespondanceUsageNatureUL:handle, 'C', mtoken:cUser)
                then undo blocTrans, leave blocTrans.
            end.
            else do:
                find first usage exclusive-lock
                    where rowid(usage) = ttCorrespondanceUsageNatureUL.rRowid no-wait no-error.
                if outils:isUpdated(buffer usage:handle, 'usage : ', substitute('&1', ttCorrespondanceUsageNatureUL.cCodeUsage), ttCorrespondanceUsageNatureUL.dtTimestamp)
                then undo blocTrans, leave blocTrans.
                delete usage no-error.
                if error-status:error then do:
                    mError:createError({&error},  error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.
            end.
        end.
    end.

end procedure.
