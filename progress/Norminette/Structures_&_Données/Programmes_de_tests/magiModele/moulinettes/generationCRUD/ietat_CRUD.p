/*------------------------------------------------------------------------
File        : ietat_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ietat
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ietat.i}
{application/include/error.i}
define variable ghttietat as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phEtat-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur etat-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'etat-cd' then phEtat-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIetat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIetat.
    run updateIetat.
    run createIetat.
end procedure.

procedure setIetat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIetat.
    ghttIetat = phttIetat.
    run crudIetat.
    delete object phttIetat.
end procedure.

procedure readIetat:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ietat Liste des programmes associes a un etat de reporting.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piEtat-cd as integer    no-undo.
    define input parameter table-handle phttIetat.
    define variable vhttBuffer as handle no-undo.
    define buffer ietat for ietat.

    vhttBuffer = phttIetat:default-buffer-handle.
    for first ietat no-lock
        where ietat.etat-cd = piEtat-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ietat:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIetat no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIetat:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ietat Liste des programmes associes a un etat de reporting.
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIetat.
    define variable vhttBuffer as handle  no-undo.
    define buffer ietat for ietat.

    vhttBuffer = phttIetat:default-buffer-handle.
    for each ietat no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ietat:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIetat no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIetat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhEtat-cd    as handle  no-undo.
    define buffer ietat for ietat.

    create query vhttquery.
    vhttBuffer = ghttIetat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIetat:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhEtat-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ietat exclusive-lock
                where rowid(ietat) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ietat:handle, 'etat-cd: ', substitute('&1', vhEtat-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ietat:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIetat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ietat for ietat.

    create query vhttquery.
    vhttBuffer = ghttIetat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIetat:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ietat.
            if not outils:copyValidField(buffer ietat:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIetat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhEtat-cd    as handle  no-undo.
    define buffer ietat for ietat.

    create query vhttquery.
    vhttBuffer = ghttIetat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIetat:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhEtat-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ietat exclusive-lock
                where rowid(Ietat) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ietat:handle, 'etat-cd: ', substitute('&1', vhEtat-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ietat no-error.
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

