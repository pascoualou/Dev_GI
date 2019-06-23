/*------------------------------------------------------------------------
File        : eawo1_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table eawo1
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/eawo1.i}
{application/include/error.i}
define variable ghtteawo1 as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudEawo1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEawo1.
    run updateEawo1.
    run createEawo1.
end procedure.

procedure setEawo1:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEawo1.
    ghttEawo1 = phttEawo1.
    run crudEawo1.
    delete object phttEawo1.
end procedure.

procedure readEawo1:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table eawo1 Stocke au format word les ordres du jour
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoint as integer    no-undo.
    define input parameter piNogrp as integer    no-undo.
    define input parameter table-handle phttEawo1.
    define variable vhttBuffer as handle no-undo.
    define buffer eawo1 for eawo1.

    vhttBuffer = phttEawo1:default-buffer-handle.
    for first eawo1 no-lock
        where eawo1.noint = piNoint
          and eawo1.nogrp = piNogrp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer eawo1:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEawo1 no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEawo1:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table eawo1 Stocke au format word les ordres du jour
    Notes  : service externe. Critère piNoint = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoint as integer    no-undo.
    define input parameter table-handle phttEawo1.
    define variable vhttBuffer as handle  no-undo.
    define buffer eawo1 for eawo1.

    vhttBuffer = phttEawo1:default-buffer-handle.
    if piNoint = ?
    then for each eawo1 no-lock
        where eawo1.noint = piNoint:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer eawo1:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each eawo1 no-lock
        where eawo1.noint = piNoint:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer eawo1:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEawo1 no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEawo1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoint    as handle  no-undo.
    define variable vhNogrp    as handle  no-undo.
    define buffer eawo1 for eawo1.

    create query vhttquery.
    vhttBuffer = ghttEawo1:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEawo1:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoint, output vhNogrp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first eawo1 exclusive-lock
                where rowid(eawo1) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer eawo1:handle, 'noint/nogrp: ', substitute('&1/&2', vhNoint:buffer-value(), vhNogrp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer eawo1:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEawo1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer eawo1 for eawo1.

    create query vhttquery.
    vhttBuffer = ghttEawo1:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEawo1:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create eawo1.
            if not outils:copyValidField(buffer eawo1:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEawo1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoint    as handle  no-undo.
    define variable vhNogrp    as handle  no-undo.
    define buffer eawo1 for eawo1.

    create query vhttquery.
    vhttBuffer = ghttEawo1:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEawo1:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoint, output vhNogrp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first eawo1 exclusive-lock
                where rowid(Eawo1) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer eawo1:handle, 'noint/nogrp: ', substitute('&1/&2', vhNoint:buffer-value(), vhNogrp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete eawo1 no-error.
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

