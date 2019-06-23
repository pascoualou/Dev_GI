/*------------------------------------------------------------------------
File        : version_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table version
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/version.i}
{application/include/error.i}
define variable ghttversion as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNumero_version as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur numero_version, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'numero_version' then phNumero_version = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudVersion private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteVersion.
    run updateVersion.
    run createVersion.
end procedure.

procedure setVersion:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttVersion.
    ghttVersion = phttVersion.
    run crudVersion.
    delete object phttVersion.
end procedure.

procedure readVersion:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table version 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcNumero_version as character  no-undo.
    define input parameter table-handle phttVersion.
    define variable vhttBuffer as handle no-undo.
    define buffer version for version.

    vhttBuffer = phttVersion:default-buffer-handle.
    for first version no-lock
        where version.numero_version = pcNumero_version:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer version:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttVersion no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getVersion:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table version 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttVersion.
    define variable vhttBuffer as handle  no-undo.
    define buffer version for version.

    vhttBuffer = phttVersion:default-buffer-handle.
    for each version no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer version:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttVersion no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateVersion private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNumero_version    as handle  no-undo.
    define buffer version for version.

    create query vhttquery.
    vhttBuffer = ghttVersion:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttVersion:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNumero_version).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first version exclusive-lock
                where rowid(version) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer version:handle, 'numero_version: ', substitute('&1', vhNumero_version:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer version:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createVersion private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer version for version.

    create query vhttquery.
    vhttBuffer = ghttVersion:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttVersion:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create version.
            if not outils:copyValidField(buffer version:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteVersion private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNumero_version    as handle  no-undo.
    define buffer version for version.

    create query vhttquery.
    vhttBuffer = ghttVersion:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttVersion:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNumero_version).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first version exclusive-lock
                where rowid(Version) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer version:handle, 'numero_version: ', substitute('&1', vhNumero_version:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete version no-error.
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

