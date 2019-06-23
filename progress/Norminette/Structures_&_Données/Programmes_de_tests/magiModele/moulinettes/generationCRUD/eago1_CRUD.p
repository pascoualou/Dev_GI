/*------------------------------------------------------------------------
File        : eago1_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table eago1
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/eago1.i}
{application/include/error.i}
define variable ghtteago1 as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoint as handle, output phNogrp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noint/nogrp, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noint' then phNoint = phBuffer:buffer-field(vi).
            when 'nogrp' then phNogrp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEago1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEago1.
    run updateEago1.
    run createEago1.
end procedure.

procedure setEago1:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEago1.
    ghttEago1 = phttEago1.
    run crudEago1.
    delete object phttEago1.
end procedure.

procedure readEago1:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table eago1 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoint as integer    no-undo.
    define input parameter piNogrp as integer    no-undo.
    define input parameter table-handle phttEago1.
    define variable vhttBuffer as handle no-undo.
    define buffer eago1 for eago1.

    vhttBuffer = phttEago1:default-buffer-handle.
    for first eago1 no-lock
        where eago1.noint = piNoint
          and eago1.nogrp = piNogrp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer eago1:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEago1 no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEago1:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table eago1 
    Notes  : service externe. Critère piNoint = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoint as integer    no-undo.
    define input parameter table-handle phttEago1.
    define variable vhttBuffer as handle  no-undo.
    define buffer eago1 for eago1.

    vhttBuffer = phttEago1:default-buffer-handle.
    if piNoint = ?
    then for each eago1 no-lock
        where eago1.noint = piNoint:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer eago1:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each eago1 no-lock
        where eago1.noint = piNoint:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer eago1:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEago1 no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEago1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoint    as handle  no-undo.
    define variable vhNogrp    as handle  no-undo.
    define buffer eago1 for eago1.

    create query vhttquery.
    vhttBuffer = ghttEago1:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEago1:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoint, output vhNogrp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first eago1 exclusive-lock
                where rowid(eago1) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer eago1:handle, 'noint/nogrp: ', substitute('&1/&2', vhNoint:buffer-value(), vhNogrp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer eago1:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEago1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer eago1 for eago1.

    create query vhttquery.
    vhttBuffer = ghttEago1:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEago1:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create eago1.
            if not outils:copyValidField(buffer eago1:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEago1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoint    as handle  no-undo.
    define variable vhNogrp    as handle  no-undo.
    define buffer eago1 for eago1.

    create query vhttquery.
    vhttBuffer = ghttEago1:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEago1:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoint, output vhNogrp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first eago1 exclusive-lock
                where rowid(Eago1) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer eago1:handle, 'noint/nogrp: ', substitute('&1/&2', vhNoint:buffer-value(), vhNogrp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete eago1 no-error.
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

