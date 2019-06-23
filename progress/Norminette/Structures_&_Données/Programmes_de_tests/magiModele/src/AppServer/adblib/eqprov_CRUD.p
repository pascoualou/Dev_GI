/*------------------------------------------------------------------------
File        : eqprov_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table eqprov
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghtteqprov as handle no-undo.     // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoint as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noint, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noint' then phNoint = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEqprov private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEqprov.
    run updateEqprov.
    run createEqprov.
end procedure.

procedure setEqprov:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEqprov.
    ghttEqprov = phttEqprov.
    run crudEqprov.
    delete object phttEqprov.
end procedure.

procedure readEqprov:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table eqprov 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoint as integer    no-undo.
    define input parameter table-handle phttEqprov.
    define variable vhttBuffer as handle no-undo.
    define buffer eqprov for eqprov.

    vhttBuffer = phttEqprov:default-buffer-handle.
    for first eqprov no-lock
        where eqprov.noint = piNoint:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer eqprov:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEqprov no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEqprov:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table eqprov 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEqprov.
    define variable vhttBuffer as handle  no-undo.
    define buffer eqprov for eqprov.

    vhttBuffer = phttEqprov:default-buffer-handle.
    for each eqprov no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer eqprov:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEqprov no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEqprov private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNoint    as handle  no-undo.
    define buffer eqprov for eqprov.

    create query vhttquery.
    vhttBuffer = ghttEqprov:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEqprov:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoint).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first eqprov exclusive-lock
                where rowid(eqprov) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer eqprov:handle, 'noint: ', substitute('&1', vhNoint:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer eqprov:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEqprov private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer eqprov for eqprov.

    create query vhttquery.
    vhttBuffer = ghttEqprov:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEqprov:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create eqprov.
            if not outils:copyValidField(buffer eqprov:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEqprov private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNoint    as handle  no-undo.
    define buffer eqprov for eqprov.

    create query vhttquery.
    vhttBuffer = ghttEqprov:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEqprov:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoint).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first eqprov exclusive-lock
                where rowid(Eqprov) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer eqprov:handle, 'noint: ', substitute('&1', vhNoint:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete eqprov no-error.
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
