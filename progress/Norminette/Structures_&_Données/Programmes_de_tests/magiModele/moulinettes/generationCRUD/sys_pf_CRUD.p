/*------------------------------------------------------------------------
File        : sys_pf_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table sys_pf
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/sys_pf.i}
{application/include/error.i}
define variable ghttsys_pf as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoprf as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NoPrf, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NoPrf' then phNoprf = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSys_pf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSys_pf.
    run updateSys_pf.
    run createSys_pf.
end procedure.

procedure setSys_pf:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSys_pf.
    ghttSys_pf = phttSys_pf.
    run crudSys_pf.
    delete object phttSys_pf.
end procedure.

procedure readSys_pf:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table sys_pf 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoprf as integer    no-undo.
    define input parameter table-handle phttSys_pf.
    define variable vhttBuffer as handle no-undo.
    define buffer sys_pf for sys_pf.

    vhttBuffer = phttSys_pf:default-buffer-handle.
    for first sys_pf no-lock
        where sys_pf.NoPrf = piNoprf:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sys_pf:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSys_pf no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSys_pf:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table sys_pf 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSys_pf.
    define variable vhttBuffer as handle  no-undo.
    define buffer sys_pf for sys_pf.

    vhttBuffer = phttSys_pf:default-buffer-handle.
    for each sys_pf no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sys_pf:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSys_pf no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSys_pf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoprf    as handle  no-undo.
    define buffer sys_pf for sys_pf.

    create query vhttquery.
    vhttBuffer = ghttSys_pf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSys_pf:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoprf).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first sys_pf exclusive-lock
                where rowid(sys_pf) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer sys_pf:handle, 'NoPrf: ', substitute('&1', vhNoprf:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer sys_pf:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSys_pf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer sys_pf for sys_pf.

    create query vhttquery.
    vhttBuffer = ghttSys_pf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSys_pf:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create sys_pf.
            if not outils:copyValidField(buffer sys_pf:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSys_pf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoprf    as handle  no-undo.
    define buffer sys_pf for sys_pf.

    create query vhttquery.
    vhttBuffer = ghttSys_pf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSys_pf:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoprf).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first sys_pf exclusive-lock
                where rowid(Sys_pf) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer sys_pf:handle, 'NoPrf: ', substitute('&1', vhNoprf:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete sys_pf no-error.
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

