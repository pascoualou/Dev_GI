/*------------------------------------------------------------------------
File        : iscijou_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iscijou
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iscijou.i}
{application/include/error.i}
define variable ghttiscijou as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIscijou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIscijou.
    run updateIscijou.
    run createIscijou.
end procedure.

procedure setIscijou:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIscijou.
    ghttIscijou = phttIscijou.
    run crudIscijou.
    delete object phttIscijou.
end procedure.

procedure readIscijou:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iscijou Table correspondances journaux SCI
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd as integer    no-undo.
    define input parameter table-handle phttIscijou.
    define variable vhttBuffer as handle no-undo.
    define buffer iscijou for iscijou.

    vhttBuffer = phttIscijou:default-buffer-handle.
    for first iscijou no-lock
        where iscijou.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iscijou:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIscijou no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIscijou:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iscijou Table correspondances journaux SCI
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIscijou.
    define variable vhttBuffer as handle  no-undo.
    define buffer iscijou for iscijou.

    vhttBuffer = phttIscijou:default-buffer-handle.
    for each iscijou no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iscijou:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIscijou no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIscijou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define buffer iscijou for iscijou.

    create query vhttquery.
    vhttBuffer = ghttIscijou:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIscijou:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iscijou exclusive-lock
                where rowid(iscijou) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iscijou:handle, 'soc-cd: ', substitute('&1', vhSoc-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iscijou:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIscijou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iscijou for iscijou.

    create query vhttquery.
    vhttBuffer = ghttIscijou:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIscijou:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iscijou.
            if not outils:copyValidField(buffer iscijou:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIscijou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define buffer iscijou for iscijou.

    create query vhttquery.
    vhttBuffer = ghttIscijou:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIscijou:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iscijou exclusive-lock
                where rowid(Iscijou) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iscijou:handle, 'soc-cd: ', substitute('&1', vhSoc-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iscijou no-error.
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

