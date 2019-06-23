/*------------------------------------------------------------------------
File        : airf1_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table airf1
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/airf1.i}
{application/include/error.i}
define variable ghttairf1 as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudAirf1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAirf1.
    run updateAirf1.
    run createAirf1.
end procedure.

procedure setAirf1:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAirf1.
    ghttAirf1 = phttAirf1.
    run crudAirf1.
    delete object phttAirf1.
end procedure.

procedure readAirf1:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table airf1 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAirf1.
    define variable vhttBuffer as handle no-undo.
    define buffer airf1 for airf1.

    vhttBuffer = phttAirf1:default-buffer-handle.
    for first airf1 no-lock
        where :
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer airf1:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAirf1 no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAirf1:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table airf1 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAirf1.
    define variable vhttBuffer as handle  no-undo.
    define buffer airf1 for airf1.

    vhttBuffer = phttAirf1:default-buffer-handle.
    for each airf1 no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer airf1:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAirf1 no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAirf1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer airf1 for airf1.

    create query vhttquery.
    vhttBuffer = ghttAirf1:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAirf1:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first airf1 exclusive-lock
                where rowid(airf1) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer airf1:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer airf1:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAirf1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer airf1 for airf1.

    create query vhttquery.
    vhttBuffer = ghttAirf1:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAirf1:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create airf1.
            if not outils:copyValidField(buffer airf1:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAirf1 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer airf1 for airf1.

    create query vhttquery.
    vhttBuffer = ghttAirf1:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAirf1:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first airf1 exclusive-lock
                where rowid(Airf1) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer airf1:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete airf1 no-error.
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

