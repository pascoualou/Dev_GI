/*------------------------------------------------------------------------
File        : igeddoc_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table igeddoc
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/igeddoc.i}
{application/include/error.i}
define variable ghttigeddoc as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phId-fich as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur id-fich, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'id-fich' then phId-fich = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIgeddoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIgeddoc.
    run updateIgeddoc.
    run createIgeddoc.
end procedure.

procedure setIgeddoc:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIgeddoc.
    ghttIgeddoc = phttIgeddoc.
    run crudIgeddoc.
    delete object phttIgeddoc.
end procedure.

procedure readIgeddoc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table igeddoc ged : documents
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piId-fich as int64      no-undo.
    define input parameter table-handle phttIgeddoc.
    define variable vhttBuffer as handle no-undo.
    define buffer igeddoc for igeddoc.

    vhttBuffer = phttIgeddoc:default-buffer-handle.
    for first igeddoc no-lock
        where igeddoc.id-fich = piId-fich:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer igeddoc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIgeddoc no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIgeddoc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table igeddoc ged : documents
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIgeddoc.
    define variable vhttBuffer as handle  no-undo.
    define buffer igeddoc for igeddoc.

    vhttBuffer = phttIgeddoc:default-buffer-handle.
    for each igeddoc no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer igeddoc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIgeddoc no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIgeddoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhId-fich    as handle  no-undo.
    define buffer igeddoc for igeddoc.

    create query vhttquery.
    vhttBuffer = ghttIgeddoc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIgeddoc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhId-fich).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first igeddoc exclusive-lock
                where rowid(igeddoc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer igeddoc:handle, 'id-fich: ', substitute('&1', vhId-fich:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer igeddoc:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIgeddoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer igeddoc for igeddoc.

    create query vhttquery.
    vhttBuffer = ghttIgeddoc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIgeddoc:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create igeddoc.
            if not outils:copyValidField(buffer igeddoc:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIgeddoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhId-fich    as handle  no-undo.
    define buffer igeddoc for igeddoc.

    create query vhttquery.
    vhttBuffer = ghttIgeddoc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIgeddoc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhId-fich).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first igeddoc exclusive-lock
                where rowid(Igeddoc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer igeddoc:handle, 'id-fich: ', substitute('&1', vhId-fich:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete igeddoc no-error.
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

