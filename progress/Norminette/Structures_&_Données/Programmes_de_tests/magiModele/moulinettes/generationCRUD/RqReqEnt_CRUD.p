/*------------------------------------------------------------------------
File        : RqReqEnt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table RqReqEnt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/RqReqEnt.i}
{application/include/error.i}
define variable ghttRqReqEnt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdreq as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdreq, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdreq' then phCdreq = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudRqreqent private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRqreqent.
    run updateRqreqent.
    run createRqreqent.
end procedure.

procedure setRqreqent:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRqreqent.
    ghttRqreqent = phttRqreqent.
    run crudRqreqent.
    delete object phttRqreqent.
end procedure.

procedure readRqreqent:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table RqReqEnt Entete des requetes : Seuls les champs fixes définissant la base de la requete. Les options de la requete sont dans RqReqDet
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdreq as character  no-undo.
    define input parameter table-handle phttRqreqent.
    define variable vhttBuffer as handle no-undo.
    define buffer RqReqEnt for RqReqEnt.

    vhttBuffer = phttRqreqent:default-buffer-handle.
    for first RqReqEnt no-lock
        where RqReqEnt.cdreq = pcCdreq:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer RqReqEnt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRqreqent no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRqreqent:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table RqReqEnt Entete des requetes : Seuls les champs fixes définissant la base de la requete. Les options de la requete sont dans RqReqDet
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRqreqent.
    define variable vhttBuffer as handle  no-undo.
    define buffer RqReqEnt for RqReqEnt.

    vhttBuffer = phttRqreqent:default-buffer-handle.
    for each RqReqEnt no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer RqReqEnt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRqreqent no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRqreqent private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdreq    as handle  no-undo.
    define buffer RqReqEnt for RqReqEnt.

    create query vhttquery.
    vhttBuffer = ghttRqreqent:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRqreqent:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdreq).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first RqReqEnt exclusive-lock
                where rowid(RqReqEnt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer RqReqEnt:handle, 'cdreq: ', substitute('&1', vhCdreq:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer RqReqEnt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRqreqent private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer RqReqEnt for RqReqEnt.

    create query vhttquery.
    vhttBuffer = ghttRqreqent:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRqreqent:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create RqReqEnt.
            if not outils:copyValidField(buffer RqReqEnt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRqreqent private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdreq    as handle  no-undo.
    define buffer RqReqEnt for RqReqEnt.

    create query vhttquery.
    vhttBuffer = ghttRqreqent:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRqreqent:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdreq).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first RqReqEnt exclusive-lock
                where rowid(Rqreqent) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer RqReqEnt:handle, 'cdreq: ', substitute('&1', vhCdreq:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete RqReqEnt no-error.
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

