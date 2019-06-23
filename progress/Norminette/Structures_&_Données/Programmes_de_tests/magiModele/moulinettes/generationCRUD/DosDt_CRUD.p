/*------------------------------------------------------------------------
File        : DosDt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table DosDt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/DosDt.i}
{application/include/error.i}
define variable ghttDosDt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoidt as handle, output phNoapp as handle, output phCdapp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NoIdt/NoApp/CdApp, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NoIdt' then phNoidt = phBuffer:buffer-field(vi).
            when 'NoApp' then phNoapp = phBuffer:buffer-field(vi).
            when 'CdApp' then phCdapp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudDosdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDosdt.
    run updateDosdt.
    run createDosdt.
end procedure.

procedure setDosdt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDosdt.
    ghttDosdt = phttDosdt.
    run crudDosdt.
    delete object phttDosdt.
end procedure.

procedure readDosdt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table DosDt Chaine Travaux : Detail appel de fond travaux
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoidt as integer    no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter pcCdapp as character  no-undo.
    define input parameter table-handle phttDosdt.
    define variable vhttBuffer as handle no-undo.
    define buffer DosDt for DosDt.

    vhttBuffer = phttDosdt:default-buffer-handle.
    for first DosDt no-lock
        where DosDt.NoIdt = piNoidt
          and DosDt.NoApp = piNoapp
          and DosDt.CdApp = pcCdapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DosDt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDosdt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDosdt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table DosDt Chaine Travaux : Detail appel de fond travaux
    Notes  : service externe. Critère piNoapp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoidt as integer    no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter table-handle phttDosdt.
    define variable vhttBuffer as handle  no-undo.
    define buffer DosDt for DosDt.

    vhttBuffer = phttDosdt:default-buffer-handle.
    if piNoapp = ?
    then for each DosDt no-lock
        where DosDt.NoIdt = piNoidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DosDt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each DosDt no-lock
        where DosDt.NoIdt = piNoidt
          and DosDt.NoApp = piNoapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DosDt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDosdt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDosdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoidt    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhCdapp    as handle  no-undo.
    define buffer DosDt for DosDt.

    create query vhttquery.
    vhttBuffer = ghttDosdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDosdt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoidt, output vhNoapp, output vhCdapp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DosDt exclusive-lock
                where rowid(DosDt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DosDt:handle, 'NoIdt/NoApp/CdApp: ', substitute('&1/&2/&3', vhNoidt:buffer-value(), vhNoapp:buffer-value(), vhCdapp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer DosDt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDosdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer DosDt for DosDt.

    create query vhttquery.
    vhttBuffer = ghttDosdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDosdt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create DosDt.
            if not outils:copyValidField(buffer DosDt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDosdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoidt    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhCdapp    as handle  no-undo.
    define buffer DosDt for DosDt.

    create query vhttquery.
    vhttBuffer = ghttDosdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDosdt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoidt, output vhNoapp, output vhCdapp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DosDt exclusive-lock
                where rowid(Dosdt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DosDt:handle, 'NoIdt/NoApp/CdApp: ', substitute('&1/&2/&3', vhNoidt:buffer-value(), vhNoapp:buffer-value(), vhCdapp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete DosDt no-error.
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

