/*------------------------------------------------------------------------
File        : trsup_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table trsup
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/trsup.i}
{application/include/error.i}
define variable ghtttrsup as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur , 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
       end case.
    end.
end function.

procedure crudTrsup private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTrsup.
    run updateTrsup.
    run createTrsup.
end procedure.

procedure setTrsup:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTrsup.
    ghttTrsup = phttTrsup.
    run crudTrsup.
    delete object phttTrsup.
end procedure.

procedure readTrsup:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table trsup Enregistrements supprimés à transférer au DPS

    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTrsup.
    define variable vhttBuffer as handle no-undo.
    define buffer trsup for trsup.

    vhttBuffer = phttTrsup:default-buffer-handle.
    for first trsup no-lock
        where :
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trsup:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrsup no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTrsup:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table trsup Enregistrements supprimés à transférer au DPS

    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTrsup.
    define variable vhttBuffer as handle  no-undo.
    define buffer trsup for trsup.

    vhttBuffer = phttTrsup:default-buffer-handle.
    for each trsup no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trsup:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrsup no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTrsup private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer trsup for trsup.

    create query vhttquery.
    vhttBuffer = ghttTrsup:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTrsup:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first trsup exclusive-lock
                where rowid(trsup) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trsup:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer trsup:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTrsup private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer trsup for trsup.

    create query vhttquery.
    vhttBuffer = ghttTrsup:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTrsup:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create trsup.
            if not outils:copyValidField(buffer trsup:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTrsup private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer trsup for trsup.

    create query vhttquery.
    vhttBuffer = ghttTrsup:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTrsup:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first trsup exclusive-lock
                where rowid(Trsup) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trsup:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete trsup no-error.
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

