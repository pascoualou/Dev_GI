/*------------------------------------------------------------------------
File        : abur2_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table abur2
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttabur2 as handle no-undo.     // le handle de la temp table à mettre à jour


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

procedure crudAbur2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAbur2.
    run updateAbur2.
    run createAbur2.
end procedure.

procedure setAbur2:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAbur2.
    ghttAbur2 = phttAbur2.
    run crudAbur2.
    delete object phttAbur2.
end procedure.

procedure readAbur2:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table abur2 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAbur2.
    define variable vhttBuffer as handle no-undo.
    define buffer abur2 for abur2.

    vhttBuffer = phttAbur2:default-buffer-handle.
    for first abur2 no-lock
        where :
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer abur2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAbur2 no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAbur2:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table abur2 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAbur2.
    define variable vhttBuffer as handle  no-undo.
    define buffer abur2 for abur2.

    vhttBuffer = phttAbur2:default-buffer-handle.
    for each abur2 no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer abur2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAbur2 no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAbur2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer abur2 for abur2.

    create query vhttquery.
    vhttBuffer = ghttAbur2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAbur2:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first abur2 exclusive-lock
                where rowid(abur2) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer abur2:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer abur2:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAbur2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer abur2 for abur2.

    create query vhttquery.
    vhttBuffer = ghttAbur2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAbur2:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create abur2.
            if not outils:copyValidField(buffer abur2:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAbur2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer abur2 for abur2.

    create query vhttquery.
    vhttBuffer = ghttAbur2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAbur2:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first abur2 exclusive-lock
                where rowid(Abur2) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer abur2:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete abur2 no-error.
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

procedure deleteAbur2tSurMandat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer no-undo.
    
    define buffer abur2 for abur2.

blocTrans:
    do transaction:
        for each abur2 no-lock
           where abur2.nomdt = piNumeroMandat:
            find current abur2 exclusive-lock.     
            delete abur2 no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

