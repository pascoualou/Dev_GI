/*------------------------------------------------------------------------
File        : trxet_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table trxet
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/trxet.i}
{application/include/error.i}
define variable ghtttrxet as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNotrx as handle, output phTpapp as handle, output phNoapp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur notrx/tpapp/noapp, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'notrx' then phNotrx = phBuffer:buffer-field(vi).
            when 'tpapp' then phTpapp = phBuffer:buffer-field(vi).
            when 'noapp' then phNoapp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTrxet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTrxet.
    run updateTrxet.
    run createTrxet.
end procedure.

procedure setTrxet:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTrxet.
    ghttTrxet = phttTrxet.
    run crudTrxet.
    delete object phttTrxet.
end procedure.

procedure readTrxet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table trxet 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNotrx as int64      no-undo.
    define input parameter pcTpapp as character  no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter table-handle phttTrxet.
    define variable vhttBuffer as handle no-undo.
    define buffer trxet for trxet.

    vhttBuffer = phttTrxet:default-buffer-handle.
    for first trxet no-lock
        where trxet.notrx = piNotrx
          and trxet.tpapp = pcTpapp
          and trxet.noapp = piNoapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trxet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrxet no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTrxet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table trxet 
    Notes  : service externe. Critère pcTpapp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNotrx as int64      no-undo.
    define input parameter pcTpapp as character  no-undo.
    define input parameter table-handle phttTrxet.
    define variable vhttBuffer as handle  no-undo.
    define buffer trxet for trxet.

    vhttBuffer = phttTrxet:default-buffer-handle.
    if pcTpapp = ?
    then for each trxet no-lock
        where trxet.notrx = piNotrx:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trxet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each trxet no-lock
        where trxet.notrx = piNotrx
          and trxet.tpapp = pcTpapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trxet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrxet no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTrxet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNotrx    as handle  no-undo.
    define variable vhTpapp    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define buffer trxet for trxet.

    create query vhttquery.
    vhttBuffer = ghttTrxet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTrxet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNotrx, output vhTpapp, output vhNoapp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first trxet exclusive-lock
                where rowid(trxet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trxet:handle, 'notrx/tpapp/noapp: ', substitute('&1/&2/&3', vhNotrx:buffer-value(), vhTpapp:buffer-value(), vhNoapp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer trxet:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTrxet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer trxet for trxet.

    create query vhttquery.
    vhttBuffer = ghttTrxet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTrxet:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create trxet.
            if not outils:copyValidField(buffer trxet:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTrxet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNotrx    as handle  no-undo.
    define variable vhTpapp    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define buffer trxet for trxet.

    create query vhttquery.
    vhttBuffer = ghttTrxet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTrxet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNotrx, output vhTpapp, output vhNoapp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first trxet exclusive-lock
                where rowid(Trxet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trxet:handle, 'notrx/tpapp/noapp: ', substitute('&1/&2/&3', vhNotrx:buffer-value(), vhTpapp:buffer-value(), vhNoapp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete trxet no-error.
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

