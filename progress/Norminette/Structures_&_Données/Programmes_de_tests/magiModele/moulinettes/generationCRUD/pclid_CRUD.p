/*------------------------------------------------------------------------
File        : pclid_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table pclid
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/pclid.i}
{application/include/error.i}
define variable ghttpclid as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTppar as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tppar, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tppar' then phTppar = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPclid private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePclid.
    run updatePclid.
    run createPclid.
end procedure.

procedure setPclid:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPclid.
    ghttPclid = phttPclid.
    run crudPclid.
    delete object phttPclid.
end procedure.

procedure readPclid:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table pclid 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTppar as character  no-undo.
    define input parameter table-handle phttPclid.
    define variable vhttBuffer as handle no-undo.
    define buffer pclid for pclid.

    vhttBuffer = phttPclid:default-buffer-handle.
    for first pclid no-lock
        where pclid.tppar = pcTppar:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pclid:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPclid no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPclid:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table pclid 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPclid.
    define variable vhttBuffer as handle  no-undo.
    define buffer pclid for pclid.

    vhttBuffer = phttPclid:default-buffer-handle.
    for each pclid no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pclid:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPclid no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePclid private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTppar    as handle  no-undo.
    define buffer pclid for pclid.

    create query vhttquery.
    vhttBuffer = ghttPclid:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPclid:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTppar).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pclid exclusive-lock
                where rowid(pclid) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pclid:handle, 'tppar: ', substitute('&1', vhTppar:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer pclid:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPclid private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer pclid for pclid.

    create query vhttquery.
    vhttBuffer = ghttPclid:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPclid:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create pclid.
            if not outils:copyValidField(buffer pclid:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePclid private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTppar    as handle  no-undo.
    define buffer pclid for pclid.

    create query vhttquery.
    vhttBuffer = ghttPclid:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPclid:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTppar).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pclid exclusive-lock
                where rowid(Pclid) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pclid:handle, 'tppar: ', substitute('&1', vhTppar:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete pclid no-error.
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

