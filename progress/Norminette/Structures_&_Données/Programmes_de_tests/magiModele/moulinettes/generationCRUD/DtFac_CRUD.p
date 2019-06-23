/*------------------------------------------------------------------------
File        : DtFac_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table DtFac
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/DtFac.i}
{application/include/error.i}
define variable ghttDtFac as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNofac as handle, output phNoint as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NoFac/NoInt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NoFac' then phNofac = phBuffer:buffer-field(vi).
            when 'NoInt' then phNoint = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudDtfac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDtfac.
    run updateDtfac.
    run createDtfac.
end procedure.

procedure setDtfac:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDtfac.
    ghttDtfac = phttDtfac.
    run crudDtfac.
    delete object phttDtfac.
end procedure.

procedure readDtfac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table DtFac Chaine Travaux : Table Détail des Factures
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNofac as integer    no-undo.
    define input parameter piNoint as int64      no-undo.
    define input parameter table-handle phttDtfac.
    define variable vhttBuffer as handle no-undo.
    define buffer DtFac for DtFac.

    vhttBuffer = phttDtfac:default-buffer-handle.
    for first DtFac no-lock
        where DtFac.NoFac = piNofac
          and DtFac.NoInt = piNoint:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DtFac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDtfac no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDtfac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table DtFac Chaine Travaux : Table Détail des Factures
    Notes  : service externe. Critère piNofac = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNofac as integer    no-undo.
    define input parameter table-handle phttDtfac.
    define variable vhttBuffer as handle  no-undo.
    define buffer DtFac for DtFac.

    vhttBuffer = phttDtfac:default-buffer-handle.
    if piNofac = ?
    then for each DtFac no-lock
        where DtFac.NoFac = piNofac:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DtFac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each DtFac no-lock
        where DtFac.NoFac = piNofac:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DtFac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDtfac no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDtfac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNofac    as handle  no-undo.
    define variable vhNoint    as handle  no-undo.
    define buffer DtFac for DtFac.

    create query vhttquery.
    vhttBuffer = ghttDtfac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDtfac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNofac, output vhNoint).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DtFac exclusive-lock
                where rowid(DtFac) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DtFac:handle, 'NoFac/NoInt: ', substitute('&1/&2', vhNofac:buffer-value(), vhNoint:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer DtFac:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDtfac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer DtFac for DtFac.

    create query vhttquery.
    vhttBuffer = ghttDtfac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDtfac:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create DtFac.
            if not outils:copyValidField(buffer DtFac:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDtfac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNofac    as handle  no-undo.
    define variable vhNoint    as handle  no-undo.
    define buffer DtFac for DtFac.

    create query vhttquery.
    vhttBuffer = ghttDtfac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDtfac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNofac, output vhNoint).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DtFac exclusive-lock
                where rowid(Dtfac) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DtFac:handle, 'NoFac/NoInt: ', substitute('&1/&2', vhNofac:buffer-value(), vhNoint:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete DtFac no-error.
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

