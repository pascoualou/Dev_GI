/*------------------------------------------------------------------------
File        : DEMTRAIT_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table DEMTRAIT
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/DEMTRAIT.i}
{application/include/error.i}
define variable ghttDEMTRAIT as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdtrait as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur CDTRAIT, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'CDTRAIT' then phCdtrait = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudDemtrait private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDemtrait.
    run updateDemtrait.
    run createDemtrait.
end procedure.

procedure setDemtrait:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDemtrait.
    ghttDemtrait = phttDemtrait.
    run crudDemtrait.
    delete object phttDemtrait.
end procedure.

procedure readDemtrait:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table DEMTRAIT 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdtrait as character  no-undo.
    define input parameter table-handle phttDemtrait.
    define variable vhttBuffer as handle no-undo.
    define buffer DEMTRAIT for DEMTRAIT.

    vhttBuffer = phttDemtrait:default-buffer-handle.
    for first DEMTRAIT no-lock
        where DEMTRAIT.CDTRAIT = pcCdtrait:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DEMTRAIT:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDemtrait no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDemtrait:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table DEMTRAIT 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDemtrait.
    define variable vhttBuffer as handle  no-undo.
    define buffer DEMTRAIT for DEMTRAIT.

    vhttBuffer = phttDemtrait:default-buffer-handle.
    for each DEMTRAIT no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DEMTRAIT:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDemtrait no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDemtrait private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdtrait    as handle  no-undo.
    define buffer DEMTRAIT for DEMTRAIT.

    create query vhttquery.
    vhttBuffer = ghttDemtrait:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDemtrait:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdtrait).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DEMTRAIT exclusive-lock
                where rowid(DEMTRAIT) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DEMTRAIT:handle, 'CDTRAIT: ', substitute('&1', vhCdtrait:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer DEMTRAIT:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDemtrait private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer DEMTRAIT for DEMTRAIT.

    create query vhttquery.
    vhttBuffer = ghttDemtrait:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDemtrait:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create DEMTRAIT.
            if not outils:copyValidField(buffer DEMTRAIT:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDemtrait private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdtrait    as handle  no-undo.
    define buffer DEMTRAIT for DEMTRAIT.

    create query vhttquery.
    vhttBuffer = ghttDemtrait:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDemtrait:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdtrait).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DEMTRAIT exclusive-lock
                where rowid(Demtrait) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DEMTRAIT:handle, 'CDTRAIT: ', substitute('&1', vhCdtrait:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete DEMTRAIT no-error.
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

