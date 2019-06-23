/*------------------------------------------------------------------------
File        : trf_mn_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table trf_mn
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/trf_mn.i}
{application/include/error.i}
define variable ghtttrf_mn as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNomen as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nomen, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nomen' then phNomen = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTrf_mn private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTrf_mn.
    run updateTrf_mn.
    run createTrf_mn.
end procedure.

procedure setTrf_mn:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTrf_mn.
    ghttTrf_mn = phttTrf_mn.
    run crudTrf_mn.
    delete object phttTrf_mn.
end procedure.

procedure readTrf_mn:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table trf_mn 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomen as integer    no-undo.
    define input parameter table-handle phttTrf_mn.
    define variable vhttBuffer as handle no-undo.
    define buffer trf_mn for trf_mn.

    vhttBuffer = phttTrf_mn:default-buffer-handle.
    for first trf_mn no-lock
        where trf_mn.nomen = piNomen:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trf_mn:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrf_mn no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTrf_mn:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table trf_mn 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTrf_mn.
    define variable vhttBuffer as handle  no-undo.
    define buffer trf_mn for trf_mn.

    vhttBuffer = phttTrf_mn:default-buffer-handle.
    for each trf_mn no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trf_mn:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrf_mn no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTrf_mn private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomen    as handle  no-undo.
    define buffer trf_mn for trf_mn.

    create query vhttquery.
    vhttBuffer = ghttTrf_mn:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTrf_mn:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomen).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first trf_mn exclusive-lock
                where rowid(trf_mn) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trf_mn:handle, 'nomen: ', substitute('&1', vhNomen:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer trf_mn:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTrf_mn private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer trf_mn for trf_mn.

    create query vhttquery.
    vhttBuffer = ghttTrf_mn:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTrf_mn:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create trf_mn.
            if not outils:copyValidField(buffer trf_mn:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTrf_mn private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomen    as handle  no-undo.
    define buffer trf_mn for trf_mn.

    create query vhttquery.
    vhttBuffer = ghttTrf_mn:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTrf_mn:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomen).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first trf_mn exclusive-lock
                where rowid(Trf_mn) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trf_mn:handle, 'nomen: ', substitute('&1', vhNomen:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete trf_mn no-error.
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

