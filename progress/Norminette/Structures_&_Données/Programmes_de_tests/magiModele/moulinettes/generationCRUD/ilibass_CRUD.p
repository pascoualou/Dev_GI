/*------------------------------------------------------------------------
File        : ilibass_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ilibass
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ilibass.i}
{application/include/error.i}
define variable ghttilibass as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phLibass-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur libass-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'libass-cd' then phLibass-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIlibass private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIlibass.
    run updateIlibass.
    run createIlibass.
end procedure.

procedure setIlibass:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibass.
    ghttIlibass = phttIlibass.
    run crudIlibass.
    delete object phttIlibass.
end procedure.

procedure readIlibass:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ilibass Liste des libelles de code territorialite.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piLibass-cd as integer    no-undo.
    define input parameter table-handle phttIlibass.
    define variable vhttBuffer as handle no-undo.
    define buffer ilibass for ilibass.

    vhttBuffer = phttIlibass:default-buffer-handle.
    for first ilibass no-lock
        where ilibass.libass-cd = piLibass-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibass:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibass no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIlibass:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ilibass Liste des libelles de code territorialite.
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibass.
    define variable vhttBuffer as handle  no-undo.
    define buffer ilibass for ilibass.

    vhttBuffer = phttIlibass:default-buffer-handle.
    for each ilibass no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibass:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibass no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIlibass private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibass-cd    as handle  no-undo.
    define buffer ilibass for ilibass.

    create query vhttquery.
    vhttBuffer = ghttIlibass:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIlibass:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibass-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibass exclusive-lock
                where rowid(ilibass) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibass:handle, 'libass-cd: ', substitute('&1', vhLibass-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ilibass:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIlibass private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ilibass for ilibass.

    create query vhttquery.
    vhttBuffer = ghttIlibass:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIlibass:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ilibass.
            if not outils:copyValidField(buffer ilibass:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIlibass private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibass-cd    as handle  no-undo.
    define buffer ilibass for ilibass.

    create query vhttquery.
    vhttBuffer = ghttIlibass:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIlibass:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibass-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibass exclusive-lock
                where rowid(Ilibass) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibass:handle, 'libass-cd: ', substitute('&1', vhLibass-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ilibass no-error.
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

