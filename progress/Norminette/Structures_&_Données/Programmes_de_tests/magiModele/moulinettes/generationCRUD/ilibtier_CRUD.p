/*------------------------------------------------------------------------
File        : ilibtier_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ilibtier
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ilibtier.i}
{application/include/error.i}
define variable ghttilibtier as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phLibtier-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur libtier-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'libtier-cd' then phLibtier-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIlibtier private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIlibtier.
    run updateIlibtier.
    run createIlibtier.
end procedure.

procedure setIlibtier:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibtier.
    ghttIlibtier = phttIlibtier.
    run crudIlibtier.
    delete object phttIlibtier.
end procedure.

procedure readIlibtier:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ilibtier Liste des libelles de type de tiers.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piLibtier-cd as integer    no-undo.
    define input parameter table-handle phttIlibtier.
    define variable vhttBuffer as handle no-undo.
    define buffer ilibtier for ilibtier.

    vhttBuffer = phttIlibtier:default-buffer-handle.
    for first ilibtier no-lock
        where ilibtier.libtier-cd = piLibtier-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibtier:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibtier no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIlibtier:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ilibtier Liste des libelles de type de tiers.
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibtier.
    define variable vhttBuffer as handle  no-undo.
    define buffer ilibtier for ilibtier.

    vhttBuffer = phttIlibtier:default-buffer-handle.
    for each ilibtier no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibtier:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibtier no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIlibtier private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibtier-cd    as handle  no-undo.
    define buffer ilibtier for ilibtier.

    create query vhttquery.
    vhttBuffer = ghttIlibtier:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIlibtier:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibtier-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibtier exclusive-lock
                where rowid(ilibtier) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibtier:handle, 'libtier-cd: ', substitute('&1', vhLibtier-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ilibtier:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIlibtier private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ilibtier for ilibtier.

    create query vhttquery.
    vhttBuffer = ghttIlibtier:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIlibtier:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ilibtier.
            if not outils:copyValidField(buffer ilibtier:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIlibtier private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibtier-cd    as handle  no-undo.
    define buffer ilibtier for ilibtier.

    create query vhttquery.
    vhttBuffer = ghttIlibtier:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIlibtier:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibtier-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibtier exclusive-lock
                where rowid(Ilibtier) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibtier:handle, 'libtier-cd: ', substitute('&1', vhLibtier-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ilibtier no-error.
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

