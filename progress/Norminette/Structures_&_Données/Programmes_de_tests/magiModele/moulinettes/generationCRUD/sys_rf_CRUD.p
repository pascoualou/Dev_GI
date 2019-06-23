/*------------------------------------------------------------------------
File        : sys_rf_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table sys_rf
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/sys_rf.i}
{application/include/error.i}
define variable ghttsys_rf as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNomes as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nomes, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nomes' then phNomes = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSys_rf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSys_rf.
    run updateSys_rf.
    run createSys_rf.
end procedure.

procedure setSys_rf:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSys_rf.
    ghttSys_rf = phttSys_rf.
    run crudSys_rf.
    delete object phttSys_rf.
end procedure.

procedure readSys_rf:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table sys_rf 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomes as integer    no-undo.
    define input parameter table-handle phttSys_rf.
    define variable vhttBuffer as handle no-undo.
    define buffer sys_rf for sys_rf.

    vhttBuffer = phttSys_rf:default-buffer-handle.
    for first sys_rf no-lock
        where sys_rf.nomes = piNomes:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sys_rf:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSys_rf no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSys_rf:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table sys_rf 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSys_rf.
    define variable vhttBuffer as handle  no-undo.
    define buffer sys_rf for sys_rf.

    vhttBuffer = phttSys_rf:default-buffer-handle.
    for each sys_rf no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sys_rf:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSys_rf no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSys_rf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomes    as handle  no-undo.
    define buffer sys_rf for sys_rf.

    create query vhttquery.
    vhttBuffer = ghttSys_rf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSys_rf:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomes).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first sys_rf exclusive-lock
                where rowid(sys_rf) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer sys_rf:handle, 'nomes: ', substitute('&1', vhNomes:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer sys_rf:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSys_rf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer sys_rf for sys_rf.

    create query vhttquery.
    vhttBuffer = ghttSys_rf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSys_rf:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create sys_rf.
            if not outils:copyValidField(buffer sys_rf:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSys_rf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomes    as handle  no-undo.
    define buffer sys_rf for sys_rf.

    create query vhttquery.
    vhttBuffer = ghttSys_rf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSys_rf:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomes).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first sys_rf exclusive-lock
                where rowid(Sys_rf) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer sys_rf:handle, 'nomes: ', substitute('&1', vhNomes:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete sys_rf no-error.
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

