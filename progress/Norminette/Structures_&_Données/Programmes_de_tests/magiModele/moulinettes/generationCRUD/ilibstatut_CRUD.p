/*------------------------------------------------------------------------
File        : ilibstatut_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ilibstatut
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ilibstatut.i}
{application/include/error.i}
define variable ghttilibstatut as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phLibstatut-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur libstatut-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'libstatut-cd' then phLibstatut-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIlibstatut private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIlibstatut.
    run updateIlibstatut.
    run createIlibstatut.
end procedure.

procedure setIlibstatut:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibstatut.
    ghttIlibstatut = phttIlibstatut.
    run crudIlibstatut.
    delete object phttIlibstatut.
end procedure.

procedure readIlibstatut:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ilibstatut Liste des libelles de statut.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piLibstatut-cd as integer    no-undo.
    define input parameter table-handle phttIlibstatut.
    define variable vhttBuffer as handle no-undo.
    define buffer ilibstatut for ilibstatut.

    vhttBuffer = phttIlibstatut:default-buffer-handle.
    for first ilibstatut no-lock
        where ilibstatut.libstatut-cd = piLibstatut-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibstatut:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibstatut no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIlibstatut:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ilibstatut Liste des libelles de statut.
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibstatut.
    define variable vhttBuffer as handle  no-undo.
    define buffer ilibstatut for ilibstatut.

    vhttBuffer = phttIlibstatut:default-buffer-handle.
    for each ilibstatut no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibstatut:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibstatut no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIlibstatut private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibstatut-cd    as handle  no-undo.
    define buffer ilibstatut for ilibstatut.

    create query vhttquery.
    vhttBuffer = ghttIlibstatut:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIlibstatut:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibstatut-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibstatut exclusive-lock
                where rowid(ilibstatut) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibstatut:handle, 'libstatut-cd: ', substitute('&1', vhLibstatut-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ilibstatut:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIlibstatut private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ilibstatut for ilibstatut.

    create query vhttquery.
    vhttBuffer = ghttIlibstatut:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIlibstatut:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ilibstatut.
            if not outils:copyValidField(buffer ilibstatut:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIlibstatut private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibstatut-cd    as handle  no-undo.
    define buffer ilibstatut for ilibstatut.

    create query vhttquery.
    vhttBuffer = ghttIlibstatut:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIlibstatut:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibstatut-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibstatut exclusive-lock
                where rowid(Ilibstatut) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibstatut:handle, 'libstatut-cd: ', substitute('&1', vhLibstatut-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ilibstatut no-error.
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

