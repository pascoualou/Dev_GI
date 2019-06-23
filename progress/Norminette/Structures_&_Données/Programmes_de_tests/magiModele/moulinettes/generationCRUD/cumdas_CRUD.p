/*------------------------------------------------------------------------
File        : cumdas_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cumdas
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cumdas.i}
{application/include/error.i}
define variable ghttcumdas as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudCumdas private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCumdas.
    run updateCumdas.
    run createCumdas.
end procedure.

procedure setCumdas:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCumdas.
    ghttCumdas = phttCumdas.
    run crudCumdas.
    delete object phttCumdas.
end procedure.

procedure readCumdas:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cumdas 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character  no-undo.
    define input parameter pdeNorol as decimal    no-undo.
    define input parameter piMspai as integer    no-undo.
    define input parameter pcModul as character  no-undo.
    define input parameter table-handle phttCumdas.
    define variable vhttBuffer as handle no-undo.
    define buffer cumdas for cumdas.

    vhttBuffer = phttCumdas:default-buffer-handle.
    for first cumdas no-lock
        where cumdas.tprol = pcTprol
          and cumdas.norol = pdeNorol
          and cumdas.mspai = piMspai
          and cumdas.modul = pcModul:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cumdas:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCumdas no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCumdas:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cumdas 
    Notes  : service externe. Critère piMspai = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character  no-undo.
    define input parameter pdeNorol as decimal    no-undo.
    define input parameter piMspai as integer    no-undo.
    define input parameter table-handle phttCumdas.
    define variable vhttBuffer as handle  no-undo.
    define buffer cumdas for cumdas.

    vhttBuffer = phttCumdas:default-buffer-handle.
    if piMspai = ?
    then for each cumdas no-lock
        where cumdas.tprol = pcTprol
          and cumdas.norol = pdeNorol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cumdas:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cumdas no-lock
        where cumdas.tprol = pcTprol
          and cumdas.norol = pdeNorol
          and cumdas.mspai = piMspai:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cumdas:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCumdas no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCumdas private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhMspai    as handle  no-undo.
    define variable vhModul    as handle  no-undo.
    define buffer cumdas for cumdas.

    create query vhttquery.
    vhttBuffer = ghttCumdas:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCumdas:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol, output vhMspai, output vhModul).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cumdas exclusive-lock
                where rowid(cumdas) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cumdas:handle, 'tprol/norol/mspai/modul: ', substitute('&1/&2/&3/&4', vhTprol:buffer-value(), vhNorol:buffer-value(), vhMspai:buffer-value(), vhModul:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cumdas:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCumdas private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cumdas for cumdas.

    create query vhttquery.
    vhttBuffer = ghttCumdas:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCumdas:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cumdas.
            if not outils:copyValidField(buffer cumdas:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCumdas private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhMspai    as handle  no-undo.
    define variable vhModul    as handle  no-undo.
    define buffer cumdas for cumdas.

    create query vhttquery.
    vhttBuffer = ghttCumdas:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCumdas:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol, output vhMspai, output vhModul).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cumdas exclusive-lock
                where rowid(Cumdas) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cumdas:handle, 'tprol/norol/mspai/modul: ', substitute('&1/&2/&3/&4', vhTprol:buffer-value(), vhNorol:buffer-value(), vhMspai:buffer-value(), vhModul:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cumdas no-error.
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

