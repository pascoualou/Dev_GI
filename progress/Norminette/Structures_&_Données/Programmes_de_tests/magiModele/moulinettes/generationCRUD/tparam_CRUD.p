/*------------------------------------------------------------------------
File        : tparam_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table tparam
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/tparam.i}
{application/include/error.i}
define variable ghtttparam as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudTparam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTparam.
    run updateTparam.
    run createTparam.
end procedure.

procedure setTparam:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTparam.
    ghttTparam = phttTparam.
    run crudTparam.
    delete object phttTparam.
end procedure.

procedure readTparam:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table tparam 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcIdent_u as character  no-undo.
    define input parameter table-handle phttTparam.
    define variable vhttBuffer as handle no-undo.
    define buffer tparam for tparam.

    vhttBuffer = phttTparam:default-buffer-handle.
    for first tparam no-lock
        where tparam.ident_u = pcIdent_u:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tparam:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTparam no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTparam:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table tparam 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTparam.
    define variable vhttBuffer as handle  no-undo.
    define buffer tparam for tparam.

    vhttBuffer = phttTparam:default-buffer-handle.
    for each tparam no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tparam:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTparam no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTparam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhIdent_u    as handle  no-undo.
    define buffer tparam for tparam.

    create query vhttquery.
    vhttBuffer = ghttTparam:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTparam:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhIdent_u).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tparam exclusive-lock
                where rowid(tparam) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tparam:handle, 'ident_u: ', substitute('&1', vhIdent_u:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer tparam:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTparam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer tparam for tparam.

    create query vhttquery.
    vhttBuffer = ghttTparam:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTparam:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create tparam.
            if not outils:copyValidField(buffer tparam:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTparam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhIdent_u    as handle  no-undo.
    define buffer tparam for tparam.

    create query vhttquery.
    vhttBuffer = ghttTparam:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTparam:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhIdent_u).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tparam exclusive-lock
                where rowid(Tparam) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tparam:handle, 'ident_u: ', substitute('&1', vhIdent_u:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete tparam no-error.
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

