/*------------------------------------------------------------------------
File        : pquit_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table pquit
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/pquit.i}
{application/include/error.i}
define variable ghttpquit as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudPquit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePquit.
    run updatePquit.
    run createPquit.
end procedure.

procedure setPquit:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPquit.
    ghttPquit = phttPquit.
    run crudPquit.
    delete object phttPquit.
end procedure.

procedure readPquit:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table pquit 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoint as int64      no-undo.
    define input parameter table-handle phttPquit.
    define variable vhttBuffer as handle no-undo.
    define buffer pquit for pquit.

    vhttBuffer = phttPquit:default-buffer-handle.
    for first pquit no-lock
        where pquit.noint = piNoint:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pquit:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPquit no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPquit:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table pquit 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPquit.
    define variable vhttBuffer as handle  no-undo.
    define buffer pquit for pquit.

    vhttBuffer = phttPquit:default-buffer-handle.
    for each pquit no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pquit:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPquit no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePquit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoint    as handle  no-undo.
    define buffer pquit for pquit.

    create query vhttquery.
    vhttBuffer = ghttPquit:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPquit:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoint).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pquit exclusive-lock
                where rowid(pquit) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pquit:handle, 'noint: ', substitute('&1', vhNoint:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer pquit:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPquit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer pquit for pquit.

    create query vhttquery.
    vhttBuffer = ghttPquit:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPquit:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create pquit.
            if not outils:copyValidField(buffer pquit:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePquit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoint    as handle  no-undo.
    define buffer pquit for pquit.

    create query vhttquery.
    vhttBuffer = ghttPquit:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPquit:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoint).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pquit exclusive-lock
                where rowid(Pquit) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pquit:handle, 'noint: ', substitute('&1', vhNoint:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete pquit no-error.
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

procedure deletePquitSurNoloc:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroLocataire as int64 no-undo.
    
    define buffer pquit for pquit.

message "deletePquitSurNoloc " piNumeroLocataire . 

blocTrans:
    do transaction:
        for each pquit exclusive-lock
           where pquit.noloc = piNumeroLocataire:
            delete pquit no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

