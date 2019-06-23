/*------------------------------------------------------------------------
File        : sys_gr_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table sys_gr
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/sys_gr.i}
{application/include/error.i}
define variable ghttsys_gr as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNogrp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NoGrp, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NoGrp' then phNogrp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSys_gr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSys_gr.
    run updateSys_gr.
    run createSys_gr.
end procedure.

procedure setSys_gr:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSys_gr.
    ghttSys_gr = phttSys_gr.
    run crudSys_gr.
    delete object phttSys_gr.
end procedure.

procedure readSys_gr:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table sys_gr 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNogrp as integer    no-undo.
    define input parameter table-handle phttSys_gr.
    define variable vhttBuffer as handle no-undo.
    define buffer sys_gr for sys_gr.

    vhttBuffer = phttSys_gr:default-buffer-handle.
    for first sys_gr no-lock
        where sys_gr.NoGrp = piNogrp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sys_gr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSys_gr no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSys_gr:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table sys_gr 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSys_gr.
    define variable vhttBuffer as handle  no-undo.
    define buffer sys_gr for sys_gr.

    vhttBuffer = phttSys_gr:default-buffer-handle.
    for each sys_gr no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sys_gr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSys_gr no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSys_gr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNogrp    as handle  no-undo.
    define buffer sys_gr for sys_gr.

    create query vhttquery.
    vhttBuffer = ghttSys_gr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSys_gr:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNogrp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first sys_gr exclusive-lock
                where rowid(sys_gr) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer sys_gr:handle, 'NoGrp: ', substitute('&1', vhNogrp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer sys_gr:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSys_gr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer sys_gr for sys_gr.

    create query vhttquery.
    vhttBuffer = ghttSys_gr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSys_gr:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create sys_gr.
            if not outils:copyValidField(buffer sys_gr:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSys_gr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNogrp    as handle  no-undo.
    define buffer sys_gr for sys_gr.

    create query vhttquery.
    vhttBuffer = ghttSys_gr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSys_gr:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNogrp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first sys_gr exclusive-lock
                where rowid(Sys_gr) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer sys_gr:handle, 'NoGrp: ', substitute('&1', vhNogrp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete sys_gr no-error.
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

