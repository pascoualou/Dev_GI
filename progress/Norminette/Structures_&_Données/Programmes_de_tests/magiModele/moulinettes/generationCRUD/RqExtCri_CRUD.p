/*------------------------------------------------------------------------
File        : RqExtCri_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table RqExtCri
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/RqExtCri.i}
{application/include/error.i}
define variable ghttRqExtCri as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdreq as handle, output phCdext as handle, output phCdchp as handle, output phNochp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdreq/cdext/cdchp/nochp, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdreq' then phCdreq = phBuffer:buffer-field(vi).
            when 'cdext' then phCdext = phBuffer:buffer-field(vi).
            when 'cdchp' then phCdchp = phBuffer:buffer-field(vi).
            when 'nochp' then phNochp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudRqextcri private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRqextcri.
    run updateRqextcri.
    run createRqextcri.
end procedure.

procedure setRqextcri:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRqextcri.
    ghttRqextcri = phttRqextcri.
    run crudRqextcri.
    delete object phttRqextcri.
end procedure.

procedure readRqextcri:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table RqExtCri 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdreq as character  no-undo.
    define input parameter pcCdext as character  no-undo.
    define input parameter pcCdchp as character  no-undo.
    define input parameter piNochp as integer    no-undo.
    define input parameter table-handle phttRqextcri.
    define variable vhttBuffer as handle no-undo.
    define buffer RqExtCri for RqExtCri.

    vhttBuffer = phttRqextcri:default-buffer-handle.
    for first RqExtCri no-lock
        where RqExtCri.cdreq = pcCdreq
          and RqExtCri.cdext = pcCdext
          and RqExtCri.cdchp = pcCdchp
          and RqExtCri.nochp = piNochp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer RqExtCri:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRqextcri no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRqextcri:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table RqExtCri 
    Notes  : service externe. Critère pcCdchp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCdreq as character  no-undo.
    define input parameter pcCdext as character  no-undo.
    define input parameter pcCdchp as character  no-undo.
    define input parameter table-handle phttRqextcri.
    define variable vhttBuffer as handle  no-undo.
    define buffer RqExtCri for RqExtCri.

    vhttBuffer = phttRqextcri:default-buffer-handle.
    if pcCdchp = ?
    then for each RqExtCri no-lock
        where RqExtCri.cdreq = pcCdreq
          and RqExtCri.cdext = pcCdext:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer RqExtCri:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each RqExtCri no-lock
        where RqExtCri.cdreq = pcCdreq
          and RqExtCri.cdext = pcCdext
          and RqExtCri.cdchp = pcCdchp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer RqExtCri:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRqextcri no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRqextcri private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdreq    as handle  no-undo.
    define variable vhCdext    as handle  no-undo.
    define variable vhCdchp    as handle  no-undo.
    define variable vhNochp    as handle  no-undo.
    define buffer RqExtCri for RqExtCri.

    create query vhttquery.
    vhttBuffer = ghttRqextcri:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRqextcri:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdreq, output vhCdext, output vhCdchp, output vhNochp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first RqExtCri exclusive-lock
                where rowid(RqExtCri) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer RqExtCri:handle, 'cdreq/cdext/cdchp/nochp: ', substitute('&1/&2/&3/&4', vhCdreq:buffer-value(), vhCdext:buffer-value(), vhCdchp:buffer-value(), vhNochp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer RqExtCri:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRqextcri private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer RqExtCri for RqExtCri.

    create query vhttquery.
    vhttBuffer = ghttRqextcri:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRqextcri:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create RqExtCri.
            if not outils:copyValidField(buffer RqExtCri:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRqextcri private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdreq    as handle  no-undo.
    define variable vhCdext    as handle  no-undo.
    define variable vhCdchp    as handle  no-undo.
    define variable vhNochp    as handle  no-undo.
    define buffer RqExtCri for RqExtCri.

    create query vhttquery.
    vhttBuffer = ghttRqextcri:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRqextcri:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdreq, output vhCdext, output vhCdchp, output vhNochp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first RqExtCri exclusive-lock
                where rowid(Rqextcri) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer RqExtCri:handle, 'cdreq/cdext/cdchp/nochp: ', substitute('&1/&2/&3/&4', vhCdreq:buffer-value(), vhCdext:buffer-value(), vhCdchp:buffer-value(), vhNochp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete RqExtCri no-error.
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

