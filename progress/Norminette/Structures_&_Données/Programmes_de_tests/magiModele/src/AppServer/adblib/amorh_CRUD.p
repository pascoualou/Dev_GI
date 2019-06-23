/*------------------------------------------------------------------------
File        : amorh_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table amorh
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttamorh as handle no-undo.     // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phMsqtt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/msqtt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'msqtt' then phMsqtt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAmorh private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAmorh.
    run updateAmorh.
    run createAmorh.
end procedure.

procedure setAmorh:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAmorh.
    ghttAmorh = phttAmorh.
    run crudAmorh.
    delete object phttAmorh.
end procedure.

procedure readAmorh:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table amorh Historique amortissements calculÃ©s
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter piMsqtt as integer    no-undo.
    define input parameter table-handle phttAmorh.
    define variable vhttBuffer as handle no-undo.
    define buffer amorh for amorh.

    vhttBuffer = phttAmorh:default-buffer-handle.
    for first amorh no-lock
        where amorh.tpcon = pcTpcon
          and amorh.nocon = piNocon
          and amorh.msqtt = piMsqtt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer amorh:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAmorh no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAmorh:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table amorh Historique amortissements calculÃ©s
    Notes  : service externe. Critère piNocon = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter table-handle phttAmorh.
    define variable vhttBuffer as handle  no-undo.
    define buffer amorh for amorh.

    vhttBuffer = phttAmorh:default-buffer-handle.
    if piNocon = ?
    then for each amorh no-lock
        where amorh.tpcon = pcTpcon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer amorh:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each amorh no-lock
        where amorh.tpcon = pcTpcon
          and amorh.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer amorh:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAmorh no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAmorh private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhMsqtt    as handle  no-undo.
    define buffer amorh for amorh.

    create query vhttquery.
    vhttBuffer = ghttAmorh:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAmorh:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhMsqtt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first amorh exclusive-lock
                where rowid(amorh) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer amorh:handle, 'tpcon/nocon/msqtt: ', substitute('&1/&2/&3', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhMsqtt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer amorh:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAmorh private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer amorh for amorh.

    create query vhttquery.
    vhttBuffer = ghttAmorh:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAmorh:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create amorh.
            if not outils:copyValidField(buffer amorh:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAmorh private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhMsqtt    as handle  no-undo.
    define buffer amorh for amorh.

    create query vhttquery.
    vhttBuffer = ghttAmorh:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAmorh:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhMsqtt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first amorh exclusive-lock
                where rowid(Amorh) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer amorh:handle, 'tpcon/nocon/msqtt: ', substitute('&1/&2/&3', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhMsqtt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete amorh no-error.
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

procedure deleteAmorhSurContrat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.

    define buffer amorh for amorh.

blocTrans:
    do transaction:
        for each amorh exclusive-lock 
            where amorh.tpcon = pcTypeContrat 
              and amorh.nocon = piNumeroContrat:
            delete amorh no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status
end procedure.
