/*------------------------------------------------------------------------
File        : RqChpTri_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table RqChpTri
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/RqChpTri.i}
{application/include/error.i}
define variable ghttRqChpTri as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudRqchptri private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRqchptri.
    run updateRqchptri.
    run createRqchptri.
end procedure.

procedure setRqchptri:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRqchptri.
    ghttRqchptri = phttRqchptri.
    run crudRqchptri.
    delete object phttRqchptri.
end procedure.

procedure readRqchptri:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table RqChpTri 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdreq as character  no-undo.
    define input parameter pcCdchp as character  no-undo.
    define input parameter piNochp as integer    no-undo.
    define input parameter table-handle phttRqchptri.
    define variable vhttBuffer as handle no-undo.
    define buffer RqChpTri for RqChpTri.

    vhttBuffer = phttRqchptri:default-buffer-handle.
    for first RqChpTri no-lock
        where RqChpTri.cdreq = pcCdreq
          and RqChpTri.cdchp = pcCdchp
          and RqChpTri.nochp = piNochp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer RqChpTri:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRqchptri no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRqchptri:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table RqChpTri 
    Notes  : service externe. Critère pcCdchp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCdreq as character  no-undo.
    define input parameter pcCdchp as character  no-undo.
    define input parameter table-handle phttRqchptri.
    define variable vhttBuffer as handle  no-undo.
    define buffer RqChpTri for RqChpTri.

    vhttBuffer = phttRqchptri:default-buffer-handle.
    if pcCdchp = ?
    then for each RqChpTri no-lock
        where RqChpTri.cdreq = pcCdreq:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer RqChpTri:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each RqChpTri no-lock
        where RqChpTri.cdreq = pcCdreq
          and RqChpTri.cdchp = pcCdchp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer RqChpTri:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRqchptri no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRqchptri private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdreq    as handle  no-undo.
    define variable vhCdchp    as handle  no-undo.
    define variable vhNochp    as handle  no-undo.
    define buffer RqChpTri for RqChpTri.

    create query vhttquery.
    vhttBuffer = ghttRqchptri:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRqchptri:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdreq, output vhCdchp, output vhNochp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first RqChpTri exclusive-lock
                where rowid(RqChpTri) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer RqChpTri:handle, 'cdreq/cdchp/nochp: ', substitute('&1/&2/&3', vhCdreq:buffer-value(), vhCdchp:buffer-value(), vhNochp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer RqChpTri:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRqchptri private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer RqChpTri for RqChpTri.

    create query vhttquery.
    vhttBuffer = ghttRqchptri:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRqchptri:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create RqChpTri.
            if not outils:copyValidField(buffer RqChpTri:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRqchptri private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdreq    as handle  no-undo.
    define variable vhCdchp    as handle  no-undo.
    define variable vhNochp    as handle  no-undo.
    define buffer RqChpTri for RqChpTri.

    create query vhttquery.
    vhttBuffer = ghttRqchptri:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRqchptri:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdreq, output vhCdchp, output vhNochp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first RqChpTri exclusive-lock
                where rowid(Rqchptri) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer RqChpTri:handle, 'cdreq/cdchp/nochp: ', substitute('&1/&2/&3', vhCdreq:buffer-value(), vhCdchp:buffer-value(), vhNochp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete RqChpTri no-error.
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

