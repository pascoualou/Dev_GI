/*------------------------------------------------------------------------
File        : ilibmess_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ilibmess
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ilibmess.i}
{application/include/error.i}
define variable ghttilibmess as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phLibmess-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur libmess-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'libmess-cd' then phLibmess-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIlibmess private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIlibmess.
    run updateIlibmess.
    run createIlibmess.
end procedure.

procedure setIlibmess:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibmess.
    ghttIlibmess = phttIlibmess.
    run crudIlibmess.
    delete object phttIlibmess.
end procedure.

procedure readIlibmess:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ilibmess Liste des libelles de message servant a aider l'utilisateur.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piLibmess-cd as integer    no-undo.
    define input parameter table-handle phttIlibmess.
    define variable vhttBuffer as handle no-undo.
    define buffer ilibmess for ilibmess.

    vhttBuffer = phttIlibmess:default-buffer-handle.
    for first ilibmess no-lock
        where ilibmess.libmess-cd = piLibmess-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibmess:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibmess no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIlibmess:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ilibmess Liste des libelles de message servant a aider l'utilisateur.
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibmess.
    define variable vhttBuffer as handle  no-undo.
    define buffer ilibmess for ilibmess.

    vhttBuffer = phttIlibmess:default-buffer-handle.
    for each ilibmess no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibmess:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibmess no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIlibmess private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibmess-cd    as handle  no-undo.
    define buffer ilibmess for ilibmess.

    create query vhttquery.
    vhttBuffer = ghttIlibmess:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIlibmess:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibmess-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibmess exclusive-lock
                where rowid(ilibmess) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibmess:handle, 'libmess-cd: ', substitute('&1', vhLibmess-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ilibmess:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIlibmess private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ilibmess for ilibmess.

    create query vhttquery.
    vhttBuffer = ghttIlibmess:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIlibmess:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ilibmess.
            if not outils:copyValidField(buffer ilibmess:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIlibmess private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibmess-cd    as handle  no-undo.
    define buffer ilibmess for ilibmess.

    create query vhttquery.
    vhttBuffer = ghttIlibmess:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIlibmess:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibmess-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibmess exclusive-lock
                where rowid(Ilibmess) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibmess:handle, 'libmess-cd: ', substitute('&1', vhLibmess-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ilibmess no-error.
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

