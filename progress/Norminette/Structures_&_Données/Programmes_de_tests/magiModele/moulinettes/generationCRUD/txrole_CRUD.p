/*------------------------------------------------------------------------
File        : txrole_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table txrole
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/txrole.i}
{application/include/error.i}
define variable ghtttxrole as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTprol as handle, output phNorol as handle, output phNotxt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tprol/norol/notxt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tprol' then phTprol = phBuffer:buffer-field(vi).
            when 'norol' then phNorol = phBuffer:buffer-field(vi).
            when 'notxt' then phNotxt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTxrole private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTxrole.
    run updateTxrole.
    run createTxrole.
end procedure.

procedure setTxrole:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTxrole.
    ghttTxrole = phttTxrole.
    run crudTxrole.
    delete object phttTxrole.
end procedure.

procedure readTxrole:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table txrole 1207/0082 - reglement direct loc-> prop
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character  no-undo.
    define input parameter piNorol as int64      no-undo.
    define input parameter piNotxt as integer    no-undo.
    define input parameter table-handle phttTxrole.
    define variable vhttBuffer as handle no-undo.
    define buffer txrole for txrole.

    vhttBuffer = phttTxrole:default-buffer-handle.
    for first txrole no-lock
        where txrole.tprol = pcTprol
          and txrole.norol = piNorol
          and txrole.notxt = piNotxt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer txrole:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTxrole no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTxrole:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table txrole 1207/0082 - reglement direct loc-> prop
    Notes  : service externe. Critère piNorol = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character  no-undo.
    define input parameter piNorol as int64      no-undo.
    define input parameter table-handle phttTxrole.
    define variable vhttBuffer as handle  no-undo.
    define buffer txrole for txrole.

    vhttBuffer = phttTxrole:default-buffer-handle.
    if piNorol = ?
    then for each txrole no-lock
        where txrole.tprol = pcTprol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer txrole:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each txrole no-lock
        where txrole.tprol = pcTprol
          and txrole.norol = piNorol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer txrole:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTxrole no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTxrole private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhNotxt    as handle  no-undo.
    define buffer txrole for txrole.

    create query vhttquery.
    vhttBuffer = ghttTxrole:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTxrole:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol, output vhNotxt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first txrole exclusive-lock
                where rowid(txrole) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer txrole:handle, 'tprol/norol/notxt: ', substitute('&1/&2/&3', vhTprol:buffer-value(), vhNorol:buffer-value(), vhNotxt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer txrole:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTxrole private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer txrole for txrole.

    create query vhttquery.
    vhttBuffer = ghttTxrole:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTxrole:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create txrole.
            if not outils:copyValidField(buffer txrole:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTxrole private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhNotxt    as handle  no-undo.
    define buffer txrole for txrole.

    create query vhttquery.
    vhttBuffer = ghttTxrole:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTxrole:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol, output vhNotxt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first txrole exclusive-lock
                where rowid(Txrole) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer txrole:handle, 'tprol/norol/notxt: ', substitute('&1/&2/&3', vhTprol:buffer-value(), vhNorol:buffer-value(), vhNotxt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete txrole no-error.
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

