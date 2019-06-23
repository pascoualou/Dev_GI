/*------------------------------------------------------------------------
File        : ilibsens_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ilibsens
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ilibsens.i}
{application/include/error.i}
define variable ghttilibsens as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phLibsens-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur libsens-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'libsens-cd' then phLibsens-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIlibsens private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIlibsens.
    run updateIlibsens.
    run createIlibsens.
end procedure.

procedure setIlibsens:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibsens.
    ghttIlibsens = phttIlibsens.
    run crudIlibsens.
    delete object phttIlibsens.
end procedure.

procedure readIlibsens:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ilibsens Listes des Libelle des sens.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piLibsens-cd as integer    no-undo.
    define input parameter table-handle phttIlibsens.
    define variable vhttBuffer as handle no-undo.
    define buffer ilibsens for ilibsens.

    vhttBuffer = phttIlibsens:default-buffer-handle.
    for first ilibsens no-lock
        where ilibsens.libsens-cd = piLibsens-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibsens:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibsens no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIlibsens:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ilibsens Listes des Libelle des sens.
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibsens.
    define variable vhttBuffer as handle  no-undo.
    define buffer ilibsens for ilibsens.

    vhttBuffer = phttIlibsens:default-buffer-handle.
    for each ilibsens no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibsens:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibsens no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIlibsens private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibsens-cd    as handle  no-undo.
    define buffer ilibsens for ilibsens.

    create query vhttquery.
    vhttBuffer = ghttIlibsens:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIlibsens:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibsens-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibsens exclusive-lock
                where rowid(ilibsens) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibsens:handle, 'libsens-cd: ', substitute('&1', vhLibsens-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ilibsens:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIlibsens private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ilibsens for ilibsens.

    create query vhttquery.
    vhttBuffer = ghttIlibsens:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIlibsens:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ilibsens.
            if not outils:copyValidField(buffer ilibsens:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIlibsens private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibsens-cd    as handle  no-undo.
    define buffer ilibsens for ilibsens.

    create query vhttquery.
    vhttBuffer = ghttIlibsens:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIlibsens:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibsens-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibsens exclusive-lock
                where rowid(Ilibsens) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibsens:handle, 'libsens-cd: ', substitute('&1', vhLibsens-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ilibsens no-error.
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

