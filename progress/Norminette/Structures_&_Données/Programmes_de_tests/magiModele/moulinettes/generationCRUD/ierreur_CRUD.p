/*------------------------------------------------------------------------
File        : ierreur_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ierreur
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ierreur.i}
{application/include/error.i}
define variable ghttierreur as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phLiblang-cd as handle, output phErreur-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur liblang-cd/erreur-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'liblang-cd' then phLiblang-cd = phBuffer:buffer-field(vi).
            when 'erreur-cd' then phErreur-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIerreur private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIerreur.
    run updateIerreur.
    run createIerreur.
end procedure.

procedure setIerreur:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIerreur.
    ghttIerreur = phttIerreur.
    run crudIerreur.
    delete object phttIerreur.
end procedure.

procedure readIerreur:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ierreur Liste des erreurs
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piLiblang-cd as integer    no-undo.
    define input parameter piErreur-cd  as integer    no-undo.
    define input parameter table-handle phttIerreur.
    define variable vhttBuffer as handle no-undo.
    define buffer ierreur for ierreur.

    vhttBuffer = phttIerreur:default-buffer-handle.
    for first ierreur no-lock
        where ierreur.liblang-cd = piLiblang-cd
          and ierreur.erreur-cd = piErreur-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ierreur:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIerreur no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIerreur:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ierreur Liste des erreurs
    Notes  : service externe. Critère piLiblang-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piLiblang-cd as integer    no-undo.
    define input parameter table-handle phttIerreur.
    define variable vhttBuffer as handle  no-undo.
    define buffer ierreur for ierreur.

    vhttBuffer = phttIerreur:default-buffer-handle.
    if piLiblang-cd = ?
    then for each ierreur no-lock
        where ierreur.liblang-cd = piLiblang-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ierreur:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ierreur no-lock
        where ierreur.liblang-cd = piLiblang-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ierreur:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIerreur no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIerreur private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLiblang-cd    as handle  no-undo.
    define variable vhErreur-cd    as handle  no-undo.
    define buffer ierreur for ierreur.

    create query vhttquery.
    vhttBuffer = ghttIerreur:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIerreur:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLiblang-cd, output vhErreur-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ierreur exclusive-lock
                where rowid(ierreur) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ierreur:handle, 'liblang-cd/erreur-cd: ', substitute('&1/&2', vhLiblang-cd:buffer-value(), vhErreur-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ierreur:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIerreur private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ierreur for ierreur.

    create query vhttquery.
    vhttBuffer = ghttIerreur:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIerreur:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ierreur.
            if not outils:copyValidField(buffer ierreur:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIerreur private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLiblang-cd    as handle  no-undo.
    define variable vhErreur-cd    as handle  no-undo.
    define buffer ierreur for ierreur.

    create query vhttquery.
    vhttBuffer = ghttIerreur:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIerreur:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLiblang-cd, output vhErreur-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ierreur exclusive-lock
                where rowid(Ierreur) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ierreur:handle, 'liblang-cd/erreur-cd: ', substitute('&1/&2', vhLiblang-cd:buffer-value(), vhErreur-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ierreur no-error.
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

