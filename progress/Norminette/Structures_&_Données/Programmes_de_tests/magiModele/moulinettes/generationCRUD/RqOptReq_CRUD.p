/*------------------------------------------------------------------------
File        : RqOptReq_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table RqOptReq
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/RqOptReq.i}
{application/include/error.i}
define variable ghttRqOptReq as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpopt as handle, output phCdopt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpopt/cdopt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpopt' then phTpopt = phBuffer:buffer-field(vi).
            when 'cdopt' then phCdopt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudRqoptreq private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRqoptreq.
    run updateRqoptreq.
    run createRqoptreq.
end procedure.

procedure setRqoptreq:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRqoptreq.
    ghttRqoptreq = phttRqoptreq.
    run crudRqoptreq.
    delete object phttRqoptreq.
end procedure.

procedure readRqoptreq:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table RqOptReq Contient les options possibles avec les valeurs respectives possible pour chaque option, la valeur par défaut et le libellé de l'option (= libellé de la colonne dans le browse correspondant), ce, pour les requetes, champs, et extractions
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpopt as character  no-undo.
    define input parameter pcCdopt as character  no-undo.
    define input parameter table-handle phttRqoptreq.
    define variable vhttBuffer as handle no-undo.
    define buffer RqOptReq for RqOptReq.

    vhttBuffer = phttRqoptreq:default-buffer-handle.
    for first RqOptReq no-lock
        where RqOptReq.tpopt = pcTpopt
          and RqOptReq.cdopt = pcCdopt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer RqOptReq:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRqoptreq no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRqoptreq:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table RqOptReq Contient les options possibles avec les valeurs respectives possible pour chaque option, la valeur par défaut et le libellé de l'option (= libellé de la colonne dans le browse correspondant), ce, pour les requetes, champs, et extractions
    Notes  : service externe. Critère pcTpopt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpopt as character  no-undo.
    define input parameter table-handle phttRqoptreq.
    define variable vhttBuffer as handle  no-undo.
    define buffer RqOptReq for RqOptReq.

    vhttBuffer = phttRqoptreq:default-buffer-handle.
    if pcTpopt = ?
    then for each RqOptReq no-lock
        where RqOptReq.tpopt = pcTpopt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer RqOptReq:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each RqOptReq no-lock
        where RqOptReq.tpopt = pcTpopt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer RqOptReq:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRqoptreq no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRqoptreq private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpopt    as handle  no-undo.
    define variable vhCdopt    as handle  no-undo.
    define buffer RqOptReq for RqOptReq.

    create query vhttquery.
    vhttBuffer = ghttRqoptreq:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRqoptreq:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpopt, output vhCdopt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first RqOptReq exclusive-lock
                where rowid(RqOptReq) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer RqOptReq:handle, 'tpopt/cdopt: ', substitute('&1/&2', vhTpopt:buffer-value(), vhCdopt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer RqOptReq:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRqoptreq private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer RqOptReq for RqOptReq.

    create query vhttquery.
    vhttBuffer = ghttRqoptreq:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRqoptreq:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create RqOptReq.
            if not outils:copyValidField(buffer RqOptReq:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRqoptreq private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpopt    as handle  no-undo.
    define variable vhCdopt    as handle  no-undo.
    define buffer RqOptReq for RqOptReq.

    create query vhttquery.
    vhttBuffer = ghttRqoptreq:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRqoptreq:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpopt, output vhCdopt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first RqOptReq exclusive-lock
                where rowid(Rqoptreq) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer RqOptReq:handle, 'tpopt/cdopt: ', substitute('&1/&2', vhTpopt:buffer-value(), vhCdopt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete RqOptReq no-error.
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

