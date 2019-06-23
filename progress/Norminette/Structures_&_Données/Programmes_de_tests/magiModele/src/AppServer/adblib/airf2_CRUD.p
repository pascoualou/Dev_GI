/*------------------------------------------------------------------------
File        : airf2_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table airf2
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttairf2 as handle no-undo.     // le handle de la temp table à mettre à jour


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

procedure crudAirf2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAirf2.
    run updateAirf2.
    run createAirf2.
end procedure.

procedure setAirf2:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAirf2.
    ghttAirf2 = phttAirf2.
    run crudAirf2.
    delete object phttAirf2.
end procedure.

procedure readAirf2:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table airf2 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAirf2.
    define variable vhttBuffer as handle no-undo.
    define buffer airf2 for airf2.

    vhttBuffer = phttAirf2:default-buffer-handle.
    for first airf2 no-lock
        where :
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer airf2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAirf2 no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAirf2:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table airf2 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAirf2.
    define variable vhttBuffer as handle  no-undo.
    define buffer airf2 for airf2.

    vhttBuffer = phttAirf2:default-buffer-handle.
    for each airf2 no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer airf2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAirf2 no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAirf2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer airf2 for airf2.

    create query vhttquery.
    vhttBuffer = ghttAirf2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAirf2:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first airf2 exclusive-lock
                where rowid(airf2) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer airf2:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer airf2:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAirf2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer airf2 for airf2.

    create query vhttquery.
    vhttBuffer = ghttAirf2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAirf2:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create airf2.
            if not outils:copyValidField(buffer airf2:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAirf2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer airf2 for airf2.

    create query vhttquery.
    vhttBuffer = ghttAirf2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAirf2:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first airf2 exclusive-lock
                where rowid(Airf2) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer airf2:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete airf2 no-error.
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

procedure deleteAirf2SurMandat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer no-undo.
    
    define buffer airf2 for airf2.

message "deleteAirf2SurMandat "  piNumeroMandat.

blocTrans:
    do transaction:
        for each airf2 no-lock
           where airf2.nomdt = piNumeroMandat:
            find current airf2 exclusive-lock.   
            delete airf2 no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
