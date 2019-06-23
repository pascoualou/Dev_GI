/*------------------------------------------------------------------------
File        : sys_mn_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table sys_mn
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/sys_mn.i}
{application/include/error.i}
define variable ghttsys_mn as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNomen as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nomen, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nomen' then phNomen = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSys_mn private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSys_mn.
    run updateSys_mn.
    run createSys_mn.
end procedure.

procedure setSys_mn:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSys_mn.
    ghttSys_mn = phttSys_mn.
    run crudSys_mn.
    delete object phttSys_mn.
end procedure.

procedure readSys_mn:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table sys_mn 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomen as integer    no-undo.
    define input parameter table-handle phttSys_mn.
    define variable vhttBuffer as handle no-undo.
    define buffer sys_mn for sys_mn.

    vhttBuffer = phttSys_mn:default-buffer-handle.
    for first sys_mn no-lock
        where sys_mn.nomen = piNomen:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sys_mn:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSys_mn no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSys_mn:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table sys_mn 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSys_mn.
    define variable vhttBuffer as handle  no-undo.
    define buffer sys_mn for sys_mn.

    vhttBuffer = phttSys_mn:default-buffer-handle.
    for each sys_mn no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sys_mn:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSys_mn no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSys_mn private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomen    as handle  no-undo.
    define buffer sys_mn for sys_mn.

    create query vhttquery.
    vhttBuffer = ghttSys_mn:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSys_mn:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomen).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first sys_mn exclusive-lock
                where rowid(sys_mn) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer sys_mn:handle, 'nomen: ', substitute('&1', vhNomen:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer sys_mn:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSys_mn private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer sys_mn for sys_mn.

    create query vhttquery.
    vhttBuffer = ghttSys_mn:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSys_mn:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create sys_mn.
            if not outils:copyValidField(buffer sys_mn:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSys_mn private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomen    as handle  no-undo.
    define buffer sys_mn for sys_mn.

    create query vhttquery.
    vhttBuffer = ghttSys_mn:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSys_mn:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomen).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first sys_mn exclusive-lock
                where rowid(Sys_mn) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer sys_mn:handle, 'nomen: ', substitute('&1', vhNomen:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete sys_mn no-error.
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

