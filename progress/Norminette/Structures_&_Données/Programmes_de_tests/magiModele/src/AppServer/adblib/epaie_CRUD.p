/*------------------------------------------------------------------------
File        : epaie_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table epaie
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttepaie as handle no-undo.     // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTprol as handle, output phNorol as handle, output phCdrub as handle, output phDtdeb as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tprol/norol/cdrub/dtdeb, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tprol' then phTprol = phBuffer:buffer-field(vi).
            when 'norol' then phNorol = phBuffer:buffer-field(vi).
            when 'cdrub' then phCdrub = phBuffer:buffer-field(vi).
            when 'dtdeb' then phDtdeb = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEpaie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEpaie.
    run updateEpaie.
    run createEpaie.
end procedure.

procedure setEpaie:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEpaie.
    ghttEpaie = phttEpaie.
    run crudEpaie.
    delete object phttEpaie.
end procedure.

procedure readEpaie:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table epaie Paie des salariÃ©s
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character  no-undo.
    define input parameter piNorol as int64      no-undo.
    define input parameter piCdrub as integer    no-undo.
    define input parameter pdaDtdeb as date       no-undo.
    define input parameter table-handle phttEpaie.
    define variable vhttBuffer as handle no-undo.
    define buffer epaie for epaie.

    vhttBuffer = phttEpaie:default-buffer-handle.
    for first epaie no-lock
        where epaie.tprol = pcTprol
          and epaie.norol = piNorol
          and epaie.cdrub = piCdrub
          and epaie.dtdeb = pdaDtdeb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer epaie:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEpaie no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEpaie:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table epaie Paie des salariÃ©s
    Notes  : service externe. Critère piCdrub = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character  no-undo.
    define input parameter piNorol as int64      no-undo.
    define input parameter piCdrub as integer    no-undo.
    define input parameter table-handle phttEpaie.
    define variable vhttBuffer as handle  no-undo.
    define buffer epaie for epaie.

    vhttBuffer = phttEpaie:default-buffer-handle.
    if piCdrub = ?
    then for each epaie no-lock
        where epaie.tprol = pcTprol
          and epaie.norol = piNorol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer epaie:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each epaie no-lock
        where epaie.tprol = pcTprol
          and epaie.norol = piNorol
          and epaie.cdrub = piCdrub:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer epaie:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEpaie no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEpaie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhCdrub    as handle  no-undo.
    define variable vhDtdeb    as handle  no-undo.
    define buffer epaie for epaie.

    create query vhttquery.
    vhttBuffer = ghttEpaie:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEpaie:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol, output vhCdrub, output vhDtdeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first epaie exclusive-lock
                where rowid(epaie) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer epaie:handle, 'tprol/norol/cdrub/dtdeb: ', substitute('&1/&2/&3/&4', vhTprol:buffer-value(), vhNorol:buffer-value(), vhCdrub:buffer-value(), vhDtdeb:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer epaie:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEpaie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer epaie for epaie.

    create query vhttquery.
    vhttBuffer = ghttEpaie:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEpaie:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create epaie.
            if not outils:copyValidField(buffer epaie:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEpaie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhCdrub    as handle  no-undo.
    define variable vhDtdeb    as handle  no-undo.
    define buffer epaie for epaie.

    create query vhttquery.
    vhttBuffer = ghttEpaie:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEpaie:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol, output vhCdrub, output vhDtdeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first epaie exclusive-lock
                where rowid(Epaie) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer epaie:handle, 'tprol/norol/cdrub/dtdeb: ', substitute('&1/&2/&3/&4', vhTprol:buffer-value(), vhNorol:buffer-value(), vhCdrub:buffer-value(), vhDtdeb:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete epaie no-error.
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

procedure deleteEpaieSurRole:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeRole   as character no-undo.
    define input parameter piNumeroRole as int64     no-undo.
    
    define buffer epaie for epaie.

message "deleteEpaieSurRole " pcTypeRole "// " piNumeroRole.

blocTrans:
    do transaction:
        for each epaie exclusive-lock
           where epaie.tprol = pcTypeRole
             and epaie.norol = piNumeroRole:  
            delete epaie no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
