/*------------------------------------------------------------------------
File        : trf_tb_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table trf_tb
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/trf_tb.i}
{application/include/error.i}
define variable ghtttrf_tb as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNmtbl as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nmtbl, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nmtbl' then phNmtbl = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTrf_tb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTrf_tb.
    run updateTrf_tb.
    run createTrf_tb.
end procedure.

procedure setTrf_tb:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTrf_tb.
    ghttTrf_tb = phttTrf_tb.
    run crudTrf_tb.
    delete object phttTrf_tb.
end procedure.

procedure readTrf_tb:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table trf_tb 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcNmtbl as character  no-undo.
    define input parameter table-handle phttTrf_tb.
    define variable vhttBuffer as handle no-undo.
    define buffer trf_tb for trf_tb.

    vhttBuffer = phttTrf_tb:default-buffer-handle.
    for first trf_tb no-lock
        where trf_tb.nmtbl = pcNmtbl:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trf_tb:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrf_tb no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTrf_tb:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table trf_tb 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTrf_tb.
    define variable vhttBuffer as handle  no-undo.
    define buffer trf_tb for trf_tb.

    vhttBuffer = phttTrf_tb:default-buffer-handle.
    for each trf_tb no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trf_tb:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrf_tb no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTrf_tb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNmtbl    as handle  no-undo.
    define buffer trf_tb for trf_tb.

    create query vhttquery.
    vhttBuffer = ghttTrf_tb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTrf_tb:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNmtbl).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first trf_tb exclusive-lock
                where rowid(trf_tb) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trf_tb:handle, 'nmtbl: ', substitute('&1', vhNmtbl:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer trf_tb:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTrf_tb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer trf_tb for trf_tb.

    create query vhttquery.
    vhttBuffer = ghttTrf_tb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTrf_tb:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create trf_tb.
            if not outils:copyValidField(buffer trf_tb:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTrf_tb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNmtbl    as handle  no-undo.
    define buffer trf_tb for trf_tb.

    create query vhttquery.
    vhttBuffer = ghttTrf_tb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTrf_tb:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNmtbl).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first trf_tb exclusive-lock
                where rowid(Trf_tb) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trf_tb:handle, 'nmtbl: ', substitute('&1', vhNmtbl:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete trf_tb no-error.
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

