/*------------------------------------------------------------------------
File        : iprtform_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iprtform
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iprtform.i}
{application/include/error.i}
define variable ghttiprtform as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phForm-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur form-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'form-cle' then phForm-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIprtform private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIprtform.
    run updateIprtform.
    run createIprtform.
end procedure.

procedure setIprtform:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIprtform.
    ghttIprtform = phttIprtform.
    run crudIprtform.
    delete object phttIprtform.
end procedure.

procedure readIprtform:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iprtform 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcForm-cle as character  no-undo.
    define input parameter table-handle phttIprtform.
    define variable vhttBuffer as handle no-undo.
    define buffer iprtform for iprtform.

    vhttBuffer = phttIprtform:default-buffer-handle.
    for first iprtform no-lock
        where iprtform.form-cle = pcForm-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iprtform:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIprtform no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIprtform:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iprtform 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIprtform.
    define variable vhttBuffer as handle  no-undo.
    define buffer iprtform for iprtform.

    vhttBuffer = phttIprtform:default-buffer-handle.
    for each iprtform no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iprtform:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIprtform no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIprtform private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhForm-cle    as handle  no-undo.
    define buffer iprtform for iprtform.

    create query vhttquery.
    vhttBuffer = ghttIprtform:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIprtform:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhForm-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iprtform exclusive-lock
                where rowid(iprtform) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iprtform:handle, 'form-cle: ', substitute('&1', vhForm-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iprtform:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIprtform private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iprtform for iprtform.

    create query vhttquery.
    vhttBuffer = ghttIprtform:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIprtform:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iprtform.
            if not outils:copyValidField(buffer iprtform:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIprtform private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhForm-cle    as handle  no-undo.
    define buffer iprtform for iprtform.

    create query vhttquery.
    vhttBuffer = ghttIprtform:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIprtform:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhForm-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iprtform exclusive-lock
                where rowid(Iprtform) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iprtform:handle, 'form-cle: ', substitute('&1', vhForm-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iprtform no-error.
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

