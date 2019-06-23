/*------------------------------------------------------------------------
File        : aquit_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table aquit
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/aquit.i}
{application/include/error.i}
define variable ghttaquit as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoint as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noint, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noint' then phNoint = phBuffer:buffer-field(vi).
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
    define input parameter piNoint as int64      no-undo.
    define input parameter table-handle phttAquit.
    define variable vhttBuffer as handle no-undo.
    define buffer aquit for aquit.

    vhttBuffer = phttAquit:default-buffer-handle.
    for first aquit no-lock
        where aquit.noint = piNoint:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aquit:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAquit no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAquit:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table aquit 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAquit.
    define variable vhttBuffer as handle  no-undo.
    define buffer aquit for aquit.

    vhttBuffer = phttAquit:default-buffer-handle.
    for each aquit no-lock:
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
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoint    as handle  no-undo.
    define buffer aquit for aquit.

    create query vhttquery.
    vhttBuffer = ghttAquit:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAquit:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoint).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aquit exclusive-lock
                where rowid(aquit) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aquit:handle, 'noint: ', substitute('&1', vhNoint:buffer-value()), vhttBuffer::dtTimestamp)
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
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
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
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoint    as handle  no-undo.
    define buffer aquit for aquit.

    create query vhttquery.
    vhttBuffer = ghttAquit:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAquit:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoint).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aquit exclusive-lock
                where rowid(Aquit) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aquit:handle, 'noint: ', substitute('&1', vhNoint:buffer-value()), vhttBuffer::dtTimestamp)
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

