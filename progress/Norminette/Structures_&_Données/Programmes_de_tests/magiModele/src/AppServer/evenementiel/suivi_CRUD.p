/*------------------------------------------------------------------------
File        : suivi_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table suivi
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/suivi.i}
{application/include/error.i}
define variable ghttsuivi as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNosui as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nosui, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nosui' then phNosui = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSuivi private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSuivi.
    run updateSuivi.
    run createSuivi.
end procedure.

procedure setSuivi:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSuivi.
    ghttSuivi = phttSuivi.
    run crudSuivi.
    delete object phttSuivi.
end procedure.

procedure readSuivi:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table suivi 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNosui as integer    no-undo.
    define input parameter table-handle phttSuivi.
    define variable vhttBuffer as handle no-undo.
    define buffer suivi for suivi.

    vhttBuffer = phttSuivi:default-buffer-handle.
    for first suivi no-lock
        where suivi.nosui = piNosui:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer suivi:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSuivi no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSuivi:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table suivi 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSuivi.
    define variable vhttBuffer as handle  no-undo.
    define buffer suivi for suivi.

    vhttBuffer = phttSuivi:default-buffer-handle.
    for each suivi no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer suivi:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSuivi no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSuivi private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNosui    as handle  no-undo.
    define buffer suivi for suivi.

    create query vhttquery.
    vhttBuffer = ghttSuivi:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSuivi:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNosui).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first suivi exclusive-lock
                where rowid(suivi) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer suivi:handle, 'nosui: ', substitute('&1', vhNosui:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer suivi:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSuivi private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer suivi for suivi.

    create query vhttquery.
    vhttBuffer = ghttSuivi:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSuivi:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create suivi.
            if not outils:copyValidField(buffer suivi:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSuivi private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNosui    as handle  no-undo.
    define buffer suivi for suivi.

    create query vhttquery.
    vhttBuffer = ghttSuivi:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSuivi:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNosui).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first suivi exclusive-lock
                where rowid(Suivi) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer suivi:handle, 'nosui: ', substitute('&1', vhNosui:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete suivi no-error.
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

procedure deleteSuiviSurNoidt:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeIdentifiant   as character no-undo.
    define input parameter piNumeroIdentifiant as int64     no-undo.
    
    define buffer suivi for suivi.

message "deleteSuiviSurNoidt "  pcTypeIdentifiant "// " piNumeroIdentifiant.

blocTrans:
    do transaction:
        for each suivi exclusive-lock
           where suivi.tpidt = pcTypeIdentifiant 
             and suivi.noidt = piNumeroIdentifiant:
            delete suivi no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

