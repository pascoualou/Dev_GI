/*------------------------------------------------------------------------
File        : daquit_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table daquit
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/daquit.i}
{application/include/error.i}
define variable ghttdaquit as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTprol as handle, output phNoloc as handle, output phNorefqtt as handle, output phNoqtt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tprol/noloc/norefqtt/noqtt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tprol' then phTprol = phBuffer:buffer-field(vi).
            when 'noloc' then phNoloc = phBuffer:buffer-field(vi).
            when 'norefqtt' then phNorefqtt = phBuffer:buffer-field(vi).
            when 'noqtt' then phNoqtt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudDaquit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDaquit.
    run updateDaquit.
    run createDaquit.
end procedure.

procedure setDaquit:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDaquit.
    ghttDaquit = phttDaquit.
    run crudDaquit.
    delete object phttDaquit.
end procedure.

procedure readDaquit:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table daquit Détail historique de facture entrée
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol    as character  no-undo.
    define input parameter piNoloc    as int64      no-undo.
    define input parameter piNorefqtt as integer    no-undo.
    define input parameter piNoqtt    as integer    no-undo.
    define input parameter table-handle phttDaquit.
    define variable vhttBuffer as handle no-undo.
    define buffer daquit for daquit.

    vhttBuffer = phttDaquit:default-buffer-handle.
    for first daquit no-lock
        where daquit.tprol = pcTprol
          and daquit.noloc = piNoloc
          and daquit.norefqtt = piNorefqtt
          and daquit.noqtt = piNoqtt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer daquit:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDaquit no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDaquit:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table daquit Détail historique de facture entrée
    Notes  : service externe. Critère piNorefqtt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol    as character  no-undo.
    define input parameter piNoloc    as int64      no-undo.
    define input parameter piNorefqtt as integer    no-undo.
    define input parameter table-handle phttDaquit.
    define variable vhttBuffer as handle  no-undo.
    define buffer daquit for daquit.

    vhttBuffer = phttDaquit:default-buffer-handle.
    if piNorefqtt = ?
    then for each daquit no-lock
        where daquit.tprol = pcTprol
          and daquit.noloc = piNoloc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer daquit:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each daquit no-lock
        where daquit.tprol = pcTprol
          and daquit.noloc = piNoloc
          and daquit.norefqtt = piNorefqtt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer daquit:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDaquit no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDaquit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define variable vhNorefqtt    as handle  no-undo.
    define variable vhNoqtt    as handle  no-undo.
    define buffer daquit for daquit.

    create query vhttquery.
    vhttBuffer = ghttDaquit:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDaquit:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNoloc, output vhNorefqtt, output vhNoqtt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first daquit exclusive-lock
                where rowid(daquit) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer daquit:handle, 'tprol/noloc/norefqtt/noqtt: ', substitute('&1/&2/&3/&4', vhTprol:buffer-value(), vhNoloc:buffer-value(), vhNorefqtt:buffer-value(), vhNoqtt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer daquit:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDaquit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer daquit for daquit.

    create query vhttquery.
    vhttBuffer = ghttDaquit:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDaquit:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create daquit.
            if not outils:copyValidField(buffer daquit:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDaquit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define variable vhNorefqtt    as handle  no-undo.
    define variable vhNoqtt    as handle  no-undo.
    define buffer daquit for daquit.

    create query vhttquery.
    vhttBuffer = ghttDaquit:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDaquit:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNoloc, output vhNorefqtt, output vhNoqtt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first daquit exclusive-lock
                where rowid(Daquit) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer daquit:handle, 'tprol/noloc/norefqtt/noqtt: ', substitute('&1/&2/&3/&4', vhTprol:buffer-value(), vhNoloc:buffer-value(), vhNorefqtt:buffer-value(), vhNoqtt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete daquit no-error.
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

