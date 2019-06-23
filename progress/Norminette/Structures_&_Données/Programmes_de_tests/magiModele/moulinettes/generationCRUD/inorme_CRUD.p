/*------------------------------------------------------------------------
File        : inorme_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table inorme
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/inorme.i}
{application/include/error.i}
define variable ghttinorme as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNorme-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur norme-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'norme-cd' then phNorme-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudInorme private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteInorme.
    run updateInorme.
    run createInorme.
end procedure.

procedure setInorme:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttInorme.
    ghttInorme = phttInorme.
    run crudInorme.
    delete object phttInorme.
end procedure.

procedure readInorme:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table inorme Table des normes
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNorme-cd as integer    no-undo.
    define input parameter table-handle phttInorme.
    define variable vhttBuffer as handle no-undo.
    define buffer inorme for inorme.

    vhttBuffer = phttInorme:default-buffer-handle.
    for first inorme no-lock
        where inorme.norme-cd = piNorme-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer inorme:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttInorme no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getInorme:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table inorme Table des normes
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttInorme.
    define variable vhttBuffer as handle  no-undo.
    define buffer inorme for inorme.

    vhttBuffer = phttInorme:default-buffer-handle.
    for each inorme no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer inorme:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttInorme no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateInorme private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNorme-cd    as handle  no-undo.
    define buffer inorme for inorme.

    create query vhttquery.
    vhttBuffer = ghttInorme:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttInorme:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNorme-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first inorme exclusive-lock
                where rowid(inorme) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer inorme:handle, 'norme-cd: ', substitute('&1', vhNorme-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer inorme:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createInorme private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer inorme for inorme.

    create query vhttquery.
    vhttBuffer = ghttInorme:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttInorme:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create inorme.
            if not outils:copyValidField(buffer inorme:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteInorme private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNorme-cd    as handle  no-undo.
    define buffer inorme for inorme.

    create query vhttquery.
    vhttBuffer = ghttInorme:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttInorme:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNorme-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first inorme exclusive-lock
                where rowid(Inorme) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer inorme:handle, 'norme-cd: ', substitute('&1', vhNorme-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete inorme no-error.
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

