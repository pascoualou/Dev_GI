/*------------------------------------------------------------------------
File        : eago2_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table eago2
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/eago2.i}
{application/include/error.i}
define variable ghtteago2 as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoint as handle, output phNoadd as handle, output phNogrp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noint/noadd/nogrp, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noint' then phNoint = phBuffer:buffer-field(vi).
            when 'noadd' then phNoadd = phBuffer:buffer-field(vi).
            when 'nogrp' then phNogrp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEago2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEago2.
    run updateEago2.
    run createEago2.
end procedure.

procedure setEago2:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEago2.
    ghttEago2 = phttEago2.
    run crudEago2.
    delete object phttEago2.
end procedure.

procedure readEago2:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table eago2 Stockage du texte par tranches de 5 lignes de 75 caractères (max 999 lig)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoint as integer    no-undo.
    define input parameter piNoadd as integer    no-undo.
    define input parameter piNogrp as integer    no-undo.
    define input parameter table-handle phttEago2.
    define variable vhttBuffer as handle no-undo.
    define buffer eago2 for eago2.

    vhttBuffer = phttEago2:default-buffer-handle.
    for first eago2 no-lock
        where eago2.noint = piNoint
          and eago2.noadd = piNoadd
          and eago2.nogrp = piNogrp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer eago2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEago2 no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEago2:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table eago2 Stockage du texte par tranches de 5 lignes de 75 caractères (max 999 lig)
    Notes  : service externe. Critère piNoadd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoint as integer    no-undo.
    define input parameter piNoadd as integer    no-undo.
    define input parameter table-handle phttEago2.
    define variable vhttBuffer as handle  no-undo.
    define buffer eago2 for eago2.

    vhttBuffer = phttEago2:default-buffer-handle.
    if piNoadd = ?
    then for each eago2 no-lock
        where eago2.noint = piNoint:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer eago2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each eago2 no-lock
        where eago2.noint = piNoint
          and eago2.noadd = piNoadd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer eago2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEago2 no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEago2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoint    as handle  no-undo.
    define variable vhNoadd    as handle  no-undo.
    define variable vhNogrp    as handle  no-undo.
    define buffer eago2 for eago2.

    create query vhttquery.
    vhttBuffer = ghttEago2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEago2:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoint, output vhNoadd, output vhNogrp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first eago2 exclusive-lock
                where rowid(eago2) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer eago2:handle, 'noint/noadd/nogrp: ', substitute('&1/&2/&3', vhNoint:buffer-value(), vhNoadd:buffer-value(), vhNogrp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer eago2:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEago2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer eago2 for eago2.

    create query vhttquery.
    vhttBuffer = ghttEago2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEago2:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create eago2.
            if not outils:copyValidField(buffer eago2:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEago2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoint    as handle  no-undo.
    define variable vhNoadd    as handle  no-undo.
    define variable vhNogrp    as handle  no-undo.
    define buffer eago2 for eago2.

    create query vhttquery.
    vhttBuffer = ghttEago2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEago2:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoint, output vhNoadd, output vhNogrp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first eago2 exclusive-lock
                where rowid(Eago2) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer eago2:handle, 'noint/noadd/nogrp: ', substitute('&1/&2/&3', vhNoint:buffer-value(), vhNoadd:buffer-value(), vhNogrp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete eago2 no-error.
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

