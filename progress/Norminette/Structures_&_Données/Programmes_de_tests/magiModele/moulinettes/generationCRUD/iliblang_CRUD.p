/*------------------------------------------------------------------------
File        : iliblang_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iliblang
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iliblang.i}
{application/include/error.i}
define variable ghttiliblang as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phLiblang-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur liblang-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'liblang-cd' then phLiblang-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIliblang private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIliblang.
    run updateIliblang.
    run createIliblang.
end procedure.

procedure setIliblang:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIliblang.
    ghttIliblang = phttIliblang.
    run crudIliblang.
    delete object phttIliblang.
end procedure.

procedure readIliblang:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iliblang Liste des libelles des differentes langues.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piLiblang-cd as integer    no-undo.
    define input parameter table-handle phttIliblang.
    define variable vhttBuffer as handle no-undo.
    define buffer iliblang for iliblang.

    vhttBuffer = phttIliblang:default-buffer-handle.
    for first iliblang no-lock
        where iliblang.liblang-cd = piLiblang-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iliblang:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIliblang no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIliblang:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iliblang Liste des libelles des differentes langues.
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIliblang.
    define variable vhttBuffer as handle  no-undo.
    define buffer iliblang for iliblang.

    vhttBuffer = phttIliblang:default-buffer-handle.
    for each iliblang no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iliblang:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIliblang no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIliblang private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLiblang-cd    as handle  no-undo.
    define buffer iliblang for iliblang.

    create query vhttquery.
    vhttBuffer = ghttIliblang:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIliblang:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLiblang-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iliblang exclusive-lock
                where rowid(iliblang) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iliblang:handle, 'liblang-cd: ', substitute('&1', vhLiblang-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iliblang:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIliblang private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iliblang for iliblang.

    create query vhttquery.
    vhttBuffer = ghttIliblang:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIliblang:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iliblang.
            if not outils:copyValidField(buffer iliblang:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIliblang private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLiblang-cd    as handle  no-undo.
    define buffer iliblang for iliblang.

    create query vhttquery.
    vhttBuffer = ghttIliblang:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIliblang:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLiblang-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iliblang exclusive-lock
                where rowid(Iliblang) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iliblang:handle, 'liblang-cd: ', substitute('&1', vhLiblang-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iliblang no-error.
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

