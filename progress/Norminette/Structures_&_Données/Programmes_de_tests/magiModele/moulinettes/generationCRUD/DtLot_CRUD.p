/*------------------------------------------------------------------------
File        : DtLot_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table DtLot
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/DtLot.i}
{application/include/error.i}
define variable ghttDtLot as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTptrt as handle, output phNotrt as handle, output phNoloc as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur TpTrt/NoTrt/NoLoc, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'TpTrt' then phTptrt = phBuffer:buffer-field(vi).
            when 'NoTrt' then phNotrt = phBuffer:buffer-field(vi).
            when 'NoLoc' then phNoloc = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudDtlot private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDtlot.
    run updateDtlot.
    run createDtlot.
end procedure.

procedure setDtlot:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDtlot.
    ghttDtlot = phttDtlot.
    run crudDtlot.
    delete object phttDtlot.
end procedure.

procedure readDtlot:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table DtLot Chaine Travaux : Table des Lots des Travaux
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTptrt as character  no-undo.
    define input parameter piNotrt as integer    no-undo.
    define input parameter piNoloc as integer    no-undo.
    define input parameter table-handle phttDtlot.
    define variable vhttBuffer as handle no-undo.
    define buffer DtLot for DtLot.

    vhttBuffer = phttDtlot:default-buffer-handle.
    for first DtLot no-lock
        where DtLot.TpTrt = pcTptrt
          and DtLot.NoTrt = piNotrt
          and DtLot.NoLoc = piNoloc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DtLot:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDtlot no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDtlot:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table DtLot Chaine Travaux : Table des Lots des Travaux
    Notes  : service externe. Critère piNotrt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTptrt as character  no-undo.
    define input parameter piNotrt as integer    no-undo.
    define input parameter table-handle phttDtlot.
    define variable vhttBuffer as handle  no-undo.
    define buffer DtLot for DtLot.

    vhttBuffer = phttDtlot:default-buffer-handle.
    if piNotrt = ?
    then for each DtLot no-lock
        where DtLot.TpTrt = pcTptrt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DtLot:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each DtLot no-lock
        where DtLot.TpTrt = pcTptrt
          and DtLot.NoTrt = piNotrt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DtLot:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDtlot no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDtlot private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTptrt    as handle  no-undo.
    define variable vhNotrt    as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define buffer DtLot for DtLot.

    create query vhttquery.
    vhttBuffer = ghttDtlot:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDtlot:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTptrt, output vhNotrt, output vhNoloc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DtLot exclusive-lock
                where rowid(DtLot) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DtLot:handle, 'TpTrt/NoTrt/NoLoc: ', substitute('&1/&2/&3', vhTptrt:buffer-value(), vhNotrt:buffer-value(), vhNoloc:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer DtLot:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDtlot private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer DtLot for DtLot.

    create query vhttquery.
    vhttBuffer = ghttDtlot:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDtlot:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create DtLot.
            if not outils:copyValidField(buffer DtLot:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDtlot private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTptrt    as handle  no-undo.
    define variable vhNotrt    as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define buffer DtLot for DtLot.

    create query vhttquery.
    vhttBuffer = ghttDtlot:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDtlot:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTptrt, output vhNotrt, output vhNoloc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DtLot exclusive-lock
                where rowid(Dtlot) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DtLot:handle, 'TpTrt/NoTrt/NoLoc: ', substitute('&1/&2/&3', vhTptrt:buffer-value(), vhNotrt:buffer-value(), vhNoloc:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete DtLot no-error.
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

