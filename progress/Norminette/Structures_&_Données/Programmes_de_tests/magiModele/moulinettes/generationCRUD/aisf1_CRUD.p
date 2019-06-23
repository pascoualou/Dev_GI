/*------------------------------------------------------------------------
File        : aisf1_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table aisf1
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/aisf1.i}
{application/include/error.i}
define variable ghttaisf1 as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudAisf1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAisf1.
    run updateAisf1.
    run createAisf1.
end procedure.

procedure setAisf1:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAisf1.
    ghttAisf1 = phttAisf1.
    run crudAisf1.
    delete object phttAisf1.
end procedure.

procedure readAisf1:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table aisf1 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAisf1.
    define variable vhttBuffer as handle no-undo.
    define buffer aisf1 for aisf1.

    vhttBuffer = phttAisf1:default-buffer-handle.
    for first aisf1 no-lock
        where :
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aisf1:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAisf1 no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAisf1:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table aisf1 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAisf1.
    define variable vhttBuffer as handle  no-undo.
    define buffer aisf1 for aisf1.

    vhttBuffer = phttAisf1:default-buffer-handle.
    for each aisf1 no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aisf1:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAisf1 no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAisf1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer aisf1 for aisf1.

    create query vhttquery.
    vhttBuffer = ghttAisf1:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAisf1:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aisf1 exclusive-lock
                where rowid(aisf1) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aisf1:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer aisf1:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAisf1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer aisf1 for aisf1.

    create query vhttquery.
    vhttBuffer = ghttAisf1:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAisf1:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create aisf1.
            if not outils:copyValidField(buffer aisf1:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAisf1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer aisf1 for aisf1.

    create query vhttquery.
    vhttBuffer = ghttAisf1:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAisf1:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aisf1 exclusive-lock
                where rowid(Aisf1) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aisf1:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete aisf1 no-error.
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

