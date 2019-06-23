/*------------------------------------------------------------------------
File        : ebupr_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ebupr
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ebupr.i}
{application/include/error.i}
define variable ghttebupr as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNobud as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nobud, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nobud' then phNobud = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEbupr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEbupr.
    run updateEbupr.
    run createEbupr.
end procedure.

procedure setEbupr:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEbupr.
    ghttEbupr = phttEbupr.
    run crudEbupr.
    delete object phttEbupr.
end procedure.

procedure readEbupr:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ebupr budgets prévisionnels non validés
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNobud as int64      no-undo.
    define input parameter table-handle phttEbupr.
    define variable vhttBuffer as handle no-undo.
    define buffer ebupr for ebupr.

    vhttBuffer = phttEbupr:default-buffer-handle.
    for first ebupr no-lock
        where ebupr.nobud = piNobud:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ebupr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEbupr no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEbupr:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ebupr budgets prévisionnels non validés
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEbupr.
    define variable vhttBuffer as handle  no-undo.
    define buffer ebupr for ebupr.

    vhttBuffer = phttEbupr:default-buffer-handle.
    for each ebupr no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ebupr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEbupr no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEbupr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNobud    as handle  no-undo.
    define buffer ebupr for ebupr.

    create query vhttquery.
    vhttBuffer = ghttEbupr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEbupr:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNobud).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ebupr exclusive-lock
                where rowid(ebupr) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ebupr:handle, 'nobud: ', substitute('&1', vhNobud:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ebupr:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEbupr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ebupr for ebupr.

    create query vhttquery.
    vhttBuffer = ghttEbupr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEbupr:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ebupr.
            if not outils:copyValidField(buffer ebupr:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEbupr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNobud    as handle  no-undo.
    define buffer ebupr for ebupr.

    create query vhttquery.
    vhttBuffer = ghttEbupr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEbupr:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNobud).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ebupr exclusive-lock
                where rowid(Ebupr) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ebupr:handle, 'nobud: ', substitute('&1', vhNobud:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ebupr no-error.
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

