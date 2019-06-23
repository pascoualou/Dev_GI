/*------------------------------------------------------------------------
File        : sys_us_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table sys_us
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/sys_us.i}
{application/include/error.i}
define variable ghttsys_us as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCduti as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cduti, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cduti' then phCduti = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSys_us private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSys_us.
    run updateSys_us.
    run createSys_us.
end procedure.

procedure setSys_us:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSys_us.
    ghttSys_us = phttSys_us.
    run crudSys_us.
    delete object phttSys_us.
end procedure.

procedure readSys_us:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table sys_us 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCduti as character  no-undo.
    define input parameter table-handle phttSys_us.
    define variable vhttBuffer as handle no-undo.
    define buffer sys_us for sys_us.

    vhttBuffer = phttSys_us:default-buffer-handle.
    for first sys_us no-lock
        where sys_us.cduti = pcCduti:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sys_us:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSys_us no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSys_us:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table sys_us 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSys_us.
    define variable vhttBuffer as handle  no-undo.
    define buffer sys_us for sys_us.

    vhttBuffer = phttSys_us:default-buffer-handle.
    for each sys_us no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sys_us:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSys_us no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSys_us private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCduti    as handle  no-undo.
    define buffer sys_us for sys_us.

    create query vhttquery.
    vhttBuffer = ghttSys_us:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSys_us:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCduti).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first sys_us exclusive-lock
                where rowid(sys_us) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer sys_us:handle, 'cduti: ', substitute('&1', vhCduti:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer sys_us:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSys_us private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer sys_us for sys_us.

    create query vhttquery.
    vhttBuffer = ghttSys_us:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSys_us:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create sys_us.
            if not outils:copyValidField(buffer sys_us:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSys_us private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCduti    as handle  no-undo.
    define buffer sys_us for sys_us.

    create query vhttquery.
    vhttBuffer = ghttSys_us:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSys_us:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCduti).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first sys_us exclusive-lock
                where rowid(Sys_us) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer sys_us:handle, 'cduti: ', substitute('&1', vhCduti:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete sys_us no-error.
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

