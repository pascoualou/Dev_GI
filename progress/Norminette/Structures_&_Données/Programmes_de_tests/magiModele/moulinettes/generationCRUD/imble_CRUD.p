/*------------------------------------------------------------------------
File        : imble_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table imble
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/imble.i}
{application/include/error.i}
define variable ghttimble as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoimm as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noimm, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noimm' then phNoimm = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudImble private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteImble.
    run updateImble.
    run createImble.
end procedure.

procedure setImble:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttImble.
    ghttImble = phttImble.
    run crudImble.
    delete object phttImble.
end procedure.

procedure readImble:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table imble 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer    no-undo.
    define input parameter table-handle phttImble.
    define variable vhttBuffer as handle no-undo.
    define buffer imble for imble.

    vhttBuffer = phttImble:default-buffer-handle.
    for first imble no-lock
        where imble.noimm = piNoimm:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer imble:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttImble no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getImble:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table imble 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttImble.
    define variable vhttBuffer as handle  no-undo.
    define buffer imble for imble.

    vhttBuffer = phttImble:default-buffer-handle.
    for each imble no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer imble:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttImble no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateImble private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoimm    as handle  no-undo.
    define buffer imble for imble.

    create query vhttquery.
    vhttBuffer = ghttImble:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttImble:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first imble exclusive-lock
                where rowid(imble) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer imble:handle, 'noimm: ', substitute('&1', vhNoimm:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer imble:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createImble private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer imble for imble.

    create query vhttquery.
    vhttBuffer = ghttImble:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttImble:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create imble.
            if not outils:copyValidField(buffer imble:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteImble private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoimm    as handle  no-undo.
    define buffer imble for imble.

    create query vhttquery.
    vhttBuffer = ghttImble:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttImble:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first imble exclusive-lock
                where rowid(Imble) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer imble:handle, 'noimm: ', substitute('&1', vhNoimm:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete imble no-error.
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

