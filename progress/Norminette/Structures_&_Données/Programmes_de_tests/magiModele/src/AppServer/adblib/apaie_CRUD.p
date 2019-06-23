/*------------------------------------------------------------------------
File        : apaie_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table apaie
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttapaie as handle no-undo.     // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTprol as handle, output phNorol as handle, output phMspai as handle, output phModul as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tprol/norol/mspai/modul, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tprol' then phTprol = phBuffer:buffer-field(vi).
            when 'norol' then phNorol = phBuffer:buffer-field(vi).
            when 'mspai' then phMspai = phBuffer:buffer-field(vi).
            when 'modul' then phModul = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudApaie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteApaie.
    run updateApaie.
    run createApaie.
end procedure.

procedure setApaie:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttApaie.
    ghttApaie = phttApaie.
    run crudApaie.
    delete object phttApaie.
end procedure.

procedure readApaie:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table apaie 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character  no-undo.
    define input parameter piNorol as int64      no-undo.
    define input parameter piMspai as integer    no-undo.
    define input parameter pcModul as character  no-undo.
    define input parameter table-handle phttApaie.
    define variable vhttBuffer as handle no-undo.
    define buffer apaie for apaie.

    vhttBuffer = phttApaie:default-buffer-handle.
    for first apaie no-lock
        where apaie.tprol = pcTprol
          and apaie.norol = piNorol
          and apaie.mspai = piMspai
          and apaie.modul = pcModul:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer apaie:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttApaie no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getApaie:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table apaie 
    Notes  : service externe. Critère piMspai = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character  no-undo.
    define input parameter piNorol as int64      no-undo.
    define input parameter piMspai as integer    no-undo.
    define input parameter table-handle phttApaie.
    define variable vhttBuffer as handle  no-undo.
    define buffer apaie for apaie.

    vhttBuffer = phttApaie:default-buffer-handle.
    if piMspai = ?
    then for each apaie no-lock
        where apaie.tprol = pcTprol
          and apaie.norol = piNorol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer apaie:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each apaie no-lock
        where apaie.tprol = pcTprol
          and apaie.norol = piNorol
          and apaie.mspai = piMspai:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer apaie:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttApaie no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateApaie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhMspai    as handle  no-undo.
    define variable vhModul    as handle  no-undo.
    define buffer apaie for apaie.

    create query vhttquery.
    vhttBuffer = ghttApaie:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttApaie:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol, output vhMspai, output vhModul).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first apaie exclusive-lock
                where rowid(apaie) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer apaie:handle, 'tprol/norol/mspai/modul: ', substitute('&1/&2/&3/&4', vhTprol:buffer-value(), vhNorol:buffer-value(), vhMspai:buffer-value(), vhModul:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer apaie:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createApaie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer apaie for apaie.

    create query vhttquery.
    vhttBuffer = ghttApaie:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttApaie:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create apaie.
            if not outils:copyValidField(buffer apaie:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteApaie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhMspai    as handle  no-undo.
    define variable vhModul    as handle  no-undo.
    define buffer apaie for apaie.

    create query vhttquery.
    vhttBuffer = ghttApaie:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttApaie:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol, output vhMspai, output vhModul).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first apaie exclusive-lock
                where rowid(Apaie) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer apaie:handle, 'tprol/norol/mspai/modul: ', substitute('&1/&2/&3/&4', vhTprol:buffer-value(), vhNorol:buffer-value(), vhMspai:buffer-value(), vhModul:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete apaie no-error.
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

procedure deleteApaieSurRole:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeRole   as character no-undo.
    define input parameter piNumeroRole as int64     no-undo.
    
    define buffer apaie for apaie.

message "deleteApaieSurRole " pcTypeRole "// " piNumeroRole.

blocTrans:
    do transaction:
        for each apaie exclusive-lock
           where apaie.tprol = pcTypeRole
             and apaie.norol = piNumeroRole:  
            delete apaie no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

procedure deleteApaieSurPlageRole:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeRole     as character no-undo.
    define input parameter piDeNumeroRole as int64     no-undo.
    define input parameter piANumeroRole  as int64     no-undo.
    
    define buffer apaie for apaie.

message "deleteApaieSurPlageRole " pcTypeRole "// " piDeNumeroRole "// " piANumeroRole.

blocTrans:
    do transaction:
        for each apaie exclusive-lock
           where apaie.tprol = pcTypeRole
             and apaie.norol >= piDeNumeroRole  
             and apaie.norol <= piANumeroRole:                   
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
