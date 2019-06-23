/*------------------------------------------------------------------------
File        : CRITERES_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table CRITERES
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/CRITERES.i}
{application/include/error.i}
define variable ghttCRITERES as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudCriteres private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCriteres.
    run updateCriteres.
    run createCriteres.
end procedure.

procedure setCriteres:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCriteres.
    ghttCriteres = phttCriteres.
    run crudCriteres.
    delete object phttCriteres.
end procedure.

procedure readCriteres:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table CRITERES Criteres de selection des lots
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCriteres.
    define variable vhttBuffer as handle no-undo.
    define buffer CRITERES for CRITERES.

    vhttBuffer = phttCriteres:default-buffer-handle.
    for first CRITERES no-lock
        where :
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer CRITERES:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCriteres no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCriteres:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table CRITERES Criteres de selection des lots
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCriteres.
    define variable vhttBuffer as handle  no-undo.
    define buffer CRITERES for CRITERES.

    vhttBuffer = phttCriteres:default-buffer-handle.
    for each CRITERES no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer CRITERES:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCriteres no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCriteres private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer CRITERES for CRITERES.

    create query vhttquery.
    vhttBuffer = ghttCriteres:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCriteres:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first CRITERES exclusive-lock
                where rowid(CRITERES) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer CRITERES:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer CRITERES:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCriteres private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer CRITERES for CRITERES.

    create query vhttquery.
    vhttBuffer = ghttCriteres:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCriteres:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create CRITERES.
            if not outils:copyValidField(buffer CRITERES:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCriteres private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer CRITERES for CRITERES.

    create query vhttquery.
    vhttBuffer = ghttCriteres:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCriteres:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first CRITERES exclusive-lock
                where rowid(Criteres) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer CRITERES:handle, ': ', substitute(''), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete CRITERES no-error.
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

