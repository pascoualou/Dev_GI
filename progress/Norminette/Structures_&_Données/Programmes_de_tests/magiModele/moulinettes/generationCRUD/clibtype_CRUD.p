/*------------------------------------------------------------------------
File        : clibtype_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table clibtype
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/clibtype.i}
{application/include/error.i}
define variable ghttclibtype as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phLibtype-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur libtype-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'libtype-cd' then phLibtype-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudClibtype private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteClibtype.
    run updateClibtype.
    run createClibtype.
end procedure.

procedure setClibtype:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttClibtype.
    ghttClibtype = phttClibtype.
    run crudClibtype.
    delete object phttClibtype.
end procedure.

procedure readClibtype:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table clibtype Liste des types de compte.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piLibtype-cd as integer    no-undo.
    define input parameter table-handle phttClibtype.
    define variable vhttBuffer as handle no-undo.
    define buffer clibtype for clibtype.

    vhttBuffer = phttClibtype:default-buffer-handle.
    for first clibtype no-lock
        where clibtype.libtype-cd = piLibtype-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer clibtype:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttClibtype no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getClibtype:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table clibtype Liste des types de compte.
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttClibtype.
    define variable vhttBuffer as handle  no-undo.
    define buffer clibtype for clibtype.

    vhttBuffer = phttClibtype:default-buffer-handle.
    for each clibtype no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer clibtype:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttClibtype no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateClibtype private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibtype-cd    as handle  no-undo.
    define buffer clibtype for clibtype.

    create query vhttquery.
    vhttBuffer = ghttClibtype:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttClibtype:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibtype-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first clibtype exclusive-lock
                where rowid(clibtype) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer clibtype:handle, 'libtype-cd: ', substitute('&1', vhLibtype-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer clibtype:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createClibtype private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer clibtype for clibtype.

    create query vhttquery.
    vhttBuffer = ghttClibtype:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttClibtype:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create clibtype.
            if not outils:copyValidField(buffer clibtype:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteClibtype private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhLibtype-cd    as handle  no-undo.
    define buffer clibtype for clibtype.

    create query vhttquery.
    vhttBuffer = ghttClibtype:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttClibtype:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhLibtype-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first clibtype exclusive-lock
                where rowid(Clibtype) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer clibtype:handle, 'libtype-cd: ', substitute('&1', vhLibtype-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete clibtype no-error.
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

