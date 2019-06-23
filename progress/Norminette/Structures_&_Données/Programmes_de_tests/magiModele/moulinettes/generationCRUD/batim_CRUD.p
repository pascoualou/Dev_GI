/*------------------------------------------------------------------------
File        : batim_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table batim
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/batim.i}
{application/include/error.i}
define variable ghttbatim as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNobat as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nobat, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nobat' then phNobat = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudBatim private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteBatim.
    run updateBatim.
    run createBatim.
end procedure.

procedure setBatim:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttBatim.
    ghttBatim = phttBatim.
    run crudBatim.
    delete object phttBatim.
end procedure.

procedure readBatim:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table batim 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNobat as integer    no-undo.
    define input parameter table-handle phttBatim.
    define variable vhttBuffer as handle no-undo.
    define buffer batim for batim.

    vhttBuffer = phttBatim:default-buffer-handle.
    for first batim no-lock
        where batim.nobat = piNobat:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer batim:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttBatim no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getBatim:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table batim 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttBatim.
    define variable vhttBuffer as handle  no-undo.
    define buffer batim for batim.

    vhttBuffer = phttBatim:default-buffer-handle.
    for each batim no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer batim:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttBatim no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateBatim private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNobat    as handle  no-undo.
    define buffer batim for batim.

    create query vhttquery.
    vhttBuffer = ghttBatim:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttBatim:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNobat).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first batim exclusive-lock
                where rowid(batim) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer batim:handle, 'nobat: ', substitute('&1', vhNobat:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer batim:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createBatim private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer batim for batim.

    create query vhttquery.
    vhttBuffer = ghttBatim:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttBatim:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create batim.
            if not outils:copyValidField(buffer batim:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteBatim private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNobat    as handle  no-undo.
    define buffer batim for batim.

    create query vhttquery.
    vhttBuffer = ghttBatim:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttBatim:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNobat).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first batim exclusive-lock
                where rowid(Batim) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer batim:handle, 'nobat: ', substitute('&1', vhNobat:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete batim no-error.
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

