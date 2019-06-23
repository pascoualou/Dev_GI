/*------------------------------------------------------------------------
File        : iutil_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iutil
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iutil.i}
{application/include/error.i}
define variable ghttiutil as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phMtpwd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur mtpwd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'mtpwd' then phMtpwd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIutil private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIutil.
    run updateIutil.
    run createIutil.
end procedure.

procedure setIutil:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIutil.
    ghttIutil = phttIutil.
    run crudIutil.
    delete object phttIutil.
end procedure.

procedure readIutil:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iutil 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcMtpwd as character  no-undo.
    define input parameter table-handle phttIutil.
    define variable vhttBuffer as handle no-undo.
    define buffer iutil for iutil.

    vhttBuffer = phttIutil:default-buffer-handle.
    for first iutil no-lock
        where iutil.mtpwd = pcMtpwd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iutil:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIutil no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIutil:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iutil 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIutil.
    define variable vhttBuffer as handle  no-undo.
    define buffer iutil for iutil.

    vhttBuffer = phttIutil:default-buffer-handle.
    for each iutil no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iutil:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIutil no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIutil private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhMtpwd    as handle  no-undo.
    define buffer iutil for iutil.

    create query vhttquery.
    vhttBuffer = ghttIutil:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIutil:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhMtpwd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iutil exclusive-lock
                where rowid(iutil) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iutil:handle, 'mtpwd: ', substitute('&1', vhMtpwd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iutil:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIutil private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iutil for iutil.

    create query vhttquery.
    vhttBuffer = ghttIutil:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIutil:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iutil.
            if not outils:copyValidField(buffer iutil:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIutil private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhMtpwd    as handle  no-undo.
    define buffer iutil for iutil.

    create query vhttquery.
    vhttBuffer = ghttIutil:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIutil:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhMtpwd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iutil exclusive-lock
                where rowid(Iutil) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iutil:handle, 'mtpwd: ', substitute('&1', vhMtpwd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iutil no-error.
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

