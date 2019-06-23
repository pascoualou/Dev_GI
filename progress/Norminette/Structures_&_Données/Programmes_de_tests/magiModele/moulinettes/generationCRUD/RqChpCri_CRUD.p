/*------------------------------------------------------------------------
File        : RqChpCri_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table RqChpCri
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/RqChpCri.i}
{application/include/error.i}
define variable ghttRqChpCri as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdreq as handle, output phCdchp as handle, output phNochp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdreq/cdchp/nochp, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdreq' then phCdreq = phBuffer:buffer-field(vi).
            when 'cdchp' then phCdchp = phBuffer:buffer-field(vi).
            when 'nochp' then phNochp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudRqchpcri private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRqchpcri.
    run updateRqchpcri.
    run createRqchpcri.
end procedure.

procedure setRqchpcri:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRqchpcri.
    ghttRqchpcri = phttRqchpcri.
    run crudRqchpcri.
    delete object phttRqchpcri.
end procedure.

procedure readRqchpcri:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table RqChpCri 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdreq as character  no-undo.
    define input parameter pcCdchp as character  no-undo.
    define input parameter piNochp as integer    no-undo.
    define input parameter table-handle phttRqchpcri.
    define variable vhttBuffer as handle no-undo.
    define buffer RqChpCri for RqChpCri.

    vhttBuffer = phttRqchpcri:default-buffer-handle.
    for first RqChpCri no-lock
        where RqChpCri.cdreq = pcCdreq
          and RqChpCri.cdchp = pcCdchp
          and RqChpCri.nochp = piNochp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer RqChpCri:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRqchpcri no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRqchpcri:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table RqChpCri 
    Notes  : service externe. Critère pcCdchp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCdreq as character  no-undo.
    define input parameter pcCdchp as character  no-undo.
    define input parameter table-handle phttRqchpcri.
    define variable vhttBuffer as handle  no-undo.
    define buffer RqChpCri for RqChpCri.

    vhttBuffer = phttRqchpcri:default-buffer-handle.
    if pcCdchp = ?
    then for each RqChpCri no-lock
        where RqChpCri.cdreq = pcCdreq:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer RqChpCri:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each RqChpCri no-lock
        where RqChpCri.cdreq = pcCdreq
          and RqChpCri.cdchp = pcCdchp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer RqChpCri:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRqchpcri no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRqchpcri private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdreq    as handle  no-undo.
    define variable vhCdchp    as handle  no-undo.
    define variable vhNochp    as handle  no-undo.
    define buffer RqChpCri for RqChpCri.

    create query vhttquery.
    vhttBuffer = ghttRqchpcri:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRqchpcri:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdreq, output vhCdchp, output vhNochp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first RqChpCri exclusive-lock
                where rowid(RqChpCri) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer RqChpCri:handle, 'cdreq/cdchp/nochp: ', substitute('&1/&2/&3', vhCdreq:buffer-value(), vhCdchp:buffer-value(), vhNochp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer RqChpCri:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRqchpcri private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer RqChpCri for RqChpCri.

    create query vhttquery.
    vhttBuffer = ghttRqchpcri:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRqchpcri:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create RqChpCri.
            if not outils:copyValidField(buffer RqChpCri:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRqchpcri private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdreq    as handle  no-undo.
    define variable vhCdchp    as handle  no-undo.
    define variable vhNochp    as handle  no-undo.
    define buffer RqChpCri for RqChpCri.

    create query vhttquery.
    vhttBuffer = ghttRqchpcri:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRqchpcri:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdreq, output vhCdchp, output vhNochp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first RqChpCri exclusive-lock
                where rowid(Rqchpcri) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer RqChpCri:handle, 'cdreq/cdchp/nochp: ', substitute('&1/&2/&3', vhCdreq:buffer-value(), vhCdchp:buffer-value(), vhNochp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete RqChpCri no-error.
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

