/*------------------------------------------------------------------------
File        : Factu_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table Factu
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/Factu.i}
{application/include/error.i}
define variable ghttFactu as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNofac as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NoFac, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NoFac' then phNofac = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudFactu private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteFactu.
    run updateFactu.
    run createFactu.
end procedure.

procedure setFactu:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttFactu.
    ghttFactu = phttFactu.
    run crudFactu.
    delete object phttFactu.
end procedure.

procedure readFactu:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table Factu Chaine Travaux : Table des Factures
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNofac as integer    no-undo.
    define input parameter table-handle phttFactu.
    define variable vhttBuffer as handle no-undo.
    define buffer Factu for Factu.

    vhttBuffer = phttFactu:default-buffer-handle.
    for first Factu no-lock
        where Factu.NoFac = piNofac:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Factu:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttFactu no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getFactu:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table Factu Chaine Travaux : Table des Factures
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttFactu.
    define variable vhttBuffer as handle  no-undo.
    define buffer Factu for Factu.

    vhttBuffer = phttFactu:default-buffer-handle.
    for each Factu no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Factu:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttFactu no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateFactu private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNofac    as handle  no-undo.
    define buffer Factu for Factu.

    create query vhttquery.
    vhttBuffer = ghttFactu:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttFactu:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNofac).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first Factu exclusive-lock
                where rowid(Factu) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer Factu:handle, 'NoFac: ', substitute('&1', vhNofac:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer Factu:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createFactu private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer Factu for Factu.

    create query vhttquery.
    vhttBuffer = ghttFactu:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttFactu:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create Factu.
            if not outils:copyValidField(buffer Factu:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteFactu private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNofac    as handle  no-undo.
    define buffer Factu for Factu.

    create query vhttquery.
    vhttBuffer = ghttFactu:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttFactu:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNofac).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first Factu exclusive-lock
                where rowid(Factu) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer Factu:handle, 'NoFac: ', substitute('&1', vhNofac:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete Factu no-error.
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

