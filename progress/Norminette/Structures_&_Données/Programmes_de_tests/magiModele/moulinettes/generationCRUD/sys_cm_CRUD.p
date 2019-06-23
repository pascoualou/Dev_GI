/*------------------------------------------------------------------------
File        : sys_cm_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table sys_cm
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/sys_cm.i}
{application/include/error.i}
define variable ghttsys_cm as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNomen as handle, output phNoord as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nomen/noord, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nomen' then phNomen = phBuffer:buffer-field(vi).
            when 'noord' then phNoord = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSys_cm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSys_cm.
    run updateSys_cm.
    run createSys_cm.
end procedure.

procedure setSys_cm:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSys_cm.
    ghttSys_cm = phttSys_cm.
    run crudSys_cm.
    delete object phttSys_cm.
end procedure.

procedure readSys_cm:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table sys_cm 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomen as integer    no-undo.
    define input parameter piNoord as integer    no-undo.
    define input parameter table-handle phttSys_cm.
    define variable vhttBuffer as handle no-undo.
    define buffer sys_cm for sys_cm.

    vhttBuffer = phttSys_cm:default-buffer-handle.
    for first sys_cm no-lock
        where sys_cm.nomen = piNomen
          and sys_cm.noord = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sys_cm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSys_cm no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSys_cm:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table sys_cm 
    Notes  : service externe. Critère piNomen = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNomen as integer    no-undo.
    define input parameter table-handle phttSys_cm.
    define variable vhttBuffer as handle  no-undo.
    define buffer sys_cm for sys_cm.

    vhttBuffer = phttSys_cm:default-buffer-handle.
    if piNomen = ?
    then for each sys_cm no-lock
        where sys_cm.nomen = piNomen:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sys_cm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each sys_cm no-lock
        where sys_cm.nomen = piNomen:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sys_cm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSys_cm no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSys_cm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomen    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer sys_cm for sys_cm.

    create query vhttquery.
    vhttBuffer = ghttSys_cm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSys_cm:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomen, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first sys_cm exclusive-lock
                where rowid(sys_cm) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer sys_cm:handle, 'nomen/noord: ', substitute('&1/&2', vhNomen:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer sys_cm:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSys_cm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer sys_cm for sys_cm.

    create query vhttquery.
    vhttBuffer = ghttSys_cm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSys_cm:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create sys_cm.
            if not outils:copyValidField(buffer sys_cm:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSys_cm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomen    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer sys_cm for sys_cm.

    create query vhttquery.
    vhttBuffer = ghttSys_cm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSys_cm:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomen, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first sys_cm exclusive-lock
                where rowid(Sys_cm) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer sys_cm:handle, 'nomen/noord: ', substitute('&1/&2', vhNomen:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete sys_cm no-error.
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

