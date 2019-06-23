/*------------------------------------------------------------------------
File        : Artic_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table Artic
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/Artic.i}
{application/include/error.i}
define variable ghttArtic as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdart as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur CdArt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'CdArt' then phCdart = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudArtic private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteArtic.
    run updateArtic.
    run createArtic.
end procedure.

procedure setArtic:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttArtic.
    ghttArtic = phttArtic.
    run crudArtic.
    delete object phttArtic.
end procedure.

procedure readArtic:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table Artic Chaine Travaux : Table des Articles
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdart as character  no-undo.
    define input parameter table-handle phttArtic.
    define variable vhttBuffer as handle no-undo.
    define buffer Artic for Artic.

    vhttBuffer = phttArtic:default-buffer-handle.
    for first Artic no-lock
        where Artic.CdArt = pcCdart:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Artic:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttArtic no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getArtic:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table Artic Chaine Travaux : Table des Articles
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttArtic.
    define variable vhttBuffer as handle  no-undo.
    define buffer Artic for Artic.

    vhttBuffer = phttArtic:default-buffer-handle.
    for each Artic no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Artic:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttArtic no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateArtic private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdart    as handle  no-undo.
    define buffer Artic for Artic.

    create query vhttquery.
    vhttBuffer = ghttArtic:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttArtic:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdart).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first Artic exclusive-lock
                where rowid(Artic) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer Artic:handle, 'CdArt: ', substitute('&1', vhCdart:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer Artic:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createArtic private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer Artic for Artic.

    create query vhttquery.
    vhttBuffer = ghttArtic:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttArtic:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create Artic.
            if not outils:copyValidField(buffer Artic:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteArtic private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdart    as handle  no-undo.
    define buffer Artic for Artic.

    create query vhttquery.
    vhttBuffer = ghttArtic:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttArtic:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdart).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first Artic exclusive-lock
                where rowid(Artic) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer Artic:handle, 'CdArt: ', substitute('&1', vhCdart:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete Artic no-error.
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

