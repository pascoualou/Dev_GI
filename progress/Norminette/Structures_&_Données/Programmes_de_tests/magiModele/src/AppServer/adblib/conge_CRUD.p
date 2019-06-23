/*------------------------------------------------------------------------
File        : conge_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table conge
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttconge as handle no-undo.     // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTprol as handle, output phNorol as handle, output phMspai as handle, output phCdori as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tprol/norol/mspai/cdori, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tprol' then phTprol = phBuffer:buffer-field(vi).
            when 'norol' then phNorol = phBuffer:buffer-field(vi).
            when 'mspai' then phMspai = phBuffer:buffer-field(vi).
            when 'cdori' then phCdori = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudConge private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteConge.
    run updateConge.
    run createConge.
end procedure.

procedure setConge:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttConge.
    ghttConge = phttConge.
    run crudConge.
    delete object phttConge.
end procedure.

procedure readConge:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table conge Suivi des congÃ©s payÃ©s
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character  no-undo.
    define input parameter piNorol as int64      no-undo.
    define input parameter piMspai as integer    no-undo.
    define input parameter pcCdori as character  no-undo.
    define input parameter table-handle phttConge.
    define variable vhttBuffer as handle no-undo.
    define buffer conge for conge.

    vhttBuffer = phttConge:default-buffer-handle.
    for first conge no-lock
        where conge.tprol = pcTprol
          and conge.norol = piNorol
          and conge.mspai = piMspai
          and conge.cdori = pcCdori:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer conge:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttConge no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getConge:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table conge Suivi des congÃ©s payÃ©s
    Notes  : service externe. Critère piMspai = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character  no-undo.
    define input parameter piNorol as int64      no-undo.
    define input parameter piMspai as integer    no-undo.
    define input parameter table-handle phttConge.
    define variable vhttBuffer as handle  no-undo.
    define buffer conge for conge.

    vhttBuffer = phttConge:default-buffer-handle.
    if piMspai = ?
    then for each conge no-lock
        where conge.tprol = pcTprol
          and conge.norol = piNorol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer conge:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each conge no-lock
        where conge.tprol = pcTprol
          and conge.norol = piNorol
          and conge.mspai = piMspai:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer conge:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttConge no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateConge private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhMspai    as handle  no-undo.
    define variable vhCdori    as handle  no-undo.
    define buffer conge for conge.

    create query vhttquery.
    vhttBuffer = ghttConge:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttConge:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol, output vhMspai, output vhCdori).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first conge exclusive-lock
                where rowid(conge) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer conge:handle, 'tprol/norol/mspai/cdori: ', substitute('&1/&2/&3/&4', vhTprol:buffer-value(), vhNorol:buffer-value(), vhMspai:buffer-value(), vhCdori:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer conge:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createConge private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer conge for conge.

    create query vhttquery.
    vhttBuffer = ghttConge:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttConge:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create conge.
            if not outils:copyValidField(buffer conge:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteConge private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhMspai    as handle  no-undo.
    define variable vhCdori    as handle  no-undo.
    define buffer conge for conge.

    create query vhttquery.
    vhttBuffer = ghttConge:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttConge:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol, output vhMspai, output vhCdori).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first conge exclusive-lock
                where rowid(Conge) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer conge:handle, 'tprol/norol/mspai/cdori: ', substitute('&1/&2/&3/&4', vhTprol:buffer-value(), vhNorol:buffer-value(), vhMspai:buffer-value(), vhCdori:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete conge no-error.
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

procedure deleteCongeSurRole:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeRole   as character no-undo.
    define input parameter piNumeroRole as int64     no-undo.
    
    define buffer conge for conge.

message "deleteCongeSurRole " pcTypeRole "// " piNumeroRole.

blocTrans:
    do transaction:
        for each conge exclusive-lock
           where conge.tprol = pcTypeRole
             and conge.norol = piNumeroRole:  
            delete conge no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

procedure deleteCongeSurPlageRole:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeRole     as character no-undo.
    define input parameter piDeNumeroRole as int64     no-undo.
    define input parameter piANumeroRole  as int64     no-undo.
    
    define buffer conge for conge.

message "deleteCongeSurPlageRole " pcTypeRole "// " piDeNumeroRole "// " piANumeroRole.

blocTrans:
    do transaction:
        for each conge exclusive-lock
           where conge.tprol = pcTypeRole
             and conge.norol >= piDeNumeroRole
             and conge.norol <= piANumeroRole:  
            delete conge no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
