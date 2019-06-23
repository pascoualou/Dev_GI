/*------------------------------------------------------------------------
File        : ilibadr_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ilibadr
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ilibadr.i}
{application/include/error.i}
define variable ghttilibadr as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phLibadr-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur libadr-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'libadr-cd' then phLibadr-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIlibadr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIlibadr.
    run updateIlibadr.
    run createIlibadr.
end procedure.

procedure setIlibadr:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibadr.
    ghttIlibadr = phttIlibadr.
    run crudIlibadr.
    delete object phttIlibadr.
end procedure.

procedure readIlibadr:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ilibadr Liste des types d'adresses.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piLibadr-cd as integer    no-undo.
    define input parameter table-handle phttIlibadr.
    define variable vhttBuffer as handle no-undo.
    define buffer ilibadr for ilibadr.

    vhttBuffer = phttIlibadr:default-buffer-handle.
    for first ilibadr no-lock
        where ilibadr.libadr-cd = piLibadr-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibadr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibadr no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIlibadr:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ilibadr Liste des types d'adresses.
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibadr.
    define variable vhttBuffer as handle  no-undo.
    define buffer ilibadr for ilibadr.

    vhttBuffer = phttIlibadr:default-buffer-handle.
    for each ilibadr no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibadr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibadr no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIlibadr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibadr-cd    as handle  no-undo.
    define buffer ilibadr for ilibadr.

    create query vhttquery.
    vhttBuffer = ghttIlibadr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIlibadr:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibadr-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibadr exclusive-lock
                where rowid(ilibadr) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibadr:handle, 'libadr-cd: ', substitute('&1', vhLibadr-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ilibadr:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIlibadr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ilibadr for ilibadr.

    create query vhttquery.
    vhttBuffer = ghttIlibadr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIlibadr:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ilibadr.
            if not outils:copyValidField(buffer ilibadr:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIlibadr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibadr-cd    as handle  no-undo.
    define buffer ilibadr for ilibadr.

    create query vhttquery.
    vhttBuffer = ghttIlibadr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIlibadr:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibadr-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibadr exclusive-lock
                where rowid(Ilibadr) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibadr:handle, 'libadr-cd: ', substitute('&1', vhLibadr-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ilibadr no-error.
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

