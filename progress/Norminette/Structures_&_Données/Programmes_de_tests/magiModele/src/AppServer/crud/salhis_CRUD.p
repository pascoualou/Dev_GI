/*------------------------------------------------------------------------
File        : salhis_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table salhis
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/06/18 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}       // Doit être positionnée juste après using
define variable ghttsalhis as handle no-undo.     // le handle de la temp table à mettre à jour

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

procedure crudSalhis private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSalhis.
    run updateSalhis.
    run createSalhis.
end procedure.

procedure setSalhis:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSalhis.
    ghttSalhis = phttSalhis.
    run crudSalhis.
    delete object phttSalhis.
end procedure.

procedure readSalhis:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table salhis SalariÃ©s : historique rÃ©munÃ©rations 
0108/0109 - DIF
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character no-undo.
    define input parameter piNorol as int64     no-undo.
    define input parameter piMspai as integer   no-undo.
    define input parameter table-handle phttSalhis.

    define variable vhttBuffer as handle no-undo.
    define buffer salhis for salhis.

    vhttBuffer = phttSalhis:default-buffer-handle.
    for first salhis no-lock
        where salhis.tprol = pcTprol
          and salhis.norol = piNorol
          and salhis.mspai = piMspai:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer salhis:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSalhis no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSalhis:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table salhis SalariÃ©s : historique rÃ©munÃ©rations 
0108/0109 - DIF
    Notes  : service externe. Critère piNorol = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character no-undo.
    define input parameter piNorol as int64     no-undo.
    define input parameter table-handle phttSalhis.

    define variable vhttBuffer as handle  no-undo.
    define buffer salhis for salhis.

    vhttBuffer = phttSalhis:default-buffer-handle.
    if piNorol = ?
    then for each salhis no-lock
        where salhis.tprol = pcTprol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer salhis:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each salhis no-lock
        where salhis.tprol = pcTprol
          and salhis.norol = piNorol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer salhis:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSalhis no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSalhis private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhMspai    as handle  no-undo.
    define buffer salhis for salhis.

    create query vhttquery.
    vhttBuffer = ghttSalhis:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSalhis:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol, output vhMspai).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first salhis exclusive-lock
                where rowid(salhis) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer salhis:handle, 'tprol/norol/mspai: ', substitute('&1/&2/&3', vhTprol:buffer-value(), vhNorol:buffer-value(), vhMspai:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer salhis:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSalhis private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer salhis for salhis.

    create query vhttquery.
    vhttBuffer = ghttSalhis:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSalhis:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create salhis.
            if not outils:copyValidField(buffer salhis:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSalhis private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhMspai    as handle  no-undo.
    define buffer salhis for salhis.

    create query vhttquery.
    vhttBuffer = ghttSalhis:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSalhis:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol, output vhMspai).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first salhis exclusive-lock
                where rowid(Salhis) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer salhis:handle, 'tprol/norol/mspai: ', substitute('&1/&2/&3', vhTprol:buffer-value(), vhNorol:buffer-value(), vhMspai:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete salhis no-error.
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

procedure deleteSalhisSurRole:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeRole   as character no-undo.
    define input parameter piNumeroRole as int64     no-undo.

    define buffer salhis for salhis.

blocTrans:
    do transaction:
        for each salhis exclusive-lock
            where salhis.tprol = pcTypeRole
              and salhis.norol = piNumeroRole:
            delete salhis no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status
end procedure.
