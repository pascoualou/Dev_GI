/*------------------------------------------------------------------------
File        : RqReqDet_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table RqReqDet
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/RqReqDet.i}
{application/include/error.i}
define variable ghttRqReqDet as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdreq as handle, output phCddet as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdreq/cddet, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdreq' then phCdreq = phBuffer:buffer-field(vi).
            when 'cddet' then phCddet = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudRqreqdet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRqreqdet.
    run updateRqreqdet.
    run createRqreqdet.
end procedure.

procedure setRqreqdet:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRqreqdet.
    ghttRqreqdet = phttRqreqdet.
    run crudRqreqdet.
    delete object phttRqreqdet.
end procedure.

procedure readRqreqdet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table RqReqDet Détails de la requete : chaque enregistrement correspond à une colonne du browse correspondant
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdreq as character  no-undo.
    define input parameter pcCddet as character  no-undo.
    define input parameter table-handle phttRqreqdet.
    define variable vhttBuffer as handle no-undo.
    define buffer RqReqDet for RqReqDet.

    vhttBuffer = phttRqreqdet:default-buffer-handle.
    for first RqReqDet no-lock
        where RqReqDet.cdreq = pcCdreq
          and RqReqDet.cddet = pcCddet:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer RqReqDet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRqreqdet no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRqreqdet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table RqReqDet Détails de la requete : chaque enregistrement correspond à une colonne du browse correspondant
    Notes  : service externe. Critère pcCdreq = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCdreq as character  no-undo.
    define input parameter table-handle phttRqreqdet.
    define variable vhttBuffer as handle  no-undo.
    define buffer RqReqDet for RqReqDet.

    vhttBuffer = phttRqreqdet:default-buffer-handle.
    if pcCdreq = ?
    then for each RqReqDet no-lock
        where RqReqDet.cdreq = pcCdreq:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer RqReqDet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each RqReqDet no-lock
        where RqReqDet.cdreq = pcCdreq:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer RqReqDet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRqreqdet no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRqreqdet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdreq    as handle  no-undo.
    define variable vhCddet    as handle  no-undo.
    define buffer RqReqDet for RqReqDet.

    create query vhttquery.
    vhttBuffer = ghttRqreqdet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRqreqdet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdreq, output vhCddet).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first RqReqDet exclusive-lock
                where rowid(RqReqDet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer RqReqDet:handle, 'cdreq/cddet: ', substitute('&1/&2', vhCdreq:buffer-value(), vhCddet:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer RqReqDet:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRqreqdet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer RqReqDet for RqReqDet.

    create query vhttquery.
    vhttBuffer = ghttRqreqdet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRqreqdet:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create RqReqDet.
            if not outils:copyValidField(buffer RqReqDet:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRqreqdet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdreq    as handle  no-undo.
    define variable vhCddet    as handle  no-undo.
    define buffer RqReqDet for RqReqDet.

    create query vhttquery.
    vhttBuffer = ghttRqreqdet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRqreqdet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdreq, output vhCddet).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first RqReqDet exclusive-lock
                where rowid(Rqreqdet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer RqReqDet:handle, 'cdreq/cddet: ', substitute('&1/&2', vhCdreq:buffer-value(), vhCddet:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete RqReqDet no-error.
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

