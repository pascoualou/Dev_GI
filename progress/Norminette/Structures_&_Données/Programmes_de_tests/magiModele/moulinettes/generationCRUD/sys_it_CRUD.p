/*------------------------------------------------------------------------
File        : sys_it_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table sys_it
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/sys_it.i}
{application/include/error.i}
define variable ghttsys_it as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoite as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noite, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noite' then phNoite = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSys_it private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSys_it.
    run updateSys_it.
    run createSys_it.
end procedure.

procedure setSys_it:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSys_it.
    ghttSys_it = phttSys_it.
    run crudSys_it.
    delete object phttSys_it.
end procedure.

procedure readSys_it:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table sys_it 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoite as integer    no-undo.
    define input parameter table-handle phttSys_it.
    define variable vhttBuffer as handle no-undo.
    define buffer sys_it for sys_it.

    vhttBuffer = phttSys_it:default-buffer-handle.
    for first sys_it no-lock
        where sys_it.noite = piNoite:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sys_it:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSys_it no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSys_it:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table sys_it 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSys_it.
    define variable vhttBuffer as handle  no-undo.
    define buffer sys_it for sys_it.

    vhttBuffer = phttSys_it:default-buffer-handle.
    for each sys_it no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sys_it:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSys_it no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSys_it private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoite    as handle  no-undo.
    define buffer sys_it for sys_it.

    create query vhttquery.
    vhttBuffer = ghttSys_it:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSys_it:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoite).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first sys_it exclusive-lock
                where rowid(sys_it) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer sys_it:handle, 'noite: ', substitute('&1', vhNoite:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer sys_it:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSys_it private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer sys_it for sys_it.

    create query vhttquery.
    vhttBuffer = ghttSys_it:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSys_it:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create sys_it.
            if not outils:copyValidField(buffer sys_it:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSys_it private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoite    as handle  no-undo.
    define buffer sys_it for sys_it.

    create query vhttquery.
    vhttBuffer = ghttSys_it:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSys_it:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoite).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first sys_it exclusive-lock
                where rowid(Sys_it) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer sys_it:handle, 'noite: ', substitute('&1', vhNoite:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete sys_it no-error.
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

