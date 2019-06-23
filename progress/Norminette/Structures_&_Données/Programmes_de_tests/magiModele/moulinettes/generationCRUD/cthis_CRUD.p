/*------------------------------------------------------------------------
File        : cthis_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cthis
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cthis.i}
{application/include/error.i}
define variable ghttcthis as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudCthis private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCthis.
    run updateCthis.
    run createCthis.
end procedure.

procedure setCthis:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCthis.
    ghttCthis = phttCthis.
    run crudCthis.
    delete object phttCthis.
end procedure.

procedure readCthis:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cthis 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNodoc as integer    no-undo.
    define input parameter table-handle phttCthis.
    define variable vhttBuffer as handle no-undo.
    define buffer cthis for cthis.

    vhttBuffer = phttCthis:default-buffer-handle.
    for first cthis no-lock
        where cthis.nodoc = piNodoc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cthis:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCthis no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCthis:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cthis 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCthis.
    define variable vhttBuffer as handle  no-undo.
    define buffer cthis for cthis.

    vhttBuffer = phttCthis:default-buffer-handle.
    for each cthis no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cthis:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCthis no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCthis private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNodoc    as handle  no-undo.
    define buffer cthis for cthis.

    create query vhttquery.
    vhttBuffer = ghttCthis:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCthis:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNodoc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cthis exclusive-lock
                where rowid(cthis) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cthis:handle, 'nodoc: ', substitute('&1', vhNodoc:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cthis:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCthis private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cthis for cthis.

    create query vhttquery.
    vhttBuffer = ghttCthis:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCthis:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cthis.
            if not outils:copyValidField(buffer cthis:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCthis private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNodoc    as handle  no-undo.
    define buffer cthis for cthis.

    create query vhttquery.
    vhttBuffer = ghttCthis:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCthis:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNodoc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cthis exclusive-lock
                where rowid(Cthis) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cthis:handle, 'nodoc: ', substitute('&1', vhNodoc:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cthis no-error.
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

