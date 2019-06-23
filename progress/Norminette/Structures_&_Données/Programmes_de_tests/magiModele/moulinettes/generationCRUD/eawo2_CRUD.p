/*------------------------------------------------------------------------
File        : eawo2_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table eawo2
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/eawo2.i}
{application/include/error.i}
define variable ghtteawo2 as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoint as handle, output phNogrp as handle, output phNoadd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noint/nogrp/noadd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noint' then phNoint = phBuffer:buffer-field(vi).
            when 'nogrp' then phNogrp = phBuffer:buffer-field(vi).
            when 'noadd' then phNoadd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEawo2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEawo2.
    run updateEawo2.
    run createEawo2.
end procedure.

procedure setEawo2:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEawo2.
    ghttEawo2 = phttEawo2.
    run crudEawo2.
    delete object phttEawo2.
end procedure.

procedure readEawo2:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table eawo2 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoint as integer    no-undo.
    define input parameter piNogrp as integer    no-undo.
    define input parameter piNoadd as integer    no-undo.
    define input parameter table-handle phttEawo2.
    define variable vhttBuffer as handle no-undo.
    define buffer eawo2 for eawo2.

    vhttBuffer = phttEawo2:default-buffer-handle.
    for first eawo2 no-lock
        where eawo2.noint = piNoint
          and eawo2.nogrp = piNogrp
          and eawo2.noadd = piNoadd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer eawo2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEawo2 no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEawo2:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table eawo2 
    Notes  : service externe. Critère piNogrp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoint as integer    no-undo.
    define input parameter piNogrp as integer    no-undo.
    define input parameter table-handle phttEawo2.
    define variable vhttBuffer as handle  no-undo.
    define buffer eawo2 for eawo2.

    vhttBuffer = phttEawo2:default-buffer-handle.
    if piNogrp = ?
    then for each eawo2 no-lock
        where eawo2.noint = piNoint:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer eawo2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each eawo2 no-lock
        where eawo2.noint = piNoint
          and eawo2.nogrp = piNogrp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer eawo2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEawo2 no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEawo2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoint    as handle  no-undo.
    define variable vhNogrp    as handle  no-undo.
    define variable vhNoadd    as handle  no-undo.
    define buffer eawo2 for eawo2.

    create query vhttquery.
    vhttBuffer = ghttEawo2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEawo2:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoint, output vhNogrp, output vhNoadd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first eawo2 exclusive-lock
                where rowid(eawo2) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer eawo2:handle, 'noint/nogrp/noadd: ', substitute('&1/&2/&3', vhNoint:buffer-value(), vhNogrp:buffer-value(), vhNoadd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer eawo2:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEawo2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer eawo2 for eawo2.

    create query vhttquery.
    vhttBuffer = ghttEawo2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEawo2:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create eawo2.
            if not outils:copyValidField(buffer eawo2:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEawo2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoint    as handle  no-undo.
    define variable vhNogrp    as handle  no-undo.
    define variable vhNoadd    as handle  no-undo.
    define buffer eawo2 for eawo2.

    create query vhttquery.
    vhttBuffer = ghttEawo2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEawo2:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoint, output vhNogrp, output vhNoadd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first eawo2 exclusive-lock
                where rowid(Eawo2) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer eawo2:handle, 'noint/nogrp/noadd: ', substitute('&1/&2/&3', vhNoint:buffer-value(), vhNogrp:buffer-value(), vhNoadd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete eawo2 no-error.
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

