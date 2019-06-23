/*------------------------------------------------------------------------
File        : imsg_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table imsg
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/imsg.i}
{application/include/error.i}
define variable ghttimsg as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phLanguage-cd as handle, output phNum as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur language-cd/num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'language-cd' then phLanguage-cd = phBuffer:buffer-field(vi).
            when 'num' then phNum = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudImsg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteImsg.
    run updateImsg.
    run createImsg.
end procedure.

procedure setImsg:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttImsg.
    ghttImsg = phttImsg.
    run crudImsg.
    delete object phttImsg.
end procedure.

procedure readImsg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table imsg Fichier des messages
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piLanguage-cd as integer    no-undo.
    define input parameter piNum         as integer    no-undo.
    define input parameter table-handle phttImsg.
    define variable vhttBuffer as handle no-undo.
    define buffer imsg for imsg.

    vhttBuffer = phttImsg:default-buffer-handle.
    for first imsg no-lock
        where imsg.language-cd = piLanguage-cd
          and imsg.num = piNum:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer imsg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttImsg no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getImsg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table imsg Fichier des messages
    Notes  : service externe. Critère piLanguage-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piLanguage-cd as integer    no-undo.
    define input parameter table-handle phttImsg.
    define variable vhttBuffer as handle  no-undo.
    define buffer imsg for imsg.

    vhttBuffer = phttImsg:default-buffer-handle.
    if piLanguage-cd = ?
    then for each imsg no-lock
        where imsg.language-cd = piLanguage-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer imsg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each imsg no-lock
        where imsg.language-cd = piLanguage-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer imsg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttImsg no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateImsg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLanguage-cd    as handle  no-undo.
    define variable vhNum    as handle  no-undo.
    define buffer imsg for imsg.

    create query vhttquery.
    vhttBuffer = ghttImsg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttImsg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLanguage-cd, output vhNum).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first imsg exclusive-lock
                where rowid(imsg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer imsg:handle, 'language-cd/num: ', substitute('&1/&2', vhLanguage-cd:buffer-value(), vhNum:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer imsg:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createImsg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer imsg for imsg.

    create query vhttquery.
    vhttBuffer = ghttImsg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttImsg:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create imsg.
            if not outils:copyValidField(buffer imsg:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteImsg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLanguage-cd    as handle  no-undo.
    define variable vhNum    as handle  no-undo.
    define buffer imsg for imsg.

    create query vhttquery.
    vhttBuffer = ghttImsg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttImsg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLanguage-cd, output vhNum).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first imsg exclusive-lock
                where rowid(Imsg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer imsg:handle, 'language-cd/num: ', substitute('&1/&2', vhLanguage-cd:buffer-value(), vhNum:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete imsg no-error.
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

