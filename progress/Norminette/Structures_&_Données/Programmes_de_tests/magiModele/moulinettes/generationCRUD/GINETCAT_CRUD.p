/*------------------------------------------------------------------------
File        : GINETCAT_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table GINETCAT
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/GINETCAT.i}
{application/include/error.i}
define variable ghttGINETCAT as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdcat as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur CDCAT, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'CDCAT' then phCdcat = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGinetcat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGinetcat.
    run updateGinetcat.
    run createGinetcat.
end procedure.

procedure setGinetcat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGinetcat.
    ghttGinetcat = phttGinetcat.
    run crudGinetcat.
    delete object phttGinetcat.
end procedure.

procedure readGinetcat:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table GINETCAT 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdcat as character  no-undo.
    define input parameter table-handle phttGinetcat.
    define variable vhttBuffer as handle no-undo.
    define buffer GINETCAT for GINETCAT.

    vhttBuffer = phttGinetcat:default-buffer-handle.
    for first GINETCAT no-lock
        where GINETCAT.CDCAT = pcCdcat:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GINETCAT:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGinetcat no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGinetcat:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table GINETCAT 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGinetcat.
    define variable vhttBuffer as handle  no-undo.
    define buffer GINETCAT for GINETCAT.

    vhttBuffer = phttGinetcat:default-buffer-handle.
    for each GINETCAT no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GINETCAT:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGinetcat no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGinetcat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdcat    as handle  no-undo.
    define buffer GINETCAT for GINETCAT.

    create query vhttquery.
    vhttBuffer = ghttGinetcat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGinetcat:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdcat).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GINETCAT exclusive-lock
                where rowid(GINETCAT) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GINETCAT:handle, 'CDCAT: ', substitute('&1', vhCdcat:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer GINETCAT:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGinetcat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer GINETCAT for GINETCAT.

    create query vhttquery.
    vhttBuffer = ghttGinetcat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGinetcat:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create GINETCAT.
            if not outils:copyValidField(buffer GINETCAT:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGinetcat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdcat    as handle  no-undo.
    define buffer GINETCAT for GINETCAT.

    create query vhttquery.
    vhttBuffer = ghttGinetcat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGinetcat:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdcat).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GINETCAT exclusive-lock
                where rowid(Ginetcat) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GINETCAT:handle, 'CDCAT: ', substitute('&1', vhCdcat:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete GINETCAT no-error.
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

