/*------------------------------------------------------------------------
File        : resolutions_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table resolutions
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/resolutions.i}
{application/include/error.i}
define variable ghttresolutions as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur , 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
       end case.
    end.
end function.

procedure crudResolutions private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteResolutions.
    run updateResolutions.
    run createResolutions.
end procedure.

procedure setResolutions:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttResolutions.
    ghttResolutions = phttResolutions.
    run crudResolutions.
    delete object phttResolutions.
end procedure.

procedure readResolutions:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table resolutions Résolutions des AG au cabinet et au mandat
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttResolutions.
    define variable vhttBuffer as handle no-undo.
    define buffer resolutions for resolutions.

    vhttBuffer = phttResolutions:default-buffer-handle.
    for first resolutions no-lock
        where :
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer resolutions:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttResolutions no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getResolutions:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table resolutions Résolutions des AG au cabinet et au mandat
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttResolutions.
    define variable vhttBuffer as handle  no-undo.
    define buffer resolutions for resolutions.

    vhttBuffer = phttResolutions:default-buffer-handle.
    for each resolutions no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer resolutions:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttResolutions no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateResolutions private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer resolutions for resolutions.

    create query vhttquery.
    vhttBuffer = ghttResolutions:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttResolutions:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first resolutions exclusive-lock
                where rowid(resolutions) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer resolutions:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer resolutions:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createResolutions private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer resolutions for resolutions.

    create query vhttquery.
    vhttBuffer = ghttResolutions:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttResolutions:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create resolutions.
            if not outils:copyValidField(buffer resolutions:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteResolutions private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer resolutions for resolutions.

    create query vhttquery.
    vhttBuffer = ghttResolutions:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttResolutions:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first resolutions exclusive-lock
                where rowid(Resolutions) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer resolutions:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete resolutions no-error.
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

