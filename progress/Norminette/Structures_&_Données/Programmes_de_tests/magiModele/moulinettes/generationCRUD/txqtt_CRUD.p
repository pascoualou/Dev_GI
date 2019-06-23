/*------------------------------------------------------------------------
File        : txqtt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table txqtt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/txqtt.i}
{application/include/error.i}
define variable ghtttxqtt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNomdt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nomdt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTxqtt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTxqtt.
    run updateTxqtt.
    run createTxqtt.
end procedure.

procedure setTxqtt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTxqtt.
    ghttTxqtt = phttTxqtt.
    run crudTxqtt.
    delete object phttTxqtt.
end procedure.

procedure readTxqtt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table txqtt 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomdt as integer    no-undo.
    define input parameter table-handle phttTxqtt.
    define variable vhttBuffer as handle no-undo.
    define buffer txqtt for txqtt.

    vhttBuffer = phttTxqtt:default-buffer-handle.
    for first txqtt no-lock
        where txqtt.nomdt = piNomdt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer txqtt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTxqtt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTxqtt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table txqtt 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTxqtt.
    define variable vhttBuffer as handle  no-undo.
    define buffer txqtt for txqtt.

    vhttBuffer = phttTxqtt:default-buffer-handle.
    for each txqtt no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer txqtt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTxqtt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTxqtt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomdt    as handle  no-undo.
    define buffer txqtt for txqtt.

    create query vhttquery.
    vhttBuffer = ghttTxqtt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTxqtt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first txqtt exclusive-lock
                where rowid(txqtt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer txqtt:handle, 'nomdt: ', substitute('&1', vhNomdt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer txqtt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTxqtt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer txqtt for txqtt.

    create query vhttquery.
    vhttBuffer = ghttTxqtt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTxqtt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create txqtt.
            if not outils:copyValidField(buffer txqtt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTxqtt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomdt    as handle  no-undo.
    define buffer txqtt for txqtt.

    create query vhttquery.
    vhttBuffer = ghttTxqtt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTxqtt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first txqtt exclusive-lock
                where rowid(Txqtt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer txqtt:handle, 'nomdt: ', substitute('&1', vhNomdt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete txqtt no-error.
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

