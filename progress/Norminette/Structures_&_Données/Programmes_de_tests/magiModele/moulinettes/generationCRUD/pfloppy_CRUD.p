/*------------------------------------------------------------------------
File        : pfloppy_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table pfloppy
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/pfloppy.i}
{application/include/error.i}
define variable ghttpfloppy as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phFloppy-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur floppy-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'floppy-cle' then phFloppy-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPfloppy private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePfloppy.
    run updatePfloppy.
    run createPfloppy.
end procedure.

procedure setPfloppy:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPfloppy.
    ghttPfloppy = phttPfloppy.
    run crudPfloppy.
    delete object phttPfloppy.
end procedure.

procedure readPfloppy:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table pfloppy Fichier Floppy Disquette
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcFloppy-cle as character  no-undo.
    define input parameter table-handle phttPfloppy.
    define variable vhttBuffer as handle no-undo.
    define buffer pfloppy for pfloppy.

    vhttBuffer = phttPfloppy:default-buffer-handle.
    for first pfloppy no-lock
        where pfloppy.floppy-cle = pcFloppy-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pfloppy:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPfloppy no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPfloppy:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table pfloppy Fichier Floppy Disquette
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPfloppy.
    define variable vhttBuffer as handle  no-undo.
    define buffer pfloppy for pfloppy.

    vhttBuffer = phttPfloppy:default-buffer-handle.
    for each pfloppy no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pfloppy:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPfloppy no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePfloppy private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhFloppy-cle    as handle  no-undo.
    define buffer pfloppy for pfloppy.

    create query vhttquery.
    vhttBuffer = ghttPfloppy:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPfloppy:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhFloppy-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pfloppy exclusive-lock
                where rowid(pfloppy) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pfloppy:handle, 'floppy-cle: ', substitute('&1', vhFloppy-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer pfloppy:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPfloppy private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer pfloppy for pfloppy.

    create query vhttquery.
    vhttBuffer = ghttPfloppy:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPfloppy:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create pfloppy.
            if not outils:copyValidField(buffer pfloppy:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePfloppy private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhFloppy-cle    as handle  no-undo.
    define buffer pfloppy for pfloppy.

    create query vhttquery.
    vhttBuffer = ghttPfloppy:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPfloppy:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhFloppy-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pfloppy exclusive-lock
                where rowid(Pfloppy) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pfloppy:handle, 'floppy-cle: ', substitute('&1', vhFloppy-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete pfloppy no-error.
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

