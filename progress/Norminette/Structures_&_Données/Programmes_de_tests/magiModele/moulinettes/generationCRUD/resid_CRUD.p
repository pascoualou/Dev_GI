/*------------------------------------------------------------------------
File        : resid_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table resid
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/resid.i}
{application/include/error.i}
define variable ghttresid as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdres as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdres, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdres' then phCdres = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudResid private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteResid.
    run updateResid.
    run createResid.
end procedure.

procedure setResid:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttResid.
    ghttResid = phttResid.
    run crudResid.
    delete object phttResid.
end procedure.

procedure readResid:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table resid 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdres as character  no-undo.
    define input parameter table-handle phttResid.
    define variable vhttBuffer as handle no-undo.
    define buffer resid for resid.

    vhttBuffer = phttResid:default-buffer-handle.
    for first resid no-lock
        where resid.cdres = pcCdres:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer resid:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttResid no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getResid:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table resid 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttResid.
    define variable vhttBuffer as handle  no-undo.
    define buffer resid for resid.

    vhttBuffer = phttResid:default-buffer-handle.
    for each resid no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer resid:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttResid no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateResid private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdres    as handle  no-undo.
    define buffer resid for resid.

    create query vhttquery.
    vhttBuffer = ghttResid:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttResid:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdres).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first resid exclusive-lock
                where rowid(resid) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer resid:handle, 'cdres: ', substitute('&1', vhCdres:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer resid:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createResid private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer resid for resid.

    create query vhttquery.
    vhttBuffer = ghttResid:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttResid:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create resid.
            if not outils:copyValidField(buffer resid:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteResid private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdres    as handle  no-undo.
    define buffer resid for resid.

    create query vhttquery.
    vhttBuffer = ghttResid:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttResid:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdres).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first resid exclusive-lock
                where rowid(Resid) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer resid:handle, 'cdres: ', substitute('&1', vhCdres:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete resid no-error.
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

