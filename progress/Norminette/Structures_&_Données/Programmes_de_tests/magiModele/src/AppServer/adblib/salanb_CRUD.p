/*------------------------------------------------------------------------
File        : salanb_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table salanb
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttsalanb as handle no-undo.     // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTprol as handle, output phNorol as handle, output phMspai-deb as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tprol/norol/mspai-deb, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tprol' then phTprol = phBuffer:buffer-field(vi).
            when 'norol' then phNorol = phBuffer:buffer-field(vi).
            when 'mspai-deb' then phMspai-deb = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSalanb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSalanb.
    run updateSalanb.
    run createSalanb.
end procedure.

procedure setSalanb:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSalanb.
    ghttSalanb = phttSalanb.
    run crudSalanb.
    delete object phttSalanb.
end procedure.

procedure readSalanb:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table salanb 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol     as character  no-undo.
    define input parameter piNorol     as int64      no-undo.
    define input parameter piMspai-deb as integer    no-undo.
    define input parameter table-handle phttSalanb.
    define variable vhttBuffer as handle no-undo.
    define buffer salanb for salanb.

    vhttBuffer = phttSalanb:default-buffer-handle.
    for first salanb no-lock
        where salanb.tprol = pcTprol
          and salanb.norol = piNorol
          and salanb.mspai-deb = piMspai-deb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer salanb:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSalanb no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSalanb:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table salanb 
    Notes  : service externe. Critère piNorol = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol     as character  no-undo.
    define input parameter piNorol     as int64      no-undo.
    define input parameter table-handle phttSalanb.
    define variable vhttBuffer as handle  no-undo.
    define buffer salanb for salanb.

    vhttBuffer = phttSalanb:default-buffer-handle.
    if piNorol = ?
    then for each salanb no-lock
        where salanb.tprol = pcTprol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer salanb:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each salanb no-lock
        where salanb.tprol = pcTprol
          and salanb.norol = piNorol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer salanb:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSalanb no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSalanb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhMspai-deb    as handle  no-undo.
    define buffer salanb for salanb.

    create query vhttquery.
    vhttBuffer = ghttSalanb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSalanb:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol, output vhMspai-deb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first salanb exclusive-lock
                where rowid(salanb) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer salanb:handle, 'tprol/norol/mspai-deb: ', substitute('&1/&2/&3', vhTprol:buffer-value(), vhNorol:buffer-value(), vhMspai-deb:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer salanb:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSalanb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer salanb for salanb.

    create query vhttquery.
    vhttBuffer = ghttSalanb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSalanb:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create salanb.
            if not outils:copyValidField(buffer salanb:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSalanb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhMspai-deb    as handle  no-undo.
    define buffer salanb for salanb.

    create query vhttquery.
    vhttBuffer = ghttSalanb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSalanb:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol, output vhMspai-deb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first salanb exclusive-lock
                where rowid(Salanb) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer salanb:handle, 'tprol/norol/mspai-deb: ', substitute('&1/&2/&3', vhTprol:buffer-value(), vhNorol:buffer-value(), vhMspai-deb:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete salanb no-error.
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

procedure deleteSalanbSurRole:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeRole   as character no-undo.
    define input parameter piNumeroRole as int64     no-undo.
    
    define buffer salanb for salanb.

message "deleteSalanbSurRole " pcTypeRole "// " piNumeroRole.

blocTrans:
    do transaction:
        for each salanb exclusive-lock
           where salanb.tprol = pcTypeRole
             and salanb.norol = piNumeroRole:  
            delete salanb no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
