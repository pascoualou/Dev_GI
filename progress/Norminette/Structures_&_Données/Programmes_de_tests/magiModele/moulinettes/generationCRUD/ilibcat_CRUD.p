/*------------------------------------------------------------------------
File        : ilibcat_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ilibcat
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ilibcat.i}
{application/include/error.i}
define variable ghttilibcat as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phLibcat-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur libcat-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'libcat-cd' then phLibcat-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIlibcat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIlibcat.
    run updateIlibcat.
    run createIlibcat.
end procedure.

procedure setIlibcat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibcat.
    ghttIlibcat = phttIlibcat.
    run crudIlibcat.
    delete object phttIlibcat.
end procedure.

procedure readIlibcat:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ilibcat Liste des libelles de categorie de compte.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piLibcat-cd as integer    no-undo.
    define input parameter table-handle phttIlibcat.
    define variable vhttBuffer as handle no-undo.
    define buffer ilibcat for ilibcat.

    vhttBuffer = phttIlibcat:default-buffer-handle.
    for first ilibcat no-lock
        where ilibcat.libcat-cd = piLibcat-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibcat:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibcat no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIlibcat:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ilibcat Liste des libelles de categorie de compte.
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibcat.
    define variable vhttBuffer as handle  no-undo.
    define buffer ilibcat for ilibcat.

    vhttBuffer = phttIlibcat:default-buffer-handle.
    for each ilibcat no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibcat:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibcat no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIlibcat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibcat-cd    as handle  no-undo.
    define buffer ilibcat for ilibcat.

    create query vhttquery.
    vhttBuffer = ghttIlibcat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIlibcat:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibcat-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibcat exclusive-lock
                where rowid(ilibcat) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibcat:handle, 'libcat-cd: ', substitute('&1', vhLibcat-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ilibcat:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIlibcat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ilibcat for ilibcat.

    create query vhttquery.
    vhttBuffer = ghttIlibcat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIlibcat:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ilibcat.
            if not outils:copyValidField(buffer ilibcat:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIlibcat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibcat-cd    as handle  no-undo.
    define buffer ilibcat for ilibcat.

    create query vhttquery.
    vhttBuffer = ghttIlibcat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIlibcat:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibcat-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibcat exclusive-lock
                where rowid(Ilibcat) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibcat:handle, 'libcat-cd: ', substitute('&1', vhLibcat-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ilibcat no-error.
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

