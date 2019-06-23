/*------------------------------------------------------------------------
File        : GINETMDT_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table GINETMDT
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/GINETMDT.i}
{application/include/error.i}
define variable ghttGINETMDT as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNomdt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nomdt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGinetmdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGinetmdt.
    run updateGinetmdt.
    run createGinetmdt.
end procedure.

procedure setGinetmdt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGinetmdt.
    ghttGinetmdt = phttGinetmdt.
    run crudGinetmdt.
    delete object phttGinetmdt.
end procedure.

procedure readGinetmdt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table GINETMDT 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomdt as integer    no-undo.
    define input parameter table-handle phttGinetmdt.
    define variable vhttBuffer as handle no-undo.
    define buffer GINETMDT for GINETMDT.

    vhttBuffer = phttGinetmdt:default-buffer-handle.
    for first GINETMDT no-lock
        where GINETMDT.nomdt = piNomdt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GINETMDT:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGinetmdt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGinetmdt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table GINETMDT 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGinetmdt.
    define variable vhttBuffer as handle  no-undo.
    define buffer GINETMDT for GINETMDT.

    vhttBuffer = phttGinetmdt:default-buffer-handle.
    for each GINETMDT no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer GINETMDT:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGinetmdt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGinetmdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomdt    as handle  no-undo.
    define buffer GINETMDT for GINETMDT.

    create query vhttquery.
    vhttBuffer = ghttGinetmdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGinetmdt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GINETMDT exclusive-lock
                where rowid(GINETMDT) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GINETMDT:handle, 'nomdt: ', substitute('&1', vhNomdt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer GINETMDT:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGinetmdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer GINETMDT for GINETMDT.

    create query vhttquery.
    vhttBuffer = ghttGinetmdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGinetmdt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create GINETMDT.
            if not outils:copyValidField(buffer GINETMDT:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGinetmdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomdt    as handle  no-undo.
    define buffer GINETMDT for GINETMDT.

    create query vhttquery.
    vhttBuffer = ghttGinetmdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGinetmdt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first GINETMDT exclusive-lock
                where rowid(Ginetmdt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer GINETMDT:handle, 'nomdt: ', substitute('&1', vhNomdt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete GINETMDT no-error.
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

