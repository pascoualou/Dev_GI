/*------------------------------------------------------------------------
File        : aquit_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table aquit
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/05/14 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttaquit as handle no-undo.     // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phNoloc as handle, output phNoqtt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noint, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noloc' then phNoloc = phBuffer:buffer-field(vi).
            when 'noqtt' then phNoqtt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAquit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAquit.
    run updateAquit.
    run createAquit.
end procedure.

procedure setAquit:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAquit.
    ghttAquit = phttAquit.
    run crudAquit.
    delete object phttAquit.
end procedure.

procedure readAquit:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table aquit 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoloc as int64    no-undo.
    define input parameter piNoqtt as integer  no-undo.
    define input parameter table-handle phttAquit.

    define variable vhttBuffer as handle no-undo.
    define buffer aquit for aquit.

    vhttBuffer = phttAquit:default-buffer-handle.
    for first aquit no-lock
        where aquit.noloc = piNoloc
          and aquit.noqtt = piNoqtt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aquit:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAquit no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAquit:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table aquit pour un locataire ou un historique locataire
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter piNoloc as int64    no-undo.
    define input parameter piMsqtt as integer  no-undo.
    define input parameter table-handle phttAquit.

    define variable vhttBuffer as handle  no-undo.
    define buffer aquit for aquit.

    vhttBuffer = phttAquit:default-buffer-handle.
    if piMsqtt = ?
    then for each aquit no-lock
        where aquit.noloc = piNoloc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aquit:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each aquit no-lock     // un historique locataire
        where aquit.noloc = piNoloc
          and aquit.msqtt > piMsqtt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aquit:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAquit no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAquit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define variable vhNoqtt    as handle  no-undo.
    define buffer aquit for aquit.

    create query vhttquery.
    vhttBuffer = ghttAquit:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAquit:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoloc, output vhNoqtt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aquit exclusive-lock
                where rowid(aquit) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aquit:handle, 'noloc/noqtt: ', substitute('&1/&2', vhNoloc:buffer-value(), vhNoqtt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer aquit:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAquit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer aquit for aquit.

    create query vhttquery.
    vhttBuffer = ghttAquit:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAquit:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create aquit.
            if not outils:copyValidField(buffer aquit:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAquit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define variable vhNoqtt    as handle  no-undo.
    define buffer aquit for aquit.

    create query vhttquery.
    vhttBuffer = ghttAquit:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAquit:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoloc, output vhNoqtt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aquit exclusive-lock
                where rowid(Aquit) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aquit:handle, 'noloc/noqtt: ', substitute('&1/&2', vhNoloc:buffer-value(), vhNoqtt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete aquit no-error.
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

procedure deleteAquitSurMandat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64     no-undo.
    
    define buffer aquit for aquit.

blocTrans:
    do transaction:
        for each aquit exclusive-lock
            where aquit.nomdt = piNumeroMandat:
            delete aquit no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.            
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

procedure deleteAquitSurLocataire:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroLocataire as int64 no-undo.
    
    define buffer aquit for aquit.

blocTrans:
    do transaction:
        for each aquit exclusive-lock
            where aquit.noloc = piNumeroLocataire:
            delete aquit no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.            
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
