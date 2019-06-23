/*------------------------------------------------------------------------
File        : trf_im_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table trf_im
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/trf_im.i}
{application/include/error.i}
define variable ghtttrf_im as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoimg as handle, output phCdlng as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noimg/cdlng, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noimg' then phNoimg = phBuffer:buffer-field(vi).
            when 'cdlng' then phCdlng = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTrf_im private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTrf_im.
    run updateTrf_im.
    run createTrf_im.
end procedure.

procedure setTrf_im:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTrf_im.
    ghttTrf_im = phttTrf_im.
    run crudTrf_im.
    delete object phttTrf_im.
end procedure.

procedure readTrf_im:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table trf_im 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoimg as integer    no-undo.
    define input parameter piCdlng as integer    no-undo.
    define input parameter table-handle phttTrf_im.
    define variable vhttBuffer as handle no-undo.
    define buffer trf_im for trf_im.

    vhttBuffer = phttTrf_im:default-buffer-handle.
    for first trf_im no-lock
        where trf_im.noimg = piNoimg
          and trf_im.cdlng = piCdlng:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trf_im:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrf_im no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTrf_im:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table trf_im 
    Notes  : service externe. Critère piNoimg = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoimg as integer    no-undo.
    define input parameter table-handle phttTrf_im.
    define variable vhttBuffer as handle  no-undo.
    define buffer trf_im for trf_im.

    vhttBuffer = phttTrf_im:default-buffer-handle.
    if piNoimg = ?
    then for each trf_im no-lock
        where trf_im.noimg = piNoimg:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trf_im:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each trf_im no-lock
        where trf_im.noimg = piNoimg:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trf_im:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrf_im no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTrf_im private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoimg    as handle  no-undo.
    define variable vhCdlng    as handle  no-undo.
    define buffer trf_im for trf_im.

    create query vhttquery.
    vhttBuffer = ghttTrf_im:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTrf_im:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimg, output vhCdlng).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first trf_im exclusive-lock
                where rowid(trf_im) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trf_im:handle, 'noimg/cdlng: ', substitute('&1/&2', vhNoimg:buffer-value(), vhCdlng:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer trf_im:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTrf_im private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer trf_im for trf_im.

    create query vhttquery.
    vhttBuffer = ghttTrf_im:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTrf_im:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create trf_im.
            if not outils:copyValidField(buffer trf_im:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTrf_im private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoimg    as handle  no-undo.
    define variable vhCdlng    as handle  no-undo.
    define buffer trf_im for trf_im.

    create query vhttquery.
    vhttBuffer = ghttTrf_im:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTrf_im:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimg, output vhCdlng).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first trf_im exclusive-lock
                where rowid(Trf_im) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trf_im:handle, 'noimg/cdlng: ', substitute('&1/&2', vhNoimg:buffer-value(), vhCdlng:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete trf_im no-error.
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

