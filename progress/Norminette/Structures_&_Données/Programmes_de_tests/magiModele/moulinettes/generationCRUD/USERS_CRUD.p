/*------------------------------------------------------------------------
File        : USERS_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table USERS
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/USERS.i}
{application/include/error.i}
define variable ghttUSERS as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCduse as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur CDUSE, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'CDUSE' then phCduse = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudUsers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteUsers.
    run updateUsers.
    run createUsers.
end procedure.

procedure setUsers:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttUsers.
    ghttUsers = phttUsers.
    run crudUsers.
    delete object phttUsers.
end procedure.

procedure readUsers:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table USERS 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCduse as character  no-undo.
    define input parameter table-handle phttUsers.
    define variable vhttBuffer as handle no-undo.
    define buffer USERS for USERS.

    vhttBuffer = phttUsers:default-buffer-handle.
    for first USERS no-lock
        where USERS.CDUSE = pcCduse:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer USERS:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttUsers no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getUsers:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table USERS 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttUsers.
    define variable vhttBuffer as handle  no-undo.
    define buffer USERS for USERS.

    vhttBuffer = phttUsers:default-buffer-handle.
    for each USERS no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer USERS:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttUsers no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateUsers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCduse    as handle  no-undo.
    define buffer USERS for USERS.

    create query vhttquery.
    vhttBuffer = ghttUsers:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttUsers:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCduse).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first USERS exclusive-lock
                where rowid(USERS) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer USERS:handle, 'CDUSE: ', substitute('&1', vhCduse:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer USERS:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createUsers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer USERS for USERS.

    create query vhttquery.
    vhttBuffer = ghttUsers:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttUsers:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create USERS.
            if not outils:copyValidField(buffer USERS:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteUsers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCduse    as handle  no-undo.
    define buffer USERS for USERS.

    create query vhttquery.
    vhttBuffer = ghttUsers:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttUsers:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCduse).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first USERS exclusive-lock
                where rowid(Users) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer USERS:handle, 'CDUSE: ', substitute('&1', vhCduse:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete USERS no-error.
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

