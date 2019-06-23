/*------------------------------------------------------------------------
File        : piedp_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table piedp
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/piedp.i}
{application/include/error.i}
define variable ghttpiedp as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudPiedp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePiedp.
    run updatePiedp.
    run createPiedp.
end procedure.

procedure setPiedp:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPiedp.
    ghttPiedp = phttPiedp.
    run crudPiedp.
    delete object phttPiedp.
end procedure.

procedure readPiedp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table piedp Stocke les pieds de page utilises pour les impressions word
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPiedp.
    define variable vhttBuffer as handle no-undo.
    define buffer piedp for piedp.

    vhttBuffer = phttPiedp:default-buffer-handle.
    for first piedp no-lock
        where :
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer piedp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPiedp no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPiedp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table piedp Stocke les pieds de page utilises pour les impressions word
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPiedp.
    define variable vhttBuffer as handle  no-undo.
    define buffer piedp for piedp.

    vhttBuffer = phttPiedp:default-buffer-handle.
    for each piedp no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer piedp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPiedp no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePiedp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer piedp for piedp.

    create query vhttquery.
    vhttBuffer = ghttPiedp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPiedp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first piedp exclusive-lock
                where rowid(piedp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer piedp:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer piedp:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPiedp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer piedp for piedp.

    create query vhttquery.
    vhttBuffer = ghttPiedp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPiedp:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create piedp.
            if not outils:copyValidField(buffer piedp:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePiedp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer piedp for piedp.

    create query vhttquery.
    vhttBuffer = ghttPiedp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPiedp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first piedp exclusive-lock
                where rowid(Piedp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer piedp:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete piedp no-error.
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

