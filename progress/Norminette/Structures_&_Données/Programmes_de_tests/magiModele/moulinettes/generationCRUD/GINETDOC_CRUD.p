/*------------------------------------------------------------------------
File        : GINETDOC_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table GINETDOC
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/GINETDOC.i}
{application/include/error.i}
define variable ghttGINETDOC as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNodoc as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NODOC, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NODOC' then phNodoc = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGinetdoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGinetdoc.
    run updateGinetdoc.
    run createGinetdoc.
end procedure.

procedure setGinetdoc:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGinetdoc.
    ghttGinetdoc = phttGinetdoc.
    run crudGinetdoc.
    delete object phttGinetdoc.
end procedure.

procedure readGinetdoc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table GINETDOC 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNodoc as integer    no-undo.
    define input parameter table-handle phttGinetdoc.
    define variable vhttBuffer as handle no-undo.
    define buffer GINETDOC for GINETDOC.

    vhttBuffer = phttGinetdoc:default-buffer-handle.
    for first GINETDOC no-lock
        where GINETDOC.NODOC = piNodoc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GINETDOC:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGinetdoc no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGinetdoc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table GINETDOC 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGinetdoc.
    define variable vhttBuffer as handle  no-undo.
    define buffer GINETDOC for GINETDOC.

    vhttBuffer = phttGinetdoc:default-buffer-handle.
    for each GINETDOC no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GINETDOC:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGinetdoc no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGinetdoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNodoc    as handle  no-undo.
    define buffer GINETDOC for GINETDOC.

    create query vhttquery.
    vhttBuffer = ghttGinetdoc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGinetdoc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNodoc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GINETDOC exclusive-lock
                where rowid(GINETDOC) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GINETDOC:handle, 'NODOC: ', substitute('&1', vhNodoc:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer GINETDOC:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGinetdoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer GINETDOC for GINETDOC.

    create query vhttquery.
    vhttBuffer = ghttGinetdoc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGinetdoc:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create GINETDOC.
            if not outils:copyValidField(buffer GINETDOC:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGinetdoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNodoc    as handle  no-undo.
    define buffer GINETDOC for GINETDOC.

    create query vhttquery.
    vhttBuffer = ghttGinetdoc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGinetdoc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNodoc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GINETDOC exclusive-lock
                where rowid(Ginetdoc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GINETDOC:handle, 'NODOC: ', substitute('&1', vhNodoc:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete GINETDOC no-error.
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

