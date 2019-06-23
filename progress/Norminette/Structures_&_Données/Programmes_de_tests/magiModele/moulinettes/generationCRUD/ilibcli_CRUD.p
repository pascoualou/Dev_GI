/*------------------------------------------------------------------------
File        : ilibcli_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ilibcli
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ilibcli.i}
{application/include/error.i}
define variable ghttilibcli as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phLibcli-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/libcli-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'libcli-cd' then phLibcli-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIlibcli private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIlibcli.
    run updateIlibcli.
    run createIlibcli.
end procedure.

procedure setIlibcli:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibcli.
    ghttIlibcli = phttIlibcli.
    run crudIlibcli.
    delete object phttIlibcli.
end procedure.

procedure readIlibcli:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ilibcli Liste des categories de type de clients.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piLibcli-cd as integer    no-undo.
    define input parameter table-handle phttIlibcli.
    define variable vhttBuffer as handle no-undo.
    define buffer ilibcli for ilibcli.

    vhttBuffer = phttIlibcli:default-buffer-handle.
    for first ilibcli no-lock
        where ilibcli.soc-cd = piSoc-cd
          and ilibcli.libcli-cd = piLibcli-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibcli:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibcli no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIlibcli:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ilibcli Liste des categories de type de clients.
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter table-handle phttIlibcli.
    define variable vhttBuffer as handle  no-undo.
    define buffer ilibcli for ilibcli.

    vhttBuffer = phttIlibcli:default-buffer-handle.
    if piSoc-cd = ?
    then for each ilibcli no-lock
        where ilibcli.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibcli:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ilibcli no-lock
        where ilibcli.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibcli:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibcli no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIlibcli private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhLibcli-cd    as handle  no-undo.
    define buffer ilibcli for ilibcli.

    create query vhttquery.
    vhttBuffer = ghttIlibcli:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIlibcli:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhLibcli-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibcli exclusive-lock
                where rowid(ilibcli) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibcli:handle, 'soc-cd/libcli-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhLibcli-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ilibcli:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIlibcli private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ilibcli for ilibcli.

    create query vhttquery.
    vhttBuffer = ghttIlibcli:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIlibcli:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ilibcli.
            if not outils:copyValidField(buffer ilibcli:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIlibcli private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhLibcli-cd    as handle  no-undo.
    define buffer ilibcli for ilibcli.

    create query vhttquery.
    vhttBuffer = ghttIlibcli:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIlibcli:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhLibcli-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibcli exclusive-lock
                where rowid(Ilibcli) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibcli:handle, 'soc-cd/libcli-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhLibcli-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ilibcli no-error.
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

