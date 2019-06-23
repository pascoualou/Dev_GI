/*------------------------------------------------------------------------
File        : iFrmBqu_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iFrmBqu
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iFrmBqu.i}
{application/include/error.i}
define variable ghttiFrmBqu as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdfrm as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdfrm, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdfrm' then phCdfrm = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfrmbqu private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfrmbqu.
    run updateIfrmbqu.
    run createIfrmbqu.
end procedure.

procedure setIfrmbqu:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfrmbqu.
    ghttIfrmbqu = phttIfrmbqu.
    run crudIfrmbqu.
    delete object phttIfrmbqu.
end procedure.

procedure readIfrmbqu:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iFrmBqu Liste des formats bancaires
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdfrm as character  no-undo.
    define input parameter table-handle phttIfrmbqu.
    define variable vhttBuffer as handle no-undo.
    define buffer iFrmBqu for iFrmBqu.

    vhttBuffer = phttIfrmbqu:default-buffer-handle.
    for first iFrmBqu no-lock
        where iFrmBqu.cdfrm = pcCdfrm:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iFrmBqu:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfrmbqu no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfrmbqu:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iFrmBqu Liste des formats bancaires
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfrmbqu.
    define variable vhttBuffer as handle  no-undo.
    define buffer iFrmBqu for iFrmBqu.

    vhttBuffer = phttIfrmbqu:default-buffer-handle.
    for each iFrmBqu no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iFrmBqu:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfrmbqu no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfrmbqu private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdfrm    as handle  no-undo.
    define buffer iFrmBqu for iFrmBqu.

    create query vhttquery.
    vhttBuffer = ghttIfrmbqu:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfrmbqu:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdfrm).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iFrmBqu exclusive-lock
                where rowid(iFrmBqu) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iFrmBqu:handle, 'cdfrm: ', substitute('&1', vhCdfrm:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iFrmBqu:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfrmbqu private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iFrmBqu for iFrmBqu.

    create query vhttquery.
    vhttBuffer = ghttIfrmbqu:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfrmbqu:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iFrmBqu.
            if not outils:copyValidField(buffer iFrmBqu:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfrmbqu private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdfrm    as handle  no-undo.
    define buffer iFrmBqu for iFrmBqu.

    create query vhttquery.
    vhttBuffer = ghttIfrmbqu:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfrmbqu:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdfrm).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iFrmBqu exclusive-lock
                where rowid(Ifrmbqu) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iFrmBqu:handle, 'cdfrm: ', substitute('&1', vhCdfrm:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iFrmBqu no-error.
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

