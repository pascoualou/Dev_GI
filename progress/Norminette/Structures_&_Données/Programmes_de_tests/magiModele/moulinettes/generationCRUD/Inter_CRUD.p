/*------------------------------------------------------------------------
File        : Inter_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table Inter
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/Inter.i}
{application/include/error.i}
define variable ghttInter as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoint as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NoInt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NoInt' then phNoint = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudInter private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteInter.
    run updateInter.
    run createInter.
end procedure.

procedure setInter:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttInter.
    ghttInter = phttInter.
    run crudInter.
    delete object phttInter.
end procedure.

procedure readInter:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table Inter Chaine Travaux : Tables des Interventions
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoint as int64      no-undo.
    define input parameter table-handle phttInter.
    define variable vhttBuffer as handle no-undo.
    define buffer Inter for Inter.

    vhttBuffer = phttInter:default-buffer-handle.
    for first Inter no-lock
        where Inter.NoInt = piNoint:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Inter:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttInter no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getInter:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table Inter Chaine Travaux : Tables des Interventions
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttInter.
    define variable vhttBuffer as handle  no-undo.
    define buffer Inter for Inter.

    vhttBuffer = phttInter:default-buffer-handle.
    for each Inter no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Inter:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttInter no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateInter private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoint    as handle  no-undo.
    define buffer Inter for Inter.

    create query vhttquery.
    vhttBuffer = ghttInter:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttInter:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoint).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first Inter exclusive-lock
                where rowid(Inter) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer Inter:handle, 'NoInt: ', substitute('&1', vhNoint:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer Inter:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createInter private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer Inter for Inter.

    create query vhttquery.
    vhttBuffer = ghttInter:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttInter:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create Inter.
            if not outils:copyValidField(buffer Inter:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteInter private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoint    as handle  no-undo.
    define buffer Inter for Inter.

    create query vhttquery.
    vhttBuffer = ghttInter:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttInter:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoint).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first Inter exclusive-lock
                where rowid(Inter) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer Inter:handle, 'NoInt: ', substitute('&1', vhNoint:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete Inter no-error.
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

