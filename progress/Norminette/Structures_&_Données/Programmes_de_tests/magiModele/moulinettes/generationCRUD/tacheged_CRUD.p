/*------------------------------------------------------------------------
File        : tacheged_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table tacheged
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/tacheged.i}
{application/include/error.i}
define variable ghtttacheged as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phEtat as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur etat, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'etat' then phEtat = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTacheged private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTacheged.
    run updateTacheged.
    run createTacheged.
end procedure.

procedure setTacheged:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTacheged.
    ghttTacheged = phttTacheged.
    run crudTacheged.
    delete object phttTacheged.
end procedure.

procedure readTacheged:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table tacheged 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcEtat as character  no-undo.
    define input parameter table-handle phttTacheged.
    define variable vhttBuffer as handle no-undo.
    define buffer tacheged for tacheged.

    vhttBuffer = phttTacheged:default-buffer-handle.
    for first tacheged no-lock
        where tacheged.etat = pcEtat:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tacheged:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTacheged no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTacheged:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table tacheged 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTacheged.
    define variable vhttBuffer as handle  no-undo.
    define buffer tacheged for tacheged.

    vhttBuffer = phttTacheged:default-buffer-handle.
    for each tacheged no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tacheged:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTacheged no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTacheged private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhEtat    as handle  no-undo.
    define buffer tacheged for tacheged.

    create query vhttquery.
    vhttBuffer = ghttTacheged:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTacheged:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhEtat).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tacheged exclusive-lock
                where rowid(tacheged) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tacheged:handle, 'etat: ', substitute('&1', vhEtat:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer tacheged:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTacheged private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer tacheged for tacheged.

    create query vhttquery.
    vhttBuffer = ghttTacheged:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTacheged:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create tacheged.
            if not outils:copyValidField(buffer tacheged:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTacheged private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhEtat    as handle  no-undo.
    define buffer tacheged for tacheged.

    create query vhttquery.
    vhttBuffer = ghttTacheged:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTacheged:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhEtat).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tacheged exclusive-lock
                where rowid(Tacheged) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tacheged:handle, 'etat: ', substitute('&1', vhEtat:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete tacheged no-error.
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

