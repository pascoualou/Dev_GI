/*------------------------------------------------------------------------
File        : clibclasse_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table clibclasse
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/clibclasse.i}
{application/include/error.i}
define variable ghttclibclasse as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phLibnat-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur libnat-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'libnat-cd' then phLibnat-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudClibclasse private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteClibclasse.
    run updateClibclasse.
    run createClibclasse.
end procedure.

procedure setClibclasse:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttClibclasse.
    ghttClibclasse = phttClibclasse.
    run crudClibclasse.
    delete object phttClibclasse.
end procedure.

procedure readClibclasse:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table clibclasse Liste des natures de classe.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piLibnat-cd as integer    no-undo.
    define input parameter table-handle phttClibclasse.
    define variable vhttBuffer as handle no-undo.
    define buffer clibclasse for clibclasse.

    vhttBuffer = phttClibclasse:default-buffer-handle.
    for first clibclasse no-lock
        where clibclasse.libnat-cd = piLibnat-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer clibclasse:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttClibclasse no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getClibclasse:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table clibclasse Liste des natures de classe.
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttClibclasse.
    define variable vhttBuffer as handle  no-undo.
    define buffer clibclasse for clibclasse.

    vhttBuffer = phttClibclasse:default-buffer-handle.
    for each clibclasse no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer clibclasse:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttClibclasse no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateClibclasse private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibnat-cd    as handle  no-undo.
    define buffer clibclasse for clibclasse.

    create query vhttquery.
    vhttBuffer = ghttClibclasse:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttClibclasse:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibnat-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first clibclasse exclusive-lock
                where rowid(clibclasse) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer clibclasse:handle, 'libnat-cd: ', substitute('&1', vhLibnat-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer clibclasse:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createClibclasse private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer clibclasse for clibclasse.

    create query vhttquery.
    vhttBuffer = ghttClibclasse:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttClibclasse:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create clibclasse.
            if not outils:copyValidField(buffer clibclasse:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteClibclasse private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibnat-cd    as handle  no-undo.
    define buffer clibclasse for clibclasse.

    create query vhttquery.
    vhttBuffer = ghttClibclasse:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttClibclasse:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibnat-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first clibclasse exclusive-lock
                where rowid(Clibclasse) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer clibclasse:handle, 'libnat-cd: ', substitute('&1', vhLibnat-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete clibclasse no-error.
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

