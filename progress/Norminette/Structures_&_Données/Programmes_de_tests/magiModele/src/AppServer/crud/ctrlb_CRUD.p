/*------------------------------------------------------------------------
File        : ctrlb_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise a jour de la table ctrlb
Author(s)   : gga - 2017/09/11
Notes       : repris depuis adb/lib/l_ctrlb.p.
derniere revue: 2018/06/18 - phm: OK
------------------------------------------------------------------------*/
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

define variable ghttCtrlb as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phTpctt as handle, output phNoctt as handle, output phTpid1 as handle, output phNoid1 as handle, output phTpid2 as handle, output phNoid2 as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpctt/noctt/tpid1/noid1/tpid2/noid2, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpctt' then phTpctt = phBuffer:buffer-field(vi).
            when 'noctt' then phNoctt = phBuffer:buffer-field(vi).
            when 'tpid1' then phTpid1 = phBuffer:buffer-field(vi).
            when 'noid1' then phNoid1 = phBuffer:buffer-field(vi).
            when 'tpid2' then phTpid2 = phBuffer:buffer-field(vi).
            when 'noid2' then phNoid2 = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCtrlb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/
    run deleteCtrlb.
    run updateCtrlb.
    run createCtrlb.
end procedure.

procedure setCtrlb:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCtrlb.
    ghttCtrlb = phttCtrlb.
    run crudCtrlb.
    delete object phttCtrlb.
end procedure.

procedure readCtrlb:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ctrlb 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpctt as character no-undo.
    define input parameter piNoctt as int64     no-undo.
    define input parameter pcTpid1 as character no-undo.
    define input parameter piNoid1 as int64     no-undo.
    define input parameter pcTpid2 as character no-undo.
    define input parameter piNoid2 as int64     no-undo.
    define input parameter table-handle phttCtrlb.

    define variable vhttBuffer as handle no-undo.
    define buffer ctrlb for ctrlb.

    vhttBuffer = phttCtrlb:default-buffer-handle.
    for first ctrlb no-lock
        where ctrlb.tpctt = pcTpctt
          and ctrlb.noctt = piNoctt
          and ctrlb.tpid1 = pcTpid1
          and ctrlb.noid1 = piNoid1
          and ctrlb.tpid2 = pcTpid2
          and ctrlb.noid2 = piNoid2:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ctrlb:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCtrlb no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCtrlb:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ctrlb 
    Notes  : service externe. Critère pcTpid2 = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpctt as character no-undo.
    define input parameter piNoctt as int64     no-undo.
    define input parameter pcTpid1 as character no-undo.
    define input parameter piNoid1 as int64     no-undo.
    define input parameter pcTpid2 as character no-undo.
    define input parameter table-handle phttCtrlb.

    define variable vhttBuffer as handle  no-undo.
    define buffer ctrlb for ctrlb.

    vhttBuffer = phttCtrlb:default-buffer-handle.
    if pcTpid2 = ?
    then for each ctrlb no-lock
        where ctrlb.tpctt = pcTpctt
          and ctrlb.noctt = piNoctt
          and ctrlb.tpid1 = pcTpid1
          and ctrlb.noid1 = piNoid1:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ctrlb:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ctrlb no-lock
        where ctrlb.tpctt = pcTpctt
          and ctrlb.noctt = piNoctt
          and ctrlb.tpid1 = pcTpid1
          and ctrlb.noid1 = piNoid1
          and ctrlb.tpid2 = pcTpid2:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ctrlb:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCtrlb no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCtrlb private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure pour la mise a jour de la table ctrlb
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpctt    as handle  no-undo.
    define variable vhNoctt    as handle  no-undo.
    define variable vhTpid1    as handle  no-undo.
    define variable vhNoid1    as handle  no-undo.
    define variable vhTpid2    as handle  no-undo.
    define variable vhNoid2    as handle  no-undo.
    define buffer ctrlb for ctrlb.

    create query vhttquery.
    vhttBuffer = ghttCtrlb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCtrlb:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpctt, output vhNoctt, output vhTpid1, output vhNoid1, output vhTpid2, output vhNoid2).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ctrlb exclusive-lock
                where rowid(ctrlb) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ctrlb:handle, 'tpctt/noctt/tpid1/noid1/tpid2/noid2: ', substitute('&1/&2/&3/&4/&5/&6', vhTpctt:buffer-value(), vhNoctt:buffer-value(), vhTpid1:buffer-value(), vhNoid1:buffer-value(), vhTpid2:buffer-value(), vhNoid2:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ctrlb:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCtrlb private:
    /*------------------------------------------------------------------------------
    Purpose: Création dans la table ctrlb.
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer ctrlb for ctrlb.

    create query vhttquery.
    vhttBuffer = ghttCtrlb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCtrlb:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ctrlb.
            if not outils:copyValidField(buffer ctrlb:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCtrlb private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure pour la suppression d'enregistrements de la table ctrlb
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpctt    as handle  no-undo.
    define variable vhNoctt    as handle  no-undo.
    define variable vhTpid1    as handle  no-undo.
    define variable vhNoid1    as handle  no-undo.
    define variable vhTpid2    as handle  no-undo.
    define variable vhNoid2    as handle  no-undo.
    define buffer ctrlb for ctrlb.

    create query vhttquery.
    vhttBuffer = ghttCtrlb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCtrlb:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpctt, output vhNoctt, output vhTpid1, output vhNoid1, output vhTpid2, output vhNoid2).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ctrlb exclusive-lock
                where rowid(Ctrlb) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ctrlb:handle, 'tpctt/noctt/tpid1/noid1/tpid2/noid2: ', substitute('&1/&2/&3/&4/&5/&6', vhTpctt:buffer-value(), vhNoctt:buffer-value(), vhTpid1:buffer-value(), vhNoid1:buffer-value(), vhTpid2:buffer-value(), vhNoid2:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ctrlb no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCtrlbSurIdentifiant:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeIdentifiant1   as character no-undo.
    define input parameter piNumeroIdentifiant1 as integer   no-undo.
    
    define buffer ctrlb for ctrlb.

blocTrans:
    do transaction:
        for each ctrlb exclusive-lock
            where ctrlb.tpid1 = pcTypeIdentifiant1
              and ctrlb.noid1 = piNumeroIdentifiant1:
            delete ctrlb no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

procedure deleteCtrlbSurContratMaitre:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.

    define buffer ctrlb for ctrlb.

blocTrans:
    do transaction:
        for each ctrlb exclusive-lock   
            where ctrlb.tpctt = pcTypeContrat
              and ctrlb.noctt = piNumeroContrat:
            delete ctrlb no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
