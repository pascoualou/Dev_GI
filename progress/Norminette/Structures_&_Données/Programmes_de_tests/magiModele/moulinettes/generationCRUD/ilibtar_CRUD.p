/*------------------------------------------------------------------------
File        : ilibtar_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ilibtar
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ilibtar.i}
{application/include/error.i}
define variable ghttilibtar as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phLibtar-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur libtar-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'libtar-cd' then phLibtar-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIlibtar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIlibtar.
    run updateIlibtar.
    run createIlibtar.
end procedure.

procedure setIlibtar:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibtar.
    ghttIlibtar = phttIlibtar.
    run crudIlibtar.
    delete object phttIlibtar.
end procedure.

procedure readIlibtar:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ilibtar Fichier LIBELLE Numeros de Tarif
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piLibtar-cd as integer    no-undo.
    define input parameter table-handle phttIlibtar.
    define variable vhttBuffer as handle no-undo.
    define buffer ilibtar for ilibtar.

    vhttBuffer = phttIlibtar:default-buffer-handle.
    for first ilibtar no-lock
        where ilibtar.libtar-cd = piLibtar-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibtar:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibtar no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIlibtar:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ilibtar Fichier LIBELLE Numeros de Tarif
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibtar.
    define variable vhttBuffer as handle  no-undo.
    define buffer ilibtar for ilibtar.

    vhttBuffer = phttIlibtar:default-buffer-handle.
    for each ilibtar no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibtar:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibtar no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIlibtar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibtar-cd    as handle  no-undo.
    define buffer ilibtar for ilibtar.

    create query vhttquery.
    vhttBuffer = ghttIlibtar:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIlibtar:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibtar-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibtar exclusive-lock
                where rowid(ilibtar) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibtar:handle, 'libtar-cd: ', substitute('&1', vhLibtar-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ilibtar:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIlibtar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ilibtar for ilibtar.

    create query vhttquery.
    vhttBuffer = ghttIlibtar:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIlibtar:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ilibtar.
            if not outils:copyValidField(buffer ilibtar:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIlibtar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibtar-cd    as handle  no-undo.
    define buffer ilibtar for ilibtar.

    create query vhttquery.
    vhttBuffer = ghttIlibtar:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIlibtar:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibtar-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibtar exclusive-lock
                where rowid(Ilibtar) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibtar:handle, 'libtar-cd: ', substitute('&1', vhLibtar-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ilibtar no-error.
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

