/*------------------------------------------------------------------------
File        : budge_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table budge
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/budge.i}
{application/include/error.i}
define variable ghttbudge as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpbud as handle, output phNobud as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpbud/nobud, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpbud' then phTpbud = phBuffer:buffer-field(vi).
            when 'nobud' then phNobud = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudBudge private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteBudge.
    run updateBudge.
    run createBudge.
end procedure.

procedure setBudge:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttBudge.
    ghttBudge = phttBudge.
    run crudBudge.
    delete object phttBudge.
end procedure.

procedure readBudge:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table budge 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpbud as character  no-undo.
    define input parameter piNobud as int64      no-undo.
    define input parameter table-handle phttBudge.
    define variable vhttBuffer as handle no-undo.
    define buffer budge for budge.

    vhttBuffer = phttBudge:default-buffer-handle.
    for first budge no-lock
        where budge.tpbud = pcTpbud
          and budge.nobud = piNobud:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer budge:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttBudge no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getBudge:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table budge 
    Notes  : service externe. Critère pcTpbud = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpbud as character  no-undo.
    define input parameter table-handle phttBudge.
    define variable vhttBuffer as handle  no-undo.
    define buffer budge for budge.

    vhttBuffer = phttBudge:default-buffer-handle.
    if pcTpbud = ?
    then for each budge no-lock
        where budge.tpbud = pcTpbud:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer budge:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each budge no-lock
        where budge.tpbud = pcTpbud:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer budge:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttBudge no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateBudge private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpbud    as handle  no-undo.
    define variable vhNobud    as handle  no-undo.
    define buffer budge for budge.

    create query vhttquery.
    vhttBuffer = ghttBudge:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttBudge:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpbud, output vhNobud).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first budge exclusive-lock
                where rowid(budge) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer budge:handle, 'tpbud/nobud: ', substitute('&1/&2', vhTpbud:buffer-value(), vhNobud:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer budge:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createBudge private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer budge for budge.

    create query vhttquery.
    vhttBuffer = ghttBudge:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttBudge:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create budge.
            if not outils:copyValidField(buffer budge:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteBudge private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpbud    as handle  no-undo.
    define variable vhNobud    as handle  no-undo.
    define buffer budge for budge.

    create query vhttquery.
    vhttBuffer = ghttBudge:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttBudge:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpbud, output vhNobud).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first budge exclusive-lock
                where rowid(Budge) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer budge:handle, 'tpbud/nobud: ', substitute('&1/&2', vhTpbud:buffer-value(), vhNobud:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete budge no-error.
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

