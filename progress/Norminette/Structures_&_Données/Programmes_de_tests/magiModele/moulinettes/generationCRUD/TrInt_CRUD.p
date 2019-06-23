/*------------------------------------------------------------------------
File        : TrInt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table TrInt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/TrInt.i}
{application/include/error.i}
define variable ghttTrInt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoint as handle, output phNoidt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NoInt/NoIdt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NoInt' then phNoint = phBuffer:buffer-field(vi).
            when 'NoIdt' then phNoidt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTrint private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTrint.
    run updateTrint.
    run createTrint.
end procedure.

procedure setTrint:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTrint.
    ghttTrint = phttTrint.
    run crudTrint.
    delete object phttTrint.
end procedure.

procedure readTrint:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table TrInt Chaine Travaux : Traitement des Interventions
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoint as int64      no-undo.
    define input parameter piNoidt as int64      no-undo.
    define input parameter table-handle phttTrint.
    define variable vhttBuffer as handle no-undo.
    define buffer TrInt for TrInt.

    vhttBuffer = phttTrint:default-buffer-handle.
    for first TrInt no-lock
        where TrInt.NoInt = piNoint
          and TrInt.NoIdt = piNoidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer TrInt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrint no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTrint:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table TrInt Chaine Travaux : Traitement des Interventions
    Notes  : service externe. Critère piNoint = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoint as int64      no-undo.
    define input parameter table-handle phttTrint.
    define variable vhttBuffer as handle  no-undo.
    define buffer TrInt for TrInt.

    vhttBuffer = phttTrint:default-buffer-handle.
    if piNoint = ?
    then for each TrInt no-lock
        where TrInt.NoInt = piNoint:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer TrInt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each TrInt no-lock
        where TrInt.NoInt = piNoint:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer TrInt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrint no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTrint private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoint    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define buffer TrInt for TrInt.

    create query vhttquery.
    vhttBuffer = ghttTrint:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTrint:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoint, output vhNoidt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first TrInt exclusive-lock
                where rowid(TrInt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer TrInt:handle, 'NoInt/NoIdt: ', substitute('&1/&2', vhNoint:buffer-value(), vhNoidt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer TrInt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTrint private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer TrInt for TrInt.

    create query vhttquery.
    vhttBuffer = ghttTrint:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTrint:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create TrInt.
            if not outils:copyValidField(buffer TrInt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTrint private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoint    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define buffer TrInt for TrInt.

    create query vhttquery.
    vhttBuffer = ghttTrint:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTrint:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoint, output vhNoidt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first TrInt exclusive-lock
                where rowid(Trint) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer TrInt:handle, 'NoInt/NoIdt: ', substitute('&1/&2', vhNoint:buffer-value(), vhNoidt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete TrInt no-error.
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

