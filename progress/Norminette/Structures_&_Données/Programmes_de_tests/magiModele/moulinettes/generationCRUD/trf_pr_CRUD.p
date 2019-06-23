/*------------------------------------------------------------------------
File        : trf_pr_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table trf_pr
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/trf_pr.i}
{application/include/error.i}
define variable ghtttrf_pr as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTppar as handle, output phCdpar as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tppar/cdpar, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tppar' then phTppar = phBuffer:buffer-field(vi).
            when 'cdpar' then phCdpar = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTrf_pr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTrf_pr.
    run updateTrf_pr.
    run createTrf_pr.
end procedure.

procedure setTrf_pr:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTrf_pr.
    ghttTrf_pr = phttTrf_pr.
    run crudTrf_pr.
    delete object phttTrf_pr.
end procedure.

procedure readTrf_pr:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table trf_pr 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTppar as character  no-undo.
    define input parameter pcCdpar as character  no-undo.
    define input parameter table-handle phttTrf_pr.
    define variable vhttBuffer as handle no-undo.
    define buffer trf_pr for trf_pr.

    vhttBuffer = phttTrf_pr:default-buffer-handle.
    for first trf_pr no-lock
        where trf_pr.tppar = pcTppar
          and trf_pr.cdpar = pcCdpar:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trf_pr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrf_pr no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTrf_pr:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table trf_pr 
    Notes  : service externe. Critère pcTppar = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTppar as character  no-undo.
    define input parameter table-handle phttTrf_pr.
    define variable vhttBuffer as handle  no-undo.
    define buffer trf_pr for trf_pr.

    vhttBuffer = phttTrf_pr:default-buffer-handle.
    if pcTppar = ?
    then for each trf_pr no-lock
        where trf_pr.tppar = pcTppar:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trf_pr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each trf_pr no-lock
        where trf_pr.tppar = pcTppar:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trf_pr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrf_pr no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTrf_pr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTppar    as handle  no-undo.
    define variable vhCdpar    as handle  no-undo.
    define buffer trf_pr for trf_pr.

    create query vhttquery.
    vhttBuffer = ghttTrf_pr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTrf_pr:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTppar, output vhCdpar).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first trf_pr exclusive-lock
                where rowid(trf_pr) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trf_pr:handle, 'tppar/cdpar: ', substitute('&1/&2', vhTppar:buffer-value(), vhCdpar:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer trf_pr:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTrf_pr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer trf_pr for trf_pr.

    create query vhttquery.
    vhttBuffer = ghttTrf_pr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTrf_pr:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create trf_pr.
            if not outils:copyValidField(buffer trf_pr:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTrf_pr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTppar    as handle  no-undo.
    define variable vhCdpar    as handle  no-undo.
    define buffer trf_pr for trf_pr.

    create query vhttquery.
    vhttBuffer = ghttTrf_pr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTrf_pr:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTppar, output vhCdpar).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first trf_pr exclusive-lock
                where rowid(Trf_pr) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trf_pr:handle, 'tppar/cdpar: ', substitute('&1/&2', vhTppar:buffer-value(), vhCdpar:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete trf_pr no-error.
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

