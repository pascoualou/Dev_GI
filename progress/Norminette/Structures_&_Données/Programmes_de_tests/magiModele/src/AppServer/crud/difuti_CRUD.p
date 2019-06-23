/*------------------------------------------------------------------------
File        : difuti_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table difuti
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/06/18 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttdifuti as handle no-undo.     // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phTprol as handle, output phNorol as handle, output phMspai as handle, output phNoord as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tprol/norol/mspai/noord, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tprol' then phTprol = phBuffer:buffer-field(vi).
            when 'norol' then phNorol = phBuffer:buffer-field(vi).
            when 'mspai' then phMspai = phBuffer:buffer-field(vi).
            when 'noord' then phNoord = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudDifuti private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDifuti.
    run updateDifuti.
    run createDifuti.
end procedure.

procedure setDifuti:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDifuti.
    ghttDifuti = phttDifuti.
    run crudDifuti.
    delete object phttDifuti.
end procedure.

procedure readDifuti:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table difuti SalariÃ©s : DIF - heures utilisees
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character no-undo.
    define input parameter piNorol as int64     no-undo.
    define input parameter piMspai as integer   no-undo.
    define input parameter piNoord as integer   no-undo.
    define input parameter table-handle phttDifuti.

    define variable vhttBuffer as handle no-undo.
    define buffer difuti for difuti.

    vhttBuffer = phttDifuti:default-buffer-handle.
    for first difuti no-lock
        where difuti.tprol = pcTprol
          and difuti.norol = piNorol
          and difuti.mspai = piMspai
          and difuti.noord = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer difuti:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDifuti no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDifuti:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table difuti SalariÃ©s : DIF - heures utilisees
    Notes  : service externe. Critère piMspai = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character no-undo.
    define input parameter piNorol as int64     no-undo.
    define input parameter piMspai as integer   no-undo.
    define input parameter table-handle phttDifuti.

    define variable vhttBuffer as handle  no-undo.
    define buffer difuti for difuti.

    vhttBuffer = phttDifuti:default-buffer-handle.
    if piMspai = ?
    then for each difuti no-lock
        where difuti.tprol = pcTprol
          and difuti.norol = piNorol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer difuti:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each difuti no-lock
        where difuti.tprol = pcTprol
          and difuti.norol = piNorol
          and difuti.mspai = piMspai:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer difuti:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDifuti no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDifuti private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhMspai    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer difuti for difuti.

    create query vhttquery.
    vhttBuffer = ghttDifuti:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDifuti:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol, output vhMspai, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first difuti exclusive-lock
                where rowid(difuti) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer difuti:handle, 'tprol/norol/mspai/noord: ', substitute('&1/&2/&3/&4', vhTprol:buffer-value(), vhNorol:buffer-value(), vhMspai:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer difuti:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDifuti private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer difuti for difuti.

    create query vhttquery.
    vhttBuffer = ghttDifuti:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDifuti:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create difuti.
            if not outils:copyValidField(buffer difuti:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDifuti private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhMspai    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer difuti for difuti.

    create query vhttquery.
    vhttBuffer = ghttDifuti:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDifuti:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol, output vhMspai, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first difuti exclusive-lock
                where rowid(Difuti) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer difuti:handle, 'tprol/norol/mspai/noord: ', substitute('&1/&2/&3/&4', vhTprol:buffer-value(), vhNorol:buffer-value(), vhMspai:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete difuti no-error.
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

procedure deleteDifutiSurRole:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeRole   as character no-undo.
    define input parameter piNumeroRole as int64     no-undo.
    
    define buffer difuti for difuti.

blocTrans:
    do transaction:
        for each difuti exclusive-lock
            where difuti.tprol = pcTypeRole
              and difuti.norol = piNumeroRole:  
            delete difuti no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
