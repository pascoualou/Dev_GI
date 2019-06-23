/*------------------------------------------------------------------------
File        : ctanx_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ctanx
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ctanx.i}
{application/include/error.i}
define variable ghttctanx as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNodoc as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nodoc, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nodoc' then phNodoc = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCtanx private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCtanx.
    run updateCtanx.
    run createCtanx.
end procedure.

procedure setCtanx:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCtanx.
    ghttCtanx = phttCtanx.
    run crudCtanx.
    delete object phttCtanx.
end procedure.

procedure readCtanx:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ctanx 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNodoc as int64      no-undo.
    define input parameter table-handle phttCtanx.
    define variable vhttBuffer as handle no-undo.
    define buffer ctanx for ctanx.

    vhttBuffer = phttCtanx:default-buffer-handle.
    for first ctanx no-lock
        where ctanx.nodoc = piNodoc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ctanx:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCtanx no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCtanx:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ctanx 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCtanx.
    define variable vhttBuffer as handle  no-undo.
    define buffer ctanx for ctanx.

    vhttBuffer = phttCtanx:default-buffer-handle.
    for each ctanx no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ctanx:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCtanx no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCtanx private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNodoc    as handle  no-undo.
    define buffer ctanx for ctanx.

    create query vhttquery.
    vhttBuffer = ghttCtanx:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCtanx:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNodoc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ctanx exclusive-lock
                where rowid(ctanx) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ctanx:handle, 'nodoc: ', substitute('&1', vhNodoc:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ctanx:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCtanx private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ctanx for ctanx.

    create query vhttquery.
    vhttBuffer = ghttCtanx:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCtanx:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ctanx.
            if not outils:copyValidField(buffer ctanx:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCtanx private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNodoc    as handle  no-undo.
    define buffer ctanx for ctanx.

    create query vhttquery.
    vhttBuffer = ghttCtanx:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCtanx:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNodoc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ctanx exclusive-lock
                where rowid(Ctanx) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ctanx:handle, 'nodoc: ', substitute('&1', vhNodoc:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ctanx no-error.
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

