/*------------------------------------------------------------------------
File        : ilibfact_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ilibfact
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ilibfact.i}
{application/include/error.i}
define variable ghttilibfact as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phLibfact-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur libfact-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'libfact-cd' then phLibfact-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIlibfact private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIlibfact.
    run updateIlibfact.
    run createIlibfact.
end procedure.

procedure setIlibfact:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibfact.
    ghttIlibfact = phttIlibfact.
    run crudIlibfact.
    delete object phttIlibfact.
end procedure.

procedure readIlibfact:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ilibfact Liste des libelles des differents types de facturation.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piLibfact-cd as integer    no-undo.
    define input parameter table-handle phttIlibfact.
    define variable vhttBuffer as handle no-undo.
    define buffer ilibfact for ilibfact.

    vhttBuffer = phttIlibfact:default-buffer-handle.
    for first ilibfact no-lock
        where ilibfact.libfact-cd = piLibfact-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibfact:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibfact no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIlibfact:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ilibfact Liste des libelles des differents types de facturation.
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibfact.
    define variable vhttBuffer as handle  no-undo.
    define buffer ilibfact for ilibfact.

    vhttBuffer = phttIlibfact:default-buffer-handle.
    for each ilibfact no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibfact:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibfact no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIlibfact private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibfact-cd    as handle  no-undo.
    define buffer ilibfact for ilibfact.

    create query vhttquery.
    vhttBuffer = ghttIlibfact:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIlibfact:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibfact-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibfact exclusive-lock
                where rowid(ilibfact) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibfact:handle, 'libfact-cd: ', substitute('&1', vhLibfact-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ilibfact:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIlibfact private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ilibfact for ilibfact.

    create query vhttquery.
    vhttBuffer = ghttIlibfact:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIlibfact:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ilibfact.
            if not outils:copyValidField(buffer ilibfact:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIlibfact private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibfact-cd    as handle  no-undo.
    define buffer ilibfact for ilibfact.

    create query vhttquery.
    vhttBuffer = ghttIlibfact:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIlibfact:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibfact-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibfact exclusive-lock
                where rowid(Ilibfact) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibfact:handle, 'libfact-cd: ', substitute('&1', vhLibfact-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ilibfact no-error.
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

