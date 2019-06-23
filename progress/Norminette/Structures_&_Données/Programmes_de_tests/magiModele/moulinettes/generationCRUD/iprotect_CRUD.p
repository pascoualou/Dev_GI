/*------------------------------------------------------------------------
File        : iprotect_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iprotect
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iprotect.i}
{application/include/error.i}
define variable ghttiprotect as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phFic-nom as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur fic-nom, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'fic-nom' then phFic-nom = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIprotect private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIprotect.
    run updateIprotect.
    run createIprotect.
end procedure.

procedure setIprotect:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIprotect.
    ghttIprotect = phttIprotect.
    run crudIprotect.
    delete object phttIprotect.
end procedure.

procedure readIprotect:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iprotect Fichier protection acces en Insertion, Modification, Effacement pour l'ensemble des modules selon l'utilisateur.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcFic-nom as character  no-undo.
    define input parameter table-handle phttIprotect.
    define variable vhttBuffer as handle no-undo.
    define buffer iprotect for iprotect.

    vhttBuffer = phttIprotect:default-buffer-handle.
    for first iprotect no-lock
        where iprotect.fic-nom = pcFic-nom:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iprotect:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIprotect no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIprotect:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iprotect Fichier protection acces en Insertion, Modification, Effacement pour l'ensemble des modules selon l'utilisateur.
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIprotect.
    define variable vhttBuffer as handle  no-undo.
    define buffer iprotect for iprotect.

    vhttBuffer = phttIprotect:default-buffer-handle.
    for each iprotect no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iprotect:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIprotect no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIprotect private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhFic-nom    as handle  no-undo.
    define buffer iprotect for iprotect.

    create query vhttquery.
    vhttBuffer = ghttIprotect:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIprotect:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhFic-nom).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iprotect exclusive-lock
                where rowid(iprotect) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iprotect:handle, 'fic-nom: ', substitute('&1', vhFic-nom:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iprotect:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIprotect private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iprotect for iprotect.

    create query vhttquery.
    vhttBuffer = ghttIprotect:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIprotect:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iprotect.
            if not outils:copyValidField(buffer iprotect:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIprotect private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhFic-nom    as handle  no-undo.
    define buffer iprotect for iprotect.

    create query vhttquery.
    vhttBuffer = ghttIprotect:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIprotect:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhFic-nom).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iprotect exclusive-lock
                where rowid(Iprotect) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iprotect:handle, 'fic-nom: ', substitute('&1', vhFic-nom:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iprotect no-error.
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

