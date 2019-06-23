/*------------------------------------------------------------------------
File        : iprinter_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iprinter
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iprinter.i}
{application/include/error.i}
define variable ghttiprinter as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNom as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nom, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nom' then phNom = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIprinter private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIprinter.
    run updateIprinter.
    run createIprinter.
end procedure.

procedure setIprinter:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIprinter.
    ghttIprinter = phttIprinter.
    run crudIprinter.
    delete object phttIprinter.
end procedure.

procedure readIprinter:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iprinter Liste des differentes imprimantes installees
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcNom as character  no-undo.
    define input parameter table-handle phttIprinter.
    define variable vhttBuffer as handle no-undo.
    define buffer iprinter for iprinter.

    vhttBuffer = phttIprinter:default-buffer-handle.
    for first iprinter no-lock
        where iprinter.nom = pcNom:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iprinter:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIprinter no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIprinter:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iprinter Liste des differentes imprimantes installees
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIprinter.
    define variable vhttBuffer as handle  no-undo.
    define buffer iprinter for iprinter.

    vhttBuffer = phttIprinter:default-buffer-handle.
    for each iprinter no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iprinter:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIprinter no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIprinter private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNom    as handle  no-undo.
    define buffer iprinter for iprinter.

    create query vhttquery.
    vhttBuffer = ghttIprinter:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIprinter:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNom).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iprinter exclusive-lock
                where rowid(iprinter) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iprinter:handle, 'nom: ', substitute('&1', vhNom:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iprinter:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIprinter private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iprinter for iprinter.

    create query vhttquery.
    vhttBuffer = ghttIprinter:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIprinter:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iprinter.
            if not outils:copyValidField(buffer iprinter:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIprinter private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNom    as handle  no-undo.
    define buffer iprinter for iprinter.

    create query vhttquery.
    vhttBuffer = ghttIprinter:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIprinter:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNom).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iprinter exclusive-lock
                where rowid(Iprinter) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iprinter:handle, 'nom: ', substitute('&1', vhNom:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iprinter no-error.
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

