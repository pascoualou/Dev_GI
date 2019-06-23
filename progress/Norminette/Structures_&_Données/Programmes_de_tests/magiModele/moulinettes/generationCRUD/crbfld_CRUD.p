/*------------------------------------------------------------------------
File        : crbfld_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table crbfld
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/crbfld.i}
{application/include/error.i}
define variable ghttcrbfld as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phChamps-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur champs-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'champs-cle' then phChamps-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCrbfld private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCrbfld.
    run updateCrbfld.
    run createCrbfld.
end procedure.

procedure setCrbfld:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCrbfld.
    ghttCrbfld = phttCrbfld.
    run crudCrbfld.
    delete object phttCrbfld.
end procedure.

procedure readCrbfld:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table crbfld 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcChamps-cle as character  no-undo.
    define input parameter table-handle phttCrbfld.
    define variable vhttBuffer as handle no-undo.
    define buffer crbfld for crbfld.

    vhttBuffer = phttCrbfld:default-buffer-handle.
    for first crbfld no-lock
        where crbfld.champs-cle = pcChamps-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crbfld:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCrbfld no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCrbfld:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table crbfld 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCrbfld.
    define variable vhttBuffer as handle  no-undo.
    define buffer crbfld for crbfld.

    vhttBuffer = phttCrbfld:default-buffer-handle.
    for each crbfld no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crbfld:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCrbfld no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCrbfld private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhChamps-cle    as handle  no-undo.
    define buffer crbfld for crbfld.

    create query vhttquery.
    vhttBuffer = ghttCrbfld:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCrbfld:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhChamps-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first crbfld exclusive-lock
                where rowid(crbfld) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer crbfld:handle, 'champs-cle: ', substitute('&1', vhChamps-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer crbfld:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCrbfld private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer crbfld for crbfld.

    create query vhttquery.
    vhttBuffer = ghttCrbfld:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCrbfld:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create crbfld.
            if not outils:copyValidField(buffer crbfld:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCrbfld private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhChamps-cle    as handle  no-undo.
    define buffer crbfld for crbfld.

    create query vhttquery.
    vhttBuffer = ghttCrbfld:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCrbfld:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhChamps-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first crbfld exclusive-lock
                where rowid(Crbfld) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer crbfld:handle, 'champs-cle: ', substitute('&1', vhChamps-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete crbfld no-error.
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

