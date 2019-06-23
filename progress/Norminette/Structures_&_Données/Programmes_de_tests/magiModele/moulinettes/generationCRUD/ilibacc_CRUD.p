/*------------------------------------------------------------------------
File        : ilibacc_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ilibacc
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ilibacc.i}
{application/include/error.i}
define variable ghttilibacc as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phLibacc-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur libacc-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'libacc-cd' then phLibacc-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIlibacc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIlibacc.
    run updateIlibacc.
    run createIlibacc.
end procedure.

procedure setIlibacc:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibacc.
    ghttIlibacc = phttIlibacc.
    run crudIlibacc.
    delete object phttIlibacc.
end procedure.

procedure readIlibacc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ilibacc Liste des libelles des types d'acceptation de traites.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piLibacc-cd as integer    no-undo.
    define input parameter table-handle phttIlibacc.
    define variable vhttBuffer as handle no-undo.
    define buffer ilibacc for ilibacc.

    vhttBuffer = phttIlibacc:default-buffer-handle.
    for first ilibacc no-lock
        where ilibacc.libacc-cd = piLibacc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibacc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibacc no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIlibacc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ilibacc Liste des libelles des types d'acceptation de traites.
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibacc.
    define variable vhttBuffer as handle  no-undo.
    define buffer ilibacc for ilibacc.

    vhttBuffer = phttIlibacc:default-buffer-handle.
    for each ilibacc no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibacc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibacc no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIlibacc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibacc-cd    as handle  no-undo.
    define buffer ilibacc for ilibacc.

    create query vhttquery.
    vhttBuffer = ghttIlibacc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIlibacc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibacc-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibacc exclusive-lock
                where rowid(ilibacc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibacc:handle, 'libacc-cd: ', substitute('&1', vhLibacc-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ilibacc:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIlibacc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ilibacc for ilibacc.

    create query vhttquery.
    vhttBuffer = ghttIlibacc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIlibacc:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ilibacc.
            if not outils:copyValidField(buffer ilibacc:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIlibacc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibacc-cd    as handle  no-undo.
    define buffer ilibacc for ilibacc.

    create query vhttquery.
    vhttBuffer = ghttIlibacc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIlibacc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibacc-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibacc exclusive-lock
                where rowid(Ilibacc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibacc:handle, 'libacc-cd: ', substitute('&1', vhLibacc-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ilibacc no-error.
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

