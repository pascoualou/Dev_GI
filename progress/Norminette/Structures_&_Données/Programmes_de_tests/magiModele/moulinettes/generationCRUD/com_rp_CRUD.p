/*------------------------------------------------------------------------
File        : com_rp_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table com_rp
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/com_rp.i}
{application/include/error.i}
define variable ghttcom_rp as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNmprg as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nmprg, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nmprg' then phNmprg = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCom_rp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCom_rp.
    run updateCom_rp.
    run createCom_rp.
end procedure.

procedure setCom_rp:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCom_rp.
    ghttCom_rp = phttCom_rp.
    run crudCom_rp.
    delete object phttCom_rp.
end procedure.

procedure readCom_rp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table com_rp 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcNmprg as character  no-undo.
    define input parameter table-handle phttCom_rp.
    define variable vhttBuffer as handle no-undo.
    define buffer com_rp for com_rp.

    vhttBuffer = phttCom_rp:default-buffer-handle.
    for first com_rp no-lock
        where com_rp.nmprg = pcNmprg:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer com_rp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCom_rp no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCom_rp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table com_rp 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCom_rp.
    define variable vhttBuffer as handle  no-undo.
    define buffer com_rp for com_rp.

    vhttBuffer = phttCom_rp:default-buffer-handle.
    for each com_rp no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer com_rp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCom_rp no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCom_rp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNmprg    as handle  no-undo.
    define buffer com_rp for com_rp.

    create query vhttquery.
    vhttBuffer = ghttCom_rp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCom_rp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNmprg).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first com_rp exclusive-lock
                where rowid(com_rp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer com_rp:handle, 'nmprg: ', substitute('&1', vhNmprg:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer com_rp:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCom_rp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer com_rp for com_rp.

    create query vhttquery.
    vhttBuffer = ghttCom_rp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCom_rp:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create com_rp.
            if not outils:copyValidField(buffer com_rp:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCom_rp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNmprg    as handle  no-undo.
    define buffer com_rp for com_rp.

    create query vhttquery.
    vhttBuffer = ghttCom_rp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCom_rp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNmprg).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first com_rp exclusive-lock
                where rowid(Com_rp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer com_rp:handle, 'nmprg: ', substitute('&1', vhNmprg:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete com_rp no-error.
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

