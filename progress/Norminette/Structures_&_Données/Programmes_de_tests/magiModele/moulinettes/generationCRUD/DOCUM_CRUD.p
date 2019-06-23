/*------------------------------------------------------------------------
File        : DOCUM_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table DOCUM
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/DOCUM.i}
{application/include/error.i}
define variable ghttDOCUM as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudDocum private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDocum.
    run updateDocum.
    run createDocum.
end procedure.

procedure setDocum:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDocum.
    ghttDocum = phttDocum.
    run crudDocum.
    delete object phttDocum.
end procedure.

procedure readDocum:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table DOCUM Document
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNodoc as int64      no-undo.
    define input parameter table-handle phttDocum.
    define variable vhttBuffer as handle no-undo.
    define buffer DOCUM for DOCUM.

    vhttBuffer = phttDocum:default-buffer-handle.
    for first DOCUM no-lock
        where DOCUM.nodoc = piNodoc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DOCUM:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDocum no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDocum:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table DOCUM Document
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDocum.
    define variable vhttBuffer as handle  no-undo.
    define buffer DOCUM for DOCUM.

    vhttBuffer = phttDocum:default-buffer-handle.
    for each DOCUM no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DOCUM:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDocum no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDocum private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNodoc    as handle  no-undo.
    define buffer DOCUM for DOCUM.

    create query vhttquery.
    vhttBuffer = ghttDocum:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDocum:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNodoc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DOCUM exclusive-lock
                where rowid(DOCUM) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DOCUM:handle, 'nodoc: ', substitute('&1', vhNodoc:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer DOCUM:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDocum private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer DOCUM for DOCUM.

    create query vhttquery.
    vhttBuffer = ghttDocum:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDocum:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create DOCUM.
            if not outils:copyValidField(buffer DOCUM:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDocum private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNodoc    as handle  no-undo.
    define buffer DOCUM for DOCUM.

    create query vhttquery.
    vhttBuffer = ghttDocum:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDocum:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNodoc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DOCUM exclusive-lock
                where rowid(Docum) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DOCUM:handle, 'nodoc: ', substitute('&1', vhNodoc:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete DOCUM no-error.
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

