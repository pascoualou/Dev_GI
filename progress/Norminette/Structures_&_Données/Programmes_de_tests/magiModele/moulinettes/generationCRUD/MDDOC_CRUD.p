/*------------------------------------------------------------------------
File        : MDDOC_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table MDDOC
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/MDDOC.i}
{application/include/error.i}
define variable ghttMDDOC as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNodot as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nodot, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nodot' then phNodot = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudMddoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteMddoc.
    run updateMddoc.
    run createMddoc.
end procedure.

procedure setMddoc:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttMddoc.
    ghttMddoc = phttMddoc.
    run crudMddoc.
    delete object phttMddoc.
end procedure.

procedure readMddoc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table MDDOC Modèle document
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNodot as integer    no-undo.
    define input parameter table-handle phttMddoc.
    define variable vhttBuffer as handle no-undo.
    define buffer MDDOC for MDDOC.

    vhttBuffer = phttMddoc:default-buffer-handle.
    for first MDDOC no-lock
        where MDDOC.nodot = piNodot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer MDDOC:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMddoc no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getMddoc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table MDDOC Modèle document
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttMddoc.
    define variable vhttBuffer as handle  no-undo.
    define buffer MDDOC for MDDOC.

    vhttBuffer = phttMddoc:default-buffer-handle.
    for each MDDOC no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer MDDOC:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMddoc no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateMddoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNodot    as handle  no-undo.
    define buffer MDDOC for MDDOC.

    create query vhttquery.
    vhttBuffer = ghttMddoc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttMddoc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNodot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first MDDOC exclusive-lock
                where rowid(MDDOC) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer MDDOC:handle, 'nodot: ', substitute('&1', vhNodot:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer MDDOC:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createMddoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer MDDOC for MDDOC.

    create query vhttquery.
    vhttBuffer = ghttMddoc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttMddoc:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create MDDOC.
            if not outils:copyValidField(buffer MDDOC:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteMddoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNodot    as handle  no-undo.
    define buffer MDDOC for MDDOC.

    create query vhttquery.
    vhttBuffer = ghttMddoc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttMddoc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNodot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first MDDOC exclusive-lock
                where rowid(Mddoc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer MDDOC:handle, 'nodot: ', substitute('&1', vhNodot:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete MDDOC no-error.
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

