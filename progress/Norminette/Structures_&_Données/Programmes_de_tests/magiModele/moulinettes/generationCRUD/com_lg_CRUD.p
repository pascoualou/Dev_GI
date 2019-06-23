/*------------------------------------------------------------------------
File        : com_lg_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table com_lg
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/com_lg.i}
{application/include/error.i}
define variable ghttcom_lg as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdlng as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdlng, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdlng' then phCdlng = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCom_lg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCom_lg.
    run updateCom_lg.
    run createCom_lg.
end procedure.

procedure setCom_lg:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCom_lg.
    ghttCom_lg = phttCom_lg.
    run crudCom_lg.
    delete object phttCom_lg.
end procedure.

procedure readCom_lg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table com_lg table des langues
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piCdlng as integer    no-undo.
    define input parameter table-handle phttCom_lg.
    define variable vhttBuffer as handle no-undo.
    define buffer com_lg for com_lg.

    vhttBuffer = phttCom_lg:default-buffer-handle.
    for first com_lg no-lock
        where com_lg.cdlng = piCdlng:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer com_lg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCom_lg no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCom_lg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table com_lg table des langues
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCom_lg.
    define variable vhttBuffer as handle  no-undo.
    define buffer com_lg for com_lg.

    vhttBuffer = phttCom_lg:default-buffer-handle.
    for each com_lg no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer com_lg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCom_lg no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCom_lg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdlng    as handle  no-undo.
    define buffer com_lg for com_lg.

    create query vhttquery.
    vhttBuffer = ghttCom_lg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCom_lg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdlng).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first com_lg exclusive-lock
                where rowid(com_lg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer com_lg:handle, 'cdlng: ', substitute('&1', vhCdlng:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer com_lg:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCom_lg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer com_lg for com_lg.

    create query vhttquery.
    vhttBuffer = ghttCom_lg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCom_lg:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create com_lg.
            if not outils:copyValidField(buffer com_lg:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCom_lg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdlng    as handle  no-undo.
    define buffer com_lg for com_lg.

    create query vhttquery.
    vhttBuffer = ghttCom_lg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCom_lg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdlng).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first com_lg exclusive-lock
                where rowid(Com_lg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer com_lg:handle, 'cdlng: ', substitute('&1', vhCdlng:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete com_lg no-error.
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

