/*------------------------------------------------------------------------
File        : trf_rp_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table trf_rp
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/trf_rp.i}
{application/include/error.i}
define variable ghtttrf_rp as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNmprg as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nmprg, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nmprg' then phNmprg = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTrf_rp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTrf_rp.
    run updateTrf_rp.
    run createTrf_rp.
end procedure.

procedure setTrf_rp:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTrf_rp.
    ghttTrf_rp = phttTrf_rp.
    run crudTrf_rp.
    delete object phttTrf_rp.
end procedure.

procedure readTrf_rp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table trf_rp 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcNmprg as character  no-undo.
    define input parameter table-handle phttTrf_rp.
    define variable vhttBuffer as handle no-undo.
    define buffer trf_rp for trf_rp.

    vhttBuffer = phttTrf_rp:default-buffer-handle.
    for first trf_rp no-lock
        where trf_rp.nmprg = pcNmprg:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trf_rp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrf_rp no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTrf_rp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table trf_rp 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTrf_rp.
    define variable vhttBuffer as handle  no-undo.
    define buffer trf_rp for trf_rp.

    vhttBuffer = phttTrf_rp:default-buffer-handle.
    for each trf_rp no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trf_rp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrf_rp no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTrf_rp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNmprg    as handle  no-undo.
    define buffer trf_rp for trf_rp.

    create query vhttquery.
    vhttBuffer = ghttTrf_rp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTrf_rp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNmprg).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first trf_rp exclusive-lock
                where rowid(trf_rp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trf_rp:handle, 'nmprg: ', substitute('&1', vhNmprg:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer trf_rp:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTrf_rp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer trf_rp for trf_rp.

    create query vhttquery.
    vhttBuffer = ghttTrf_rp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTrf_rp:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create trf_rp.
            if not outils:copyValidField(buffer trf_rp:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTrf_rp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNmprg    as handle  no-undo.
    define buffer trf_rp for trf_rp.

    create query vhttquery.
    vhttBuffer = ghttTrf_rp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTrf_rp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNmprg).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first trf_rp exclusive-lock
                where rowid(Trf_rp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trf_rp:handle, 'nmprg: ', substitute('&1', vhNmprg:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete trf_rp no-error.
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

