/*------------------------------------------------------------------------
File        : trf_lb_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table trf_lb
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/trf_lb.i}
{application/include/error.i}
define variable ghtttrf_lb as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNomes as handle, output phCdlng as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nomes/cdlng, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nomes' then phNomes = phBuffer:buffer-field(vi).
            when 'cdlng' then phCdlng = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTrf_lb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTrf_lb.
    run updateTrf_lb.
    run createTrf_lb.
end procedure.

procedure setTrf_lb:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTrf_lb.
    ghttTrf_lb = phttTrf_lb.
    run crudTrf_lb.
    delete object phttTrf_lb.
end procedure.

procedure readTrf_lb:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table trf_lb 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomes as integer    no-undo.
    define input parameter piCdlng as integer    no-undo.
    define input parameter table-handle phttTrf_lb.
    define variable vhttBuffer as handle no-undo.
    define buffer trf_lb for trf_lb.

    vhttBuffer = phttTrf_lb:default-buffer-handle.
    for first trf_lb no-lock
        where trf_lb.nomes = piNomes
          and trf_lb.cdlng = piCdlng:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trf_lb:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrf_lb no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTrf_lb:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table trf_lb 
    Notes  : service externe. Critère piNomes = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNomes as integer    no-undo.
    define input parameter table-handle phttTrf_lb.
    define variable vhttBuffer as handle  no-undo.
    define buffer trf_lb for trf_lb.

    vhttBuffer = phttTrf_lb:default-buffer-handle.
    if piNomes = ?
    then for each trf_lb no-lock
        where trf_lb.nomes = piNomes:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trf_lb:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each trf_lb no-lock
        where trf_lb.nomes = piNomes:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trf_lb:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrf_lb no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTrf_lb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomes    as handle  no-undo.
    define variable vhCdlng    as handle  no-undo.
    define buffer trf_lb for trf_lb.

    create query vhttquery.
    vhttBuffer = ghttTrf_lb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTrf_lb:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomes, output vhCdlng).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first trf_lb exclusive-lock
                where rowid(trf_lb) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trf_lb:handle, 'nomes/cdlng: ', substitute('&1/&2', vhNomes:buffer-value(), vhCdlng:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer trf_lb:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTrf_lb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer trf_lb for trf_lb.

    create query vhttquery.
    vhttBuffer = ghttTrf_lb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTrf_lb:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create trf_lb.
            if not outils:copyValidField(buffer trf_lb:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTrf_lb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomes    as handle  no-undo.
    define variable vhCdlng    as handle  no-undo.
    define buffer trf_lb for trf_lb.

    create query vhttquery.
    vhttBuffer = ghttTrf_lb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTrf_lb:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomes, output vhCdlng).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first trf_lb exclusive-lock
                where rowid(Trf_lb) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trf_lb:handle, 'nomes/cdlng: ', substitute('&1/&2', vhNomes:buffer-value(), vhCdlng:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete trf_lb no-error.
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

