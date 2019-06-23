/*------------------------------------------------------------------------
File        : com_tb_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table com_tb
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/com_tb.i}
{application/include/error.i}
define variable ghttcom_tb as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNmtbl as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nmtbl, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nmtbl' then phNmtbl = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCom_tb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCom_tb.
    run updateCom_tb.
    run createCom_tb.
end procedure.

procedure setCom_tb:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCom_tb.
    ghttCom_tb = phttCom_tb.
    run crudCom_tb.
    delete object phttCom_tb.
end procedure.

procedure readCom_tb:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table com_tb 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcNmtbl as character  no-undo.
    define input parameter table-handle phttCom_tb.
    define variable vhttBuffer as handle no-undo.
    define buffer com_tb for com_tb.

    vhttBuffer = phttCom_tb:default-buffer-handle.
    for first com_tb no-lock
        where com_tb.nmtbl = pcNmtbl:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer com_tb:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCom_tb no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCom_tb:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table com_tb 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCom_tb.
    define variable vhttBuffer as handle  no-undo.
    define buffer com_tb for com_tb.

    vhttBuffer = phttCom_tb:default-buffer-handle.
    for each com_tb no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer com_tb:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCom_tb no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCom_tb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNmtbl    as handle  no-undo.
    define buffer com_tb for com_tb.

    create query vhttquery.
    vhttBuffer = ghttCom_tb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCom_tb:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNmtbl).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first com_tb exclusive-lock
                where rowid(com_tb) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer com_tb:handle, 'nmtbl: ', substitute('&1', vhNmtbl:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer com_tb:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCom_tb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer com_tb for com_tb.

    create query vhttquery.
    vhttBuffer = ghttCom_tb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCom_tb:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create com_tb.
            if not outils:copyValidField(buffer com_tb:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCom_tb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNmtbl    as handle  no-undo.
    define buffer com_tb for com_tb.

    create query vhttquery.
    vhttBuffer = ghttCom_tb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCom_tb:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNmtbl).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first com_tb exclusive-lock
                where rowid(Com_tb) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer com_tb:handle, 'nmtbl: ', substitute('&1', vhNmtbl:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete com_tb no-error.
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

