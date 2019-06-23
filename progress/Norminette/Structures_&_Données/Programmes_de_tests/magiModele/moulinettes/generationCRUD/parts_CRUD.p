/*------------------------------------------------------------------------
File        : parts_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table parts
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/parts.i}
{application/include/error.i}
define variable ghttparts as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudParts private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteParts.
    run updateParts.
    run createParts.
end procedure.

procedure setParts:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttParts.
    ghttParts = phttParts.
    run crudParts.
    delete object phttParts.
end procedure.

procedure readParts:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table parts 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttParts.
    define variable vhttBuffer as handle no-undo.
    define buffer parts for parts.

    vhttBuffer = phttParts:default-buffer-handle.
    for first parts no-lock
        where :
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer parts:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttParts no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getParts:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table parts 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttParts.
    define variable vhttBuffer as handle  no-undo.
    define buffer parts for parts.

    vhttBuffer = phttParts:default-buffer-handle.
    for each parts no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer parts:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttParts no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateParts private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer parts for parts.

    create query vhttquery.
    vhttBuffer = ghttParts:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttParts:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first parts exclusive-lock
                where rowid(parts) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer parts:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer parts:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createParts private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer parts for parts.

    create query vhttquery.
    vhttBuffer = ghttParts:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttParts:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create parts.
            if not outils:copyValidField(buffer parts:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteParts private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer parts for parts.

    create query vhttquery.
    vhttBuffer = ghttParts:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttParts:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first parts exclusive-lock
                where rowid(Parts) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer parts:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete parts no-error.
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

