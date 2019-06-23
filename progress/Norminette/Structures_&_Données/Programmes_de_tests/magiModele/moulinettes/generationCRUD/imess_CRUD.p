/*------------------------------------------------------------------------
File        : imess_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table imess
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/imess.i}
{application/include/error.i}
define variable ghttimess as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phLiblang-cd as handle, output phMess-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur liblang-cd/mess-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'liblang-cd' then phLiblang-cd = phBuffer:buffer-field(vi).
            when 'mess-cd' then phMess-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudImess private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteImess.
    run updateImess.
    run createImess.
end procedure.

procedure setImess:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttImess.
    ghttImess = phttImess.
    run crudImess.
    delete object phttImess.
end procedure.

procedure readImess:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table imess Liste des messages
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piLiblang-cd as integer    no-undo.
    define input parameter piMess-cd    as integer    no-undo.
    define input parameter table-handle phttImess.
    define variable vhttBuffer as handle no-undo.
    define buffer imess for imess.

    vhttBuffer = phttImess:default-buffer-handle.
    for first imess no-lock
        where imess.liblang-cd = piLiblang-cd
          and imess.mess-cd = piMess-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer imess:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttImess no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getImess:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table imess Liste des messages
    Notes  : service externe. Critère piLiblang-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piLiblang-cd as integer    no-undo.
    define input parameter table-handle phttImess.
    define variable vhttBuffer as handle  no-undo.
    define buffer imess for imess.

    vhttBuffer = phttImess:default-buffer-handle.
    if piLiblang-cd = ?
    then for each imess no-lock
        where imess.liblang-cd = piLiblang-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer imess:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each imess no-lock
        where imess.liblang-cd = piLiblang-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer imess:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttImess no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateImess private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLiblang-cd    as handle  no-undo.
    define variable vhMess-cd    as handle  no-undo.
    define buffer imess for imess.

    create query vhttquery.
    vhttBuffer = ghttImess:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttImess:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLiblang-cd, output vhMess-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first imess exclusive-lock
                where rowid(imess) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer imess:handle, 'liblang-cd/mess-cd: ', substitute('&1/&2', vhLiblang-cd:buffer-value(), vhMess-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer imess:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createImess private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer imess for imess.

    create query vhttquery.
    vhttBuffer = ghttImess:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttImess:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create imess.
            if not outils:copyValidField(buffer imess:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteImess private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLiblang-cd    as handle  no-undo.
    define variable vhMess-cd    as handle  no-undo.
    define buffer imess for imess.

    create query vhttquery.
    vhttBuffer = ghttImess:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttImess:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLiblang-cd, output vhMess-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first imess exclusive-lock
                where rowid(Imess) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer imess:handle, 'liblang-cd/mess-cd: ', substitute('&1/&2', vhLiblang-cd:buffer-value(), vhMess-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete imess no-error.
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

