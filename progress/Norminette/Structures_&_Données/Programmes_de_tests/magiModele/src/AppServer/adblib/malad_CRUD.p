/*------------------------------------------------------------------------
File        : malad_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table malad
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttmalad as handle no-undo.     // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTprol as handle, output phNorol as handle, output phMspai as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tprol/norol/mspai, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tprol' then phTprol = phBuffer:buffer-field(vi).
            when 'norol' then phNorol = phBuffer:buffer-field(vi).
            when 'mspai' then phMspai = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudMalad private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteMalad.
    run updateMalad.
    run createMalad.
end procedure.

procedure setMalad:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttMalad.
    ghttMalad = phttMalad.
    run crudMalad.
    delete object phttMalad.
end procedure.

procedure readMalad:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table malad Suivi des absences maladie des salariÃ©s
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character  no-undo.
    define input parameter piNorol as int64      no-undo.
    define input parameter piMspai as integer    no-undo.
    define input parameter table-handle phttMalad.
    define variable vhttBuffer as handle no-undo.
    define buffer malad for malad.

    vhttBuffer = phttMalad:default-buffer-handle.
    for first malad no-lock
        where malad.tprol = pcTprol
          and malad.norol = piNorol
          and malad.mspai = piMspai:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer malad:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMalad no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getMalad:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table malad Suivi des absences maladie des salariÃ©s
    Notes  : service externe. Critère piNorol = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character  no-undo.
    define input parameter piNorol as int64      no-undo.
    define input parameter table-handle phttMalad.
    define variable vhttBuffer as handle  no-undo.
    define buffer malad for malad.

    vhttBuffer = phttMalad:default-buffer-handle.
    if piNorol = ?
    then for each malad no-lock
        where malad.tprol = pcTprol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer malad:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each malad no-lock
        where malad.tprol = pcTprol
          and malad.norol = piNorol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer malad:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMalad no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateMalad private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhMspai    as handle  no-undo.
    define buffer malad for malad.

    create query vhttquery.
    vhttBuffer = ghttMalad:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttMalad:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol, output vhMspai).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first malad exclusive-lock
                where rowid(malad) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer malad:handle, 'tprol/norol/mspai: ', substitute('&1/&2/&3', vhTprol:buffer-value(), vhNorol:buffer-value(), vhMspai:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer malad:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createMalad private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer malad for malad.

    create query vhttquery.
    vhttBuffer = ghttMalad:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttMalad:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create malad.
            if not outils:copyValidField(buffer malad:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteMalad private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhMspai    as handle  no-undo.
    define buffer malad for malad.

    create query vhttquery.
    vhttBuffer = ghttMalad:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttMalad:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol, output vhMspai).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first malad exclusive-lock
                where rowid(Malad) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer malad:handle, 'tprol/norol/mspai: ', substitute('&1/&2/&3', vhTprol:buffer-value(), vhNorol:buffer-value(), vhMspai:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete malad no-error.
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

procedure deleteMaladSurRole:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroRole as int64 no-undo.
    
    define buffer malad for malad.

message "deleteMaladSurRole " piNumeroRole.

blocTrans:
    do transaction:
        for each malad no-lock
           where malad.norol = piNumeroRole: 
            find current malad exclusive-lock.
            delete malad no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

procedure deleteMaladSurPlageRole:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeRole     as character no-undo.
    define input parameter piDeNumeroRole as int64     no-undo.
    define input parameter piANumeroRole  as int64     no-undo.
    
    define buffer malad for malad.

message "deleteMaladSurPlageRole " pcTypeRole "// " piDeNumeroRole "// " piANumeroRole.

blocTrans:
    do transaction:
        for each malad exclusive-lock
           where malad.tprol = pcTypeRole
             and malad.norol >= piDeNumeroRole
             and malad.norol <= piANumeroRole:  
            delete malad no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
