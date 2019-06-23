/*------------------------------------------------------------------------
File        : trf_module_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table trf_module
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/trf_module.i}
{application/include/error.i}
define variable ghtttrf_module as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur , 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
       end case.
    end.
end function.

procedure crudTrf_module private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTrf_module.
    run updateTrf_module.
    run createTrf_module.
end procedure.

procedure setTrf_module:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTrf_module.
    ghttTrf_module = phttTrf_module.
    run crudTrf_module.
    delete object phttTrf_module.
end procedure.

procedure readTrf_module:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table trf_module 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTrf_module.
    define variable vhttBuffer as handle no-undo.
    define buffer trf_module for trf_module.

    vhttBuffer = phttTrf_module:default-buffer-handle.
    for first trf_module no-lock
        where :
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trf_module:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrf_module no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTrf_module:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table trf_module 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTrf_module.
    define variable vhttBuffer as handle  no-undo.
    define buffer trf_module for trf_module.

    vhttBuffer = phttTrf_module:default-buffer-handle.
    for each trf_module no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trf_module:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrf_module no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTrf_module private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer trf_module for trf_module.

    create query vhttquery.
    vhttBuffer = ghttTrf_module:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTrf_module:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first trf_module exclusive-lock
                where rowid(trf_module) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trf_module:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer trf_module:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTrf_module private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer trf_module for trf_module.

    create query vhttquery.
    vhttBuffer = ghttTrf_module:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTrf_module:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create trf_module.
            if not outils:copyValidField(buffer trf_module:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTrf_module private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer trf_module for trf_module.

    create query vhttquery.
    vhttBuffer = ghttTrf_module:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTrf_module:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first trf_module exclusive-lock
                where rowid(Trf_module) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trf_module:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete trf_module no-error.
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

