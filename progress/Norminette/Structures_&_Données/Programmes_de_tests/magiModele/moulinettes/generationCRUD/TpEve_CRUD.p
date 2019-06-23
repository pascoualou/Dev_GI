/*------------------------------------------------------------------------
File        : TpEve_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table TpEve
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/TpEve.i}
{application/include/error.i}
define variable ghttTpEve as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoact as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NoAct, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NoAct' then phNoact = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTpeve private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTpeve.
    run updateTpeve.
    run createTpeve.
end procedure.

procedure setTpeve:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTpeve.
    ghttTpeve = phttTpeve.
    run crudTpeve.
    delete object phttTpeve.
end procedure.

procedure readTpeve:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table TpEve 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoact as integer    no-undo.
    define input parameter table-handle phttTpeve.
    define variable vhttBuffer as handle no-undo.
    define buffer TpEve for TpEve.

    vhttBuffer = phttTpeve:default-buffer-handle.
    for first TpEve no-lock
        where TpEve.NoAct = piNoact:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer TpEve:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTpeve no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTpeve:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table TpEve 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTpeve.
    define variable vhttBuffer as handle  no-undo.
    define buffer TpEve for TpEve.

    vhttBuffer = phttTpeve:default-buffer-handle.
    for each TpEve no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer TpEve:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTpeve no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTpeve private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoact    as handle  no-undo.
    define buffer TpEve for TpEve.

    create query vhttquery.
    vhttBuffer = ghttTpeve:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTpeve:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoact).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first TpEve exclusive-lock
                where rowid(TpEve) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer TpEve:handle, 'NoAct: ', substitute('&1', vhNoact:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer TpEve:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTpeve private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer TpEve for TpEve.

    create query vhttquery.
    vhttBuffer = ghttTpeve:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTpeve:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create TpEve.
            if not outils:copyValidField(buffer TpEve:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTpeve private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoact    as handle  no-undo.
    define buffer TpEve for TpEve.

    create query vhttquery.
    vhttBuffer = ghttTpeve:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTpeve:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoact).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first TpEve exclusive-lock
                where rowid(Tpeve) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer TpEve:handle, 'NoAct: ', substitute('&1', vhNoact:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete TpEve no-error.
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

