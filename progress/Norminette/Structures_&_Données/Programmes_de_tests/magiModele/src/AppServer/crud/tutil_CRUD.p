/*------------------------------------------------------------------------
File        : tutil_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table tutil
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/tutil.i}
{application/include/error.i}
define variable ghtttutil as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phIdent_u as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur ident_u, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'ident_u' then phIdent_u = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTutil private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTutil.
    run updateTutil.
    run createTutil.
end procedure.

procedure setTutil:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTutil.
    ghttTutil = phttTutil.
    run crudTutil.
    delete object phttTutil.
end procedure.

procedure readTutil:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table tutil 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcIdent_u as character  no-undo.
    define input parameter table-handle phttTutil.
    define variable vhttBuffer as handle no-undo.
    define buffer tutil for tutil.

    vhttBuffer = phttTutil:default-buffer-handle.
    for first tutil no-lock
        where tutil.ident_u = pcIdent_u:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tutil:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTutil no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTutil:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table tutil 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTutil.
    define variable vhttBuffer as handle  no-undo.
    define buffer tutil for tutil.

    vhttBuffer = phttTutil:default-buffer-handle.
    for each tutil no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tutil:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTutil no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTutil private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhIdent_u    as handle  no-undo.
    define buffer tutil for tutil.

    create query vhttquery.
    vhttBuffer = ghttTutil:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTutil:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhIdent_u).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tutil exclusive-lock
                where rowid(tutil) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tutil:handle, 'ident_u: ', substitute('&1', vhIdent_u:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer tutil:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTutil private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer tutil for tutil.

    create query vhttquery.
    vhttBuffer = ghttTutil:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTutil:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create tutil.
            if not outils:copyValidField(buffer tutil:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTutil private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhIdent_u    as handle  no-undo.
    define buffer tutil for tutil.

    create query vhttquery.
    vhttBuffer = ghttTutil:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTutil:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhIdent_u).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tutil exclusive-lock
                where rowid(Tutil) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tutil:handle, 'ident_u: ', substitute('&1', vhIdent_u:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete tutil no-error.
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

