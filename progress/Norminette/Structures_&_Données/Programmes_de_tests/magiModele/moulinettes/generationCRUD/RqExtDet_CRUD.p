/*------------------------------------------------------------------------
File        : RqExtDet_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table RqExtDet
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/RqExtDet.i}
{application/include/error.i}
define variable ghttRqExtDet as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdreq as handle, output phCdext as handle, output phCddet as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdreq/cdext/cddet, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdreq' then phCdreq = phBuffer:buffer-field(vi).
            when 'cdext' then phCdext = phBuffer:buffer-field(vi).
            when 'cddet' then phCddet = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudRqextdet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRqextdet.
    run updateRqextdet.
    run createRqextdet.
end procedure.

procedure setRqextdet:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRqextdet.
    ghttRqextdet = phttRqextdet.
    run crudRqextdet.
    delete object phttRqextdet.
end procedure.

procedure readRqextdet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table RqExtDet 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdreq as character  no-undo.
    define input parameter pcCdext as character  no-undo.
    define input parameter pcCddet as character  no-undo.
    define input parameter table-handle phttRqextdet.
    define variable vhttBuffer as handle no-undo.
    define buffer RqExtDet for RqExtDet.

    vhttBuffer = phttRqextdet:default-buffer-handle.
    for first RqExtDet no-lock
        where RqExtDet.cdreq = pcCdreq
          and RqExtDet.cdext = pcCdext
          and RqExtDet.cddet = pcCddet:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer RqExtDet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRqextdet no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRqextdet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table RqExtDet 
    Notes  : service externe. Critère pcCdext = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCdreq as character  no-undo.
    define input parameter pcCdext as character  no-undo.
    define input parameter table-handle phttRqextdet.
    define variable vhttBuffer as handle  no-undo.
    define buffer RqExtDet for RqExtDet.

    vhttBuffer = phttRqextdet:default-buffer-handle.
    if pcCdext = ?
    then for each RqExtDet no-lock
        where RqExtDet.cdreq = pcCdreq:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer RqExtDet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each RqExtDet no-lock
        where RqExtDet.cdreq = pcCdreq
          and RqExtDet.cdext = pcCdext:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer RqExtDet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRqextdet no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRqextdet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdreq    as handle  no-undo.
    define variable vhCdext    as handle  no-undo.
    define variable vhCddet    as handle  no-undo.
    define buffer RqExtDet for RqExtDet.

    create query vhttquery.
    vhttBuffer = ghttRqextdet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRqextdet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdreq, output vhCdext, output vhCddet).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first RqExtDet exclusive-lock
                where rowid(RqExtDet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer RqExtDet:handle, 'cdreq/cdext/cddet: ', substitute('&1/&2/&3', vhCdreq:buffer-value(), vhCdext:buffer-value(), vhCddet:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer RqExtDet:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRqextdet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer RqExtDet for RqExtDet.

    create query vhttquery.
    vhttBuffer = ghttRqextdet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRqextdet:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create RqExtDet.
            if not outils:copyValidField(buffer RqExtDet:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRqextdet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdreq    as handle  no-undo.
    define variable vhCdext    as handle  no-undo.
    define variable vhCddet    as handle  no-undo.
    define buffer RqExtDet for RqExtDet.

    create query vhttquery.
    vhttBuffer = ghttRqextdet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRqextdet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdreq, output vhCdext, output vhCddet).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first RqExtDet exclusive-lock
                where rowid(Rqextdet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer RqExtDet:handle, 'cdreq/cdext/cddet: ', substitute('&1/&2/&3', vhCdreq:buffer-value(), vhCdext:buffer-value(), vhCddet:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete RqExtDet no-error.
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

