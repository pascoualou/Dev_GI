/*------------------------------------------------------------------------
File        : vacan_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table vacan
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttvacan as handle no-undo.     // le handle de la temp table à mettre à jour


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

procedure crudVacan private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteVacan.
    run updateVacan.
    run createVacan.
end procedure.

procedure setVacan:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttVacan.
    ghttVacan = phttVacan.
    run crudVacan.
    delete object phttVacan.
end procedure.

procedure readVacan:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table vacan 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttVacan.
    define variable vhttBuffer as handle no-undo.
    define buffer vacan for vacan.

    vhttBuffer = phttVacan:default-buffer-handle.
    for first vacan no-lock
        where :
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer vacan:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttVacan no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getVacan:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table vacan 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttVacan.
    define variable vhttBuffer as handle  no-undo.
    define buffer vacan for vacan.

    vhttBuffer = phttVacan:default-buffer-handle.
    for each vacan no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer vacan:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttVacan no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateVacan private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer vacan for vacan.

    create query vhttquery.
    vhttBuffer = ghttVacan:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttVacan:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first vacan exclusive-lock
                where rowid(vacan) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer vacan:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer vacan:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createVacan private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer vacan for vacan.

    create query vhttquery.
    vhttBuffer = ghttVacan:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttVacan:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create vacan.
            if not outils:copyValidField(buffer vacan:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteVacan private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer vacan for vacan.

    create query vhttquery.
    vhttBuffer = ghttVacan:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttVacan:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first vacan exclusive-lock
                where rowid(Vacan) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer vacan:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete vacan no-error.
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

procedure deleteVacanSurMandat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64 no-undo.
    
    define buffer vacan for vacan.

blocTrans:
    do transaction:
        for each vacan no-lock  
           where vacan.nomdt = piNumeroMandat:
            find current vacan exclusive-lock.    
            delete vacan no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.


