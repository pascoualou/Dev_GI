/*------------------------------------------------------------------------
File        : rprub_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table rprub
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/06/18 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttrprub as handle no-undo.     // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phCdrub as handle, output phCdsru as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/cdrub/cdsru, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'cdrub' then phCdrub = phBuffer:buffer-field(vi).
            when 'cdsru' then phCdsru = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudRprub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRprub.
    run updateRprub.
    run createRprub.
end procedure.

procedure setRprub:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRprub.
    ghttRprub = phttRprub.
    run crudRprub.
    delete object phttRprub.
end procedure.

procedure readRprub:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table rprub RÃ©patition par code rubrique
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character no-undo.
    define input parameter piNocon as int64     no-undo.
    define input parameter piCdrub as integer   no-undo.
    define input parameter piCdsru as integer   no-undo.
    define input parameter table-handle phttRprub.

    define variable vhttBuffer as handle no-undo.
    define buffer rprub for rprub.

    vhttBuffer = phttRprub:default-buffer-handle.
    for first rprub no-lock
        where rprub.tpcon = pcTpcon
          and rprub.nocon = piNocon
          and rprub.cdrub = piCdrub
          and rprub.cdsru = piCdsru:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rprub:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRprub no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRprub:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table rprub RÃ©patition par code rubrique
    Notes  : service externe. Critère piCdrub = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character no-undo.
    define input parameter piNocon as int64     no-undo.
    define input parameter piCdrub as integer   no-undo.
    define input parameter table-handle phttRprub.

    define variable vhttBuffer as handle  no-undo.
    define buffer rprub for rprub.

    vhttBuffer = phttRprub:default-buffer-handle.
    if piCdrub = ?
    then for each rprub no-lock
        where rprub.tpcon = pcTpcon
          and rprub.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rprub:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each rprub no-lock
        where rprub.tpcon = pcTpcon
          and rprub.nocon = piNocon
          and rprub.cdrub = piCdrub:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rprub:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRprub no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRprub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhCdrub    as handle  no-undo.
    define variable vhCdsru    as handle  no-undo.
    define buffer rprub for rprub.

    create query vhttquery.
    vhttBuffer = ghttRprub:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRprub:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhCdrub, output vhCdsru).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first rprub exclusive-lock
                where rowid(rprub) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer rprub:handle, 'tpcon/nocon/cdrub/cdsru: ', substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhCdrub:buffer-value(), vhCdsru:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer rprub:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRprub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer rprub for rprub.

    create query vhttquery.
    vhttBuffer = ghttRprub:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRprub:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create rprub.
            if not outils:copyValidField(buffer rprub:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRprub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhCdrub    as handle  no-undo.
    define variable vhCdsru    as handle  no-undo.
    define buffer rprub for rprub.

    create query vhttquery.
    vhttBuffer = ghttRprub:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRprub:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhCdrub, output vhCdsru).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first rprub exclusive-lock
                where rowid(Rprub) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer rprub:handle, 'tpcon/nocon/cdrub/cdsru: ', substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhCdrub:buffer-value(), vhCdsru:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete rprub no-error.
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

procedure deleteRprubSurContrat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.

    define buffer rprub for rprub.

blocTrans:
    do transaction:
        for each rprub exclusive-lock
            where rprub.tpcon = pcTypeContrat
              and rprub.nocon = piNumeroContrat:
            delete rprub no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status
end procedure.
