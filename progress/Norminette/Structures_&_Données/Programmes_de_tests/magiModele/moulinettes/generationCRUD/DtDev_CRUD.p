/*------------------------------------------------------------------------
File        : DtDev_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table DtDev
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/DtDev.i}
{application/include/error.i}
define variable ghttDtDev as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNodev as handle, output phNoint as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NoDev/NoInt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NoDev' then phNodev = phBuffer:buffer-field(vi).
            when 'NoInt' then phNoint = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudDtdev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDtdev.
    run updateDtdev.
    run createDtdev.
end procedure.

procedure setDtdev:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDtdev.
    ghttDtdev = phttDtdev.
    run crudDtdev.
    delete object phttDtdev.
end procedure.

procedure readDtdev:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table DtDev Chaine Travaux : Table Détail d'un Devis
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNodev as integer    no-undo.
    define input parameter piNoint as int64      no-undo.
    define input parameter table-handle phttDtdev.
    define variable vhttBuffer as handle no-undo.
    define buffer DtDev for DtDev.

    vhttBuffer = phttDtdev:default-buffer-handle.
    for first DtDev no-lock
        where DtDev.NoDev = piNodev
          and DtDev.NoInt = piNoint:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DtDev:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDtdev no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDtdev:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table DtDev Chaine Travaux : Table Détail d'un Devis
    Notes  : service externe. Critère piNodev = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNodev as integer    no-undo.
    define input parameter table-handle phttDtdev.
    define variable vhttBuffer as handle  no-undo.
    define buffer DtDev for DtDev.

    vhttBuffer = phttDtdev:default-buffer-handle.
    if piNodev = ?
    then for each DtDev no-lock
        where DtDev.NoDev = piNodev:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DtDev:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each DtDev no-lock
        where DtDev.NoDev = piNodev:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DtDev:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDtdev no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDtdev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNodev    as handle  no-undo.
    define variable vhNoint    as handle  no-undo.
    define buffer DtDev for DtDev.

    create query vhttquery.
    vhttBuffer = ghttDtdev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDtdev:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNodev, output vhNoint).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DtDev exclusive-lock
                where rowid(DtDev) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DtDev:handle, 'NoDev/NoInt: ', substitute('&1/&2', vhNodev:buffer-value(), vhNoint:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer DtDev:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDtdev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer DtDev for DtDev.

    create query vhttquery.
    vhttBuffer = ghttDtdev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDtdev:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create DtDev.
            if not outils:copyValidField(buffer DtDev:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDtdev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNodev    as handle  no-undo.
    define variable vhNoint    as handle  no-undo.
    define buffer DtDev for DtDev.

    create query vhttquery.
    vhttBuffer = ghttDtdev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDtdev:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNodev, output vhNoint).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DtDev exclusive-lock
                where rowid(Dtdev) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DtDev:handle, 'NoDev/NoInt: ', substitute('&1/&2', vhNodev:buffer-value(), vhNoint:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete DtDev no-error.
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

