/*------------------------------------------------------------------------
File        : ratlo_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ratlo
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/08/08 - phm: 
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttratlo as handle no-undo.     // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phNoimm as handle, output phNolot as handle, output phDtdeb as handle, output phTpidt as handle, output phNoidt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noimm/nolot/dtdeb/tpidt/noidt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noimm' then phNoimm = phBuffer:buffer-field(vi).
            when 'nolot' then phNolot = phBuffer:buffer-field(vi).
            when 'dtdeb' then phDtdeb = phBuffer:buffer-field(vi).
            when 'tpidt' then phTpidt = phBuffer:buffer-field(vi).
            when 'noidt' then phNoidt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudRatlo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRatlo.
    run updateRatlo.
    run createRatlo.
end procedure.

procedure setRatlo:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRatlo.
    ghttRatlo = phttRatlo.
    run crudRatlo.
    delete object phttRatlo.
end procedure.

procedure readRatlo:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ratlo rattachements des lots
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer    no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter pdaDtdeb as date       no-undo.
    define input parameter pcTpidt as character  no-undo.
    define input parameter piNoidt as int64      no-undo.
    define input parameter table-handle phttRatlo.
    define variable vhttBuffer as handle no-undo.
    define buffer ratlo for ratlo.

    vhttBuffer = phttRatlo:default-buffer-handle.
    for first ratlo no-lock
        where ratlo.noimm = piNoimm
          and ratlo.nolot = piNolot
          and ratlo.dtdeb = pdaDtdeb
          and ratlo.tpidt = pcTpidt
          and ratlo.noidt = piNoidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ratlo:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRatlo no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRatlo:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ratlo rattachements des lots
    Notes  : service externe. Critère pcTpidt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer    no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter pdaDtdeb as date       no-undo.
    define input parameter pcTpidt as character  no-undo.
    define input parameter table-handle phttRatlo.
    define variable vhttBuffer as handle  no-undo.
    define buffer ratlo for ratlo.

    vhttBuffer = phttRatlo:default-buffer-handle.
    if pcTpidt = ?
    then for each ratlo no-lock
        where ratlo.noimm = piNoimm
          and ratlo.nolot = piNolot
          and ratlo.dtdeb = pdaDtdeb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ratlo:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ratlo no-lock
        where ratlo.noimm = piNoimm
          and ratlo.nolot = piNolot
          and ratlo.dtdeb = pdaDtdeb
          and ratlo.tpidt = pcTpidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ratlo:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRatlo no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRatlo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhDtdeb    as handle  no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define buffer ratlo for ratlo.

    create query vhttquery.
    vhttBuffer = ghttRatlo:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRatlo:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm, output vhNolot, output vhDtdeb, output vhTpidt, output vhNoidt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ratlo exclusive-lock
                where rowid(ratlo) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ratlo:handle, 'noimm/nolot/dtdeb/tpidt/noidt: ', substitute('&1/&2/&3/&4/&5', vhNoimm:buffer-value(), vhNolot:buffer-value(), vhDtdeb:buffer-value(), vhTpidt:buffer-value(), vhNoidt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ratlo:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRatlo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer ratlo for ratlo.

    create query vhttquery.
    vhttBuffer = ghttRatlo:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRatlo:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ratlo.
            if not outils:copyValidField(buffer ratlo:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRatlo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhDtdeb    as handle  no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define buffer ratlo for ratlo.

    create query vhttquery.
    vhttBuffer = ghttRatlo:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRatlo:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm, output vhNolot, output vhDtdeb, output vhTpidt, output vhNoidt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ratlo exclusive-lock
                where rowid(Ratlo) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ratlo:handle, 'noimm/nolot/dtdeb/tpidt/noidt: ', substitute('&1/&2/&3/&4/&5', vhNoimm:buffer-value(), vhNolot:buffer-value(), vhDtdeb:buffer-value(), vhTpidt:buffer-value(), vhNoidt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ratlo no-error.
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

procedure deleteRatloSurMandat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat   as character no-undo.
    define input parameter piNumeroMandat as integer   no-undo.

    define buffer ratlo for ratlo.

blocTrans:
    do transaction:
        for each ratlo no-lock
            where ratlo.nomdt = piNumeroMandat:     // nouvel index ix_mandat en V19.00
            find current ratlo exclusive-lock.     
            delete ratlo no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status
end procedure.
