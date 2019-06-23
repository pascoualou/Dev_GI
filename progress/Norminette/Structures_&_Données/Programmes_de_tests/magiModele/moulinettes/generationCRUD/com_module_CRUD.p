/*------------------------------------------------------------------------
File        : com_module_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table com_module
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/com_module.i}
{application/include/error.i}
define variable ghttcom_module as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudCom_module private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCom_module.
    run updateCom_module.
    run createCom_module.
end procedure.

procedure setCom_module:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCom_module.
    ghttCom_module = phttCom_module.
    run crudCom_module.
    delete object phttCom_module.
end procedure.

procedure readCom_module:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table com_module 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCom_module.
    define variable vhttBuffer as handle no-undo.
    define buffer com_module for com_module.

    vhttBuffer = phttCom_module:default-buffer-handle.
    for first com_module no-lock
        where :
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer com_module:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCom_module no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCom_module:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table com_module 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCom_module.
    define variable vhttBuffer as handle  no-undo.
    define buffer com_module for com_module.

    vhttBuffer = phttCom_module:default-buffer-handle.
    for each com_module no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer com_module:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCom_module no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCom_module private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer com_module for com_module.

    create query vhttquery.
    vhttBuffer = ghttCom_module:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCom_module:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first com_module exclusive-lock
                where rowid(com_module) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer com_module:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer com_module:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCom_module private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer com_module for com_module.

    create query vhttquery.
    vhttBuffer = ghttCom_module:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCom_module:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create com_module.
            if not outils:copyValidField(buffer com_module:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCom_module private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer com_module for com_module.

    create query vhttquery.
    vhttBuffer = ghttCom_module:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCom_module:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first com_module exclusive-lock
                where rowid(Com_module) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer com_module:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete com_module no-error.
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

