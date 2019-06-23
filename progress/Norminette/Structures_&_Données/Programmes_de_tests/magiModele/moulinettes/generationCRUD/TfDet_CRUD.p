/*------------------------------------------------------------------------
File        : TfDet_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table TfDet
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/TfDet.i}
{application/include/error.i}
define variable ghttTfDet as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoimm as handle, output phDtrev as handle, output phIdlot as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NoImm/DtRev/IdLot, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NoImm' then phNoimm = phBuffer:buffer-field(vi).
            when 'DtRev' then phDtrev = phBuffer:buffer-field(vi).
            when 'IdLot' then phIdlot = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTfdet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTfdet.
    run updateTfdet.
    run createTfdet.
end procedure.

procedure setTfdet:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTfdet.
    ghttTfdet = phttTfdet.
    run crudTfdet.
    delete object phttTfdet.
end procedure.

procedure readTfdet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table TfDet 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer    no-undo.
    define input parameter pdaDtrev as date       no-undo.
    define input parameter pcIdlot as character  no-undo.
    define input parameter table-handle phttTfdet.
    define variable vhttBuffer as handle no-undo.
    define buffer TfDet for TfDet.

    vhttBuffer = phttTfdet:default-buffer-handle.
    for first TfDet no-lock
        where TfDet.NoImm = piNoimm
          and TfDet.DtRev = pdaDtrev
          and TfDet.IdLot = pcIdlot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer TfDet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTfdet no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTfdet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table TfDet 
    Notes  : service externe. Critère pdaDtrev = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer    no-undo.
    define input parameter pdaDtrev as date       no-undo.
    define input parameter table-handle phttTfdet.
    define variable vhttBuffer as handle  no-undo.
    define buffer TfDet for TfDet.

    vhttBuffer = phttTfdet:default-buffer-handle.
    if pdaDtrev = ?
    then for each TfDet no-lock
        where TfDet.NoImm = piNoimm:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer TfDet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each TfDet no-lock
        where TfDet.NoImm = piNoimm
          and TfDet.DtRev = pdaDtrev:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer TfDet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTfdet no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTfdet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhDtrev    as handle  no-undo.
    define variable vhIdlot    as handle  no-undo.
    define buffer TfDet for TfDet.

    create query vhttquery.
    vhttBuffer = ghttTfdet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTfdet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm, output vhDtrev, output vhIdlot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first TfDet exclusive-lock
                where rowid(TfDet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer TfDet:handle, 'NoImm/DtRev/IdLot: ', substitute('&1/&2/&3', vhNoimm:buffer-value(), vhDtrev:buffer-value(), vhIdlot:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer TfDet:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTfdet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer TfDet for TfDet.

    create query vhttquery.
    vhttBuffer = ghttTfdet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTfdet:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create TfDet.
            if not outils:copyValidField(buffer TfDet:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTfdet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhDtrev    as handle  no-undo.
    define variable vhIdlot    as handle  no-undo.
    define buffer TfDet for TfDet.

    create query vhttquery.
    vhttBuffer = ghttTfdet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTfdet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm, output vhDtrev, output vhIdlot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first TfDet exclusive-lock
                where rowid(Tfdet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer TfDet:handle, 'NoImm/DtRev/IdLot: ', substitute('&1/&2/&3', vhNoimm:buffer-value(), vhDtrev:buffer-value(), vhIdlot:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete TfDet no-error.
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

