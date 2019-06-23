/*------------------------------------------------------------------------
File        : location_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table location
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/location.i}
{application/include/error.i}
define variable ghttlocation as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNofiche as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nofiche, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nofiche' then phNofiche = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudLocation private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteLocation.
    run updateLocation.
    run createLocation.
end procedure.

procedure setLocation:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttLocation.
    ghttLocation = phttLocation.
    run crudLocation.
    delete object phttLocation.
end procedure.

procedure readLocation:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table location 1106/0142 - AGF Module LOCATIONS
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNofiche as integer    no-undo.
    define input parameter table-handle phttLocation.
    define variable vhttBuffer as handle no-undo.
    define buffer location for location.

    vhttBuffer = phttLocation:default-buffer-handle.
    for first location no-lock
        where location.nofiche = piNofiche:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer location:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLocation no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getLocation:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table location 1106/0142 - AGF Module LOCATIONS
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttLocation.
    define variable vhttBuffer as handle  no-undo.
    define buffer location for location.

    vhttBuffer = phttLocation:default-buffer-handle.
    for each location no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer location:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttLocation no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateLocation private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNofiche    as handle  no-undo.
    define buffer location for location.

    create query vhttquery.
    vhttBuffer = ghttLocation:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttLocation:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNofiche).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first location exclusive-lock
                where rowid(location) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer location:handle, 'nofiche: ', substitute('&1', vhNofiche:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer location:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createLocation private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer location for location.

    create query vhttquery.
    vhttBuffer = ghttLocation:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttLocation:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create location.
            if not outils:copyValidField(buffer location:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteLocation private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNofiche    as handle  no-undo.
    define buffer location for location.

    create query vhttquery.
    vhttBuffer = ghttLocation:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttLocation:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNofiche).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first location exclusive-lock
                where rowid(Location) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer location:handle, 'nofiche: ', substitute('&1', vhNofiche:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete location no-error.
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

