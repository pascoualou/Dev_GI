/*------------------------------------------------------------------------
File        : tportef_cadb_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table tportef_cadb
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/tportef_cadb.i}
{application/include/error.i}
define variable ghtttportef_cadb as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudTportef_cadb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTportef_cadb.
    run updateTportef_cadb.
    run createTportef_cadb.
end procedure.

procedure setTportef_cadb:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTportef_cadb.
    ghttTportef_cadb = phttTportef_cadb.
    run crudTportef_cadb.
    delete object phttTportef_cadb.
end procedure.

procedure readTportef_cadb:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table tportef_cadb 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTportef_cadb.
    define variable vhttBuffer as handle no-undo.
    define buffer tportef_cadb for tportef_cadb.

    vhttBuffer = phttTportef_cadb:default-buffer-handle.
    for first tportef_cadb no-lock
        where :
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tportef_cadb:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTportef_cadb no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTportef_cadb:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table tportef_cadb 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTportef_cadb.
    define variable vhttBuffer as handle  no-undo.
    define buffer tportef_cadb for tportef_cadb.

    vhttBuffer = phttTportef_cadb:default-buffer-handle.
    for each tportef_cadb no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tportef_cadb:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTportef_cadb no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTportef_cadb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer tportef_cadb for tportef_cadb.

    create query vhttquery.
    vhttBuffer = ghttTportef_cadb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTportef_cadb:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tportef_cadb exclusive-lock
                where rowid(tportef_cadb) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tportef_cadb:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer tportef_cadb:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTportef_cadb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer tportef_cadb for tportef_cadb.

    create query vhttquery.
    vhttBuffer = ghttTportef_cadb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTportef_cadb:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create tportef_cadb.
            if not outils:copyValidField(buffer tportef_cadb:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTportef_cadb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer tportef_cadb for tportef_cadb.

    create query vhttquery.
    vhttBuffer = ghttTportef_cadb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTportef_cadb:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tportef_cadb exclusive-lock
                where rowid(Tportef_cadb) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tportef_cadb:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete tportef_cadb no-error.
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

