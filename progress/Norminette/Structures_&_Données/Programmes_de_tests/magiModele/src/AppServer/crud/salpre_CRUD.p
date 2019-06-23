/*------------------------------------------------------------------------
File        : salpre_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table salpre
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/06/18 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttsalpre as handle no-undo.     // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phTprol as handle, output phNorol as handle, output phMspai as handle, output phDtdeb as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tprol/norol/mspai/dtdeb, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tprol' then phTprol = phBuffer:buffer-field(vi).
            when 'norol' then phNorol = phBuffer:buffer-field(vi).
            when 'mspai' then phMspai = phBuffer:buffer-field(vi).
            when 'dtdeb' then phDtdeb = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSalpre private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSalpre.
    run updateSalpre.
    run createSalpre.
end procedure.

procedure setSalpre:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSalpre.
    ghttSalpre = phttSalpre.
    run crudSalpre.
    delete object phttSalpre.
end procedure.

procedure readSalpre:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table salpre SalariÃ©s : PÃ©riodes de prÃ©sence 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol  as character no-undo.
    define input parameter piNorol  as int64     no-undo.
    define input parameter piMspai  as integer   no-undo.
    define input parameter pdaDtdeb as date      no-undo.
    define input parameter table-handle phttSalpre.

    define variable vhttBuffer as handle no-undo.
    define buffer salpre for salpre.

    vhttBuffer = phttSalpre:default-buffer-handle.
    for first salpre no-lock
        where salpre.tprol = pcTprol
          and salpre.norol = piNorol
          and salpre.mspai = piMspai
          and salpre.dtdeb = pdaDtdeb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer salpre:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSalpre no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSalpre:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table salpre SalariÃ©s : PÃ©riodes de prÃ©sence 
    Notes  : service externe. Critère piMspai = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character no-undo.
    define input parameter piNorol as int64     no-undo.
    define input parameter piMspai as integer   no-undo.
    define input parameter table-handle phttSalpre.

    define variable vhttBuffer as handle  no-undo.
    define buffer salpre for salpre.

    vhttBuffer = phttSalpre:default-buffer-handle.
    if piMspai = ?
    then for each salpre no-lock
        where salpre.tprol = pcTprol
          and salpre.norol = piNorol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer salpre:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each salpre no-lock
        where salpre.tprol = pcTprol
          and salpre.norol = piNorol
          and salpre.mspai = piMspai:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer salpre:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSalpre no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSalpre private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhMspai    as handle  no-undo.
    define variable vhDtdeb    as handle  no-undo.
    define buffer salpre for salpre.

    create query vhttquery.
    vhttBuffer = ghttSalpre:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSalpre:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol, output vhMspai, output vhDtdeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first salpre exclusive-lock
                where rowid(salpre) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer salpre:handle, 'tprol/norol/mspai/dtdeb: ', substitute('&1/&2/&3/&4', vhTprol:buffer-value(), vhNorol:buffer-value(), vhMspai:buffer-value(), vhDtdeb:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer salpre:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSalpre private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer salpre for salpre.

    create query vhttquery.
    vhttBuffer = ghttSalpre:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSalpre:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create salpre.
            if not outils:copyValidField(buffer salpre:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSalpre private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhMspai    as handle  no-undo.
    define variable vhDtdeb    as handle  no-undo.
    define buffer salpre for salpre.

    create query vhttquery.
    vhttBuffer = ghttSalpre:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSalpre:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol, output vhMspai, output vhDtdeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first salpre exclusive-lock
                where rowid(Salpre) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer salpre:handle, 'tprol/norol/mspai/dtdeb: ', substitute('&1/&2/&3/&4', vhTprol:buffer-value(), vhNorol:buffer-value(), vhMspai:buffer-value(), vhDtdeb:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete salpre no-error.
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

procedure deleteSalpreSurRole:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeRole   as character no-undo.
    define input parameter piNumeroRole as int64     no-undo.

    define buffer salpre for salpre.

blocTrans:
    do transaction:
        for each salpre exclusive-lock
            where salpre.tprol = pcTypeRole
              and salpre.norol = piNumeroRole:  
            delete salpre no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status
end procedure.
