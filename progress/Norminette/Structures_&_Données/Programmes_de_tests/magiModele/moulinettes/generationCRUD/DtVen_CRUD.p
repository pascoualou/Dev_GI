/*------------------------------------------------------------------------
File        : DtVen_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table DtVen
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/DtVen.i}
{application/include/error.i}
define variable ghttDtVen as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNofac as handle, output phNoint as handle, output phNoord as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NoFac/NoInt/NoOrd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NoFac' then phNofac = phBuffer:buffer-field(vi).
            when 'NoInt' then phNoint = phBuffer:buffer-field(vi).
            when 'NoOrd' then phNoord = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudDtven private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDtven.
    run updateDtven.
    run createDtven.
end procedure.

procedure setDtven:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDtven.
    ghttDtven = phttDtven.
    run crudDtven.
    delete object phttDtven.
end procedure.

procedure readDtven:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table DtVen Chaine travaux : Ventil ana ligne facture
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNofac as integer    no-undo.
    define input parameter piNoint as int64      no-undo.
    define input parameter piNoord as integer    no-undo.
    define input parameter table-handle phttDtven.
    define variable vhttBuffer as handle no-undo.
    define buffer DtVen for DtVen.

    vhttBuffer = phttDtven:default-buffer-handle.
    for first DtVen no-lock
        where DtVen.NoFac = piNofac
          and DtVen.NoInt = piNoint
          and DtVen.NoOrd = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DtVen:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDtven no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDtven:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table DtVen Chaine travaux : Ventil ana ligne facture
    Notes  : service externe. Critère piNoint = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNofac as integer    no-undo.
    define input parameter piNoint as int64      no-undo.
    define input parameter table-handle phttDtven.
    define variable vhttBuffer as handle  no-undo.
    define buffer DtVen for DtVen.

    vhttBuffer = phttDtven:default-buffer-handle.
    if piNoint = ?
    then for each DtVen no-lock
        where DtVen.NoFac = piNofac:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DtVen:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each DtVen no-lock
        where DtVen.NoFac = piNofac
          and DtVen.NoInt = piNoint:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer DtVen:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDtven no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDtven private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNofac    as handle  no-undo.
    define variable vhNoint    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer DtVen for DtVen.

    create query vhttquery.
    vhttBuffer = ghttDtven:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDtven:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNofac, output vhNoint, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DtVen exclusive-lock
                where rowid(DtVen) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DtVen:handle, 'NoFac/NoInt/NoOrd: ', substitute('&1/&2/&3', vhNofac:buffer-value(), vhNoint:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer DtVen:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDtven private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer DtVen for DtVen.

    create query vhttquery.
    vhttBuffer = ghttDtven:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDtven:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create DtVen.
            if not outils:copyValidField(buffer DtVen:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDtven private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNofac    as handle  no-undo.
    define variable vhNoint    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer DtVen for DtVen.

    create query vhttquery.
    vhttBuffer = ghttDtven:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDtven:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNofac, output vhNoint, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first DtVen exclusive-lock
                where rowid(Dtven) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer DtVen:handle, 'NoFac/NoInt/NoOrd: ', substitute('&1/&2/&3', vhNofac:buffer-value(), vhNoint:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete DtVen no-error.
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

