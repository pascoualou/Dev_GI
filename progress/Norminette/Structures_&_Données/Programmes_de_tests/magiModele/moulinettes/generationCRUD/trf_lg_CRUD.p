/*------------------------------------------------------------------------
File        : trf_lg_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table trf_lg
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/trf_lg.i}
{application/include/error.i}
define variable ghtttrf_lg as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdlng as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdlng, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdlng' then phCdlng = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTrf_lg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTrf_lg.
    run updateTrf_lg.
    run createTrf_lg.
end procedure.

procedure setTrf_lg:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTrf_lg.
    ghttTrf_lg = phttTrf_lg.
    run crudTrf_lg.
    delete object phttTrf_lg.
end procedure.

procedure readTrf_lg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table trf_lg table des langues
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piCdlng as integer    no-undo.
    define input parameter table-handle phttTrf_lg.
    define variable vhttBuffer as handle no-undo.
    define buffer trf_lg for trf_lg.

    vhttBuffer = phttTrf_lg:default-buffer-handle.
    for first trf_lg no-lock
        where trf_lg.cdlng = piCdlng:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trf_lg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrf_lg no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTrf_lg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table trf_lg table des langues
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTrf_lg.
    define variable vhttBuffer as handle  no-undo.
    define buffer trf_lg for trf_lg.

    vhttBuffer = phttTrf_lg:default-buffer-handle.
    for each trf_lg no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trf_lg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrf_lg no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTrf_lg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdlng    as handle  no-undo.
    define buffer trf_lg for trf_lg.

    create query vhttquery.
    vhttBuffer = ghttTrf_lg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTrf_lg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdlng).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first trf_lg exclusive-lock
                where rowid(trf_lg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trf_lg:handle, 'cdlng: ', substitute('&1', vhCdlng:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer trf_lg:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTrf_lg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer trf_lg for trf_lg.

    create query vhttquery.
    vhttBuffer = ghttTrf_lg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTrf_lg:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create trf_lg.
            if not outils:copyValidField(buffer trf_lg:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTrf_lg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdlng    as handle  no-undo.
    define buffer trf_lg for trf_lg.

    create query vhttquery.
    vhttBuffer = ghttTrf_lg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTrf_lg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdlng).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first trf_lg exclusive-lock
                where rowid(Trf_lg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trf_lg:handle, 'cdlng: ', substitute('&1', vhCdlng:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete trf_lg no-error.
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

