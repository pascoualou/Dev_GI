/*------------------------------------------------------------------------
File        : RqChpRup_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table RqChpRup
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/RqChpRup.i}
{application/include/error.i}
define variable ghttRqChpRup as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudRqchprup private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRqchprup.
    run updateRqchprup.
    run createRqchprup.
end procedure.

procedure setRqchprup:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRqchprup.
    ghttRqchprup = phttRqchprup.
    run crudRqchprup.
    delete object phttRqchprup.
end procedure.

procedure readRqchprup:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table RqChpRup 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdreq as character  no-undo.
    define input parameter pcCdchp as character  no-undo.
    define input parameter piNochp as integer    no-undo.
    define input parameter table-handle phttRqchprup.
    define variable vhttBuffer as handle no-undo.
    define buffer RqChpRup for RqChpRup.

    vhttBuffer = phttRqchprup:default-buffer-handle.
    for first RqChpRup no-lock
        where RqChpRup.cdreq = pcCdreq
          and RqChpRup.cdchp = pcCdchp
          and RqChpRup.nochp = piNochp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer RqChpRup:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRqchprup no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRqchprup:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table RqChpRup 
    Notes  : service externe. Critère pcCdchp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCdreq as character  no-undo.
    define input parameter pcCdchp as character  no-undo.
    define input parameter table-handle phttRqchprup.
    define variable vhttBuffer as handle  no-undo.
    define buffer RqChpRup for RqChpRup.

    vhttBuffer = phttRqchprup:default-buffer-handle.
    if pcCdchp = ?
    then for each RqChpRup no-lock
        where RqChpRup.cdreq = pcCdreq:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer RqChpRup:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each RqChpRup no-lock
        where RqChpRup.cdreq = pcCdreq
          and RqChpRup.cdchp = pcCdchp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer RqChpRup:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRqchprup no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRqchprup private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdreq    as handle  no-undo.
    define variable vhCdchp    as handle  no-undo.
    define variable vhNochp    as handle  no-undo.
    define buffer RqChpRup for RqChpRup.

    create query vhttquery.
    vhttBuffer = ghttRqchprup:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRqchprup:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdreq, output vhCdchp, output vhNochp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first RqChpRup exclusive-lock
                where rowid(RqChpRup) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer RqChpRup:handle, 'cdreq/cdchp/nochp: ', substitute('&1/&2/&3', vhCdreq:buffer-value(), vhCdchp:buffer-value(), vhNochp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer RqChpRup:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRqchprup private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer RqChpRup for RqChpRup.

    create query vhttquery.
    vhttBuffer = ghttRqchprup:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRqchprup:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create RqChpRup.
            if not outils:copyValidField(buffer RqChpRup:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRqchprup private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdreq    as handle  no-undo.
    define variable vhCdchp    as handle  no-undo.
    define variable vhNochp    as handle  no-undo.
    define buffer RqChpRup for RqChpRup.

    create query vhttquery.
    vhttBuffer = ghttRqchprup:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRqchprup:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdreq, output vhCdchp, output vhNochp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first RqChpRup exclusive-lock
                where rowid(Rqchprup) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer RqChpRup:handle, 'cdreq/cdchp/nochp: ', substitute('&1/&2/&3', vhCdreq:buffer-value(), vhCdchp:buffer-value(), vhNochp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete RqChpRup no-error.
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

