/*------------------------------------------------------------------------
File        : ilibfonc_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ilibfonc
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ilibfonc.i}
{application/include/error.i}
define variable ghttilibfonc as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phFonc-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur fonc-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'fonc-cd' then phFonc-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIlibfonc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIlibfonc.
    run updateIlibfonc.
    run createIlibfonc.
end procedure.

procedure setIlibfonc:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibfonc.
    ghttIlibfonc = phttIlibfonc.
    run crudIlibfonc.
    delete object phttIlibfonc.
end procedure.

procedure readIlibfonc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ilibfonc 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piFonc-cd as integer    no-undo.
    define input parameter table-handle phttIlibfonc.
    define variable vhttBuffer as handle no-undo.
    define buffer ilibfonc for ilibfonc.

    vhttBuffer = phttIlibfonc:default-buffer-handle.
    for first ilibfonc no-lock
        where ilibfonc.fonc-cd = piFonc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibfonc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibfonc no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIlibfonc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ilibfonc 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibfonc.
    define variable vhttBuffer as handle  no-undo.
    define buffer ilibfonc for ilibfonc.

    vhttBuffer = phttIlibfonc:default-buffer-handle.
    for each ilibfonc no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibfonc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibfonc no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIlibfonc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhFonc-cd    as handle  no-undo.
    define buffer ilibfonc for ilibfonc.

    create query vhttquery.
    vhttBuffer = ghttIlibfonc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIlibfonc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhFonc-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibfonc exclusive-lock
                where rowid(ilibfonc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibfonc:handle, 'fonc-cd: ', substitute('&1', vhFonc-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ilibfonc:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIlibfonc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ilibfonc for ilibfonc.

    create query vhttquery.
    vhttBuffer = ghttIlibfonc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIlibfonc:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ilibfonc.
            if not outils:copyValidField(buffer ilibfonc:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIlibfonc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhFonc-cd    as handle  no-undo.
    define buffer ilibfonc for ilibfonc.

    create query vhttquery.
    vhttBuffer = ghttIlibfonc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIlibfonc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhFonc-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibfonc exclusive-lock
                where rowid(Ilibfonc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibfonc:handle, 'fonc-cd: ', substitute('&1', vhFonc-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ilibfonc no-error.
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

