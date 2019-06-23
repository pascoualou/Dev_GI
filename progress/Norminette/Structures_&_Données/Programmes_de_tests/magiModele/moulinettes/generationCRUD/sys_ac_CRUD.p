/*------------------------------------------------------------------------
File        : sys_ac_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table sys_ac
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/sys_ac.i}
{application/include/error.i}
define variable ghttsys_ac as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoprf as handle, output phNmtbl as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NoPrf/NmTbl, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NoPrf' then phNoprf = phBuffer:buffer-field(vi).
            when 'NmTbl' then phNmtbl = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSys_ac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSys_ac.
    run updateSys_ac.
    run createSys_ac.
end procedure.

procedure setSys_ac:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSys_ac.
    ghttSys_ac = phttSys_ac.
    run crudSys_ac.
    delete object phttSys_ac.
end procedure.

procedure readSys_ac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table sys_ac 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoprf as integer    no-undo.
    define input parameter pcNmtbl as character  no-undo.
    define input parameter table-handle phttSys_ac.
    define variable vhttBuffer as handle no-undo.
    define buffer sys_ac for sys_ac.

    vhttBuffer = phttSys_ac:default-buffer-handle.
    for first sys_ac no-lock
        where sys_ac.NoPrf = piNoprf
          and sys_ac.NmTbl = pcNmtbl:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sys_ac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSys_ac no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSys_ac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table sys_ac 
    Notes  : service externe. Critère piNoprf = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoprf as integer    no-undo.
    define input parameter table-handle phttSys_ac.
    define variable vhttBuffer as handle  no-undo.
    define buffer sys_ac for sys_ac.

    vhttBuffer = phttSys_ac:default-buffer-handle.
    if piNoprf = ?
    then for each sys_ac no-lock
        where sys_ac.NoPrf = piNoprf:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sys_ac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each sys_ac no-lock
        where sys_ac.NoPrf = piNoprf:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sys_ac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSys_ac no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSys_ac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoprf    as handle  no-undo.
    define variable vhNmtbl    as handle  no-undo.
    define buffer sys_ac for sys_ac.

    create query vhttquery.
    vhttBuffer = ghttSys_ac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSys_ac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoprf, output vhNmtbl).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first sys_ac exclusive-lock
                where rowid(sys_ac) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer sys_ac:handle, 'NoPrf/NmTbl: ', substitute('&1/&2', vhNoprf:buffer-value(), vhNmtbl:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer sys_ac:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSys_ac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer sys_ac for sys_ac.

    create query vhttquery.
    vhttBuffer = ghttSys_ac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSys_ac:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create sys_ac.
            if not outils:copyValidField(buffer sys_ac:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSys_ac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoprf    as handle  no-undo.
    define variable vhNmtbl    as handle  no-undo.
    define buffer sys_ac for sys_ac.

    create query vhttquery.
    vhttBuffer = ghttSys_ac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSys_ac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoprf, output vhNmtbl).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first sys_ac exclusive-lock
                where rowid(Sys_ac) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer sys_ac:handle, 'NoPrf/NmTbl: ', substitute('&1/&2', vhNoprf:buffer-value(), vhNmtbl:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete sys_ac no-error.
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

