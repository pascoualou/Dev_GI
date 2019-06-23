/*------------------------------------------------------------------------
File        : TrfPm_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table TrfPm
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/TrfPm.i}
{application/include/error.i}
define variable ghttTrfPm as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTptrf as handle, output phTpapp as handle, output phNomdt as handle, output phNoexe as handle, output phNoapp as handle, output phDtapp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur TpTrf/TpApp/nomdt/noexe/noapp/dtapp, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'TpTrf' then phTptrf = phBuffer:buffer-field(vi).
            when 'TpApp' then phTpapp = phBuffer:buffer-field(vi).
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'noexe' then phNoexe = phBuffer:buffer-field(vi).
            when 'noapp' then phNoapp = phBuffer:buffer-field(vi).
            when 'dtapp' then phDtapp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTrfpm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTrfpm.
    run updateTrfpm.
    run createTrfpm.
end procedure.

procedure setTrfpm:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTrfpm.
    ghttTrfpm = phttTrfpm.
    run crudTrfpm.
    delete object phttTrfpm.
end procedure.

procedure readTrfpm:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table TrfPm 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTptrf as character  no-undo.
    define input parameter pcTpapp as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoexe as integer    no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter pdaDtapp as date       no-undo.
    define input parameter table-handle phttTrfpm.
    define variable vhttBuffer as handle no-undo.
    define buffer TrfPm for TrfPm.

    vhttBuffer = phttTrfpm:default-buffer-handle.
    for first TrfPm no-lock
        where TrfPm.TpTrf = pcTptrf
          and TrfPm.TpApp = pcTpapp
          and TrfPm.nomdt = piNomdt
          and TrfPm.noexe = piNoexe
          and TrfPm.noapp = piNoapp
          and TrfPm.dtapp = pdaDtapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer TrfPm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrfpm no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTrfpm:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table TrfPm 
    Notes  : service externe. Critère piNoapp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTptrf as character  no-undo.
    define input parameter pcTpapp as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoexe as integer    no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter table-handle phttTrfpm.
    define variable vhttBuffer as handle  no-undo.
    define buffer TrfPm for TrfPm.

    vhttBuffer = phttTrfpm:default-buffer-handle.
    if piNoapp = ?
    then for each TrfPm no-lock
        where TrfPm.TpTrf = pcTptrf
          and TrfPm.TpApp = pcTpapp
          and TrfPm.nomdt = piNomdt
          and TrfPm.noexe = piNoexe:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer TrfPm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each TrfPm no-lock
        where TrfPm.TpTrf = pcTptrf
          and TrfPm.TpApp = pcTpapp
          and TrfPm.nomdt = piNomdt
          and TrfPm.noexe = piNoexe
          and TrfPm.noapp = piNoapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer TrfPm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrfpm no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTrfpm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTptrf    as handle  no-undo.
    define variable vhTpapp    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoexe    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhDtapp    as handle  no-undo.
    define buffer TrfPm for TrfPm.

    create query vhttquery.
    vhttBuffer = ghttTrfpm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTrfpm:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTptrf, output vhTpapp, output vhNomdt, output vhNoexe, output vhNoapp, output vhDtapp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first TrfPm exclusive-lock
                where rowid(TrfPm) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer TrfPm:handle, 'TpTrf/TpApp/nomdt/noexe/noapp/dtapp: ', substitute('&1/&2/&3/&4/&5/&6', vhTptrf:buffer-value(), vhTpapp:buffer-value(), vhNomdt:buffer-value(), vhNoexe:buffer-value(), vhNoapp:buffer-value(), vhDtapp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer TrfPm:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTrfpm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer TrfPm for TrfPm.

    create query vhttquery.
    vhttBuffer = ghttTrfpm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTrfpm:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create TrfPm.
            if not outils:copyValidField(buffer TrfPm:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTrfpm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTptrf    as handle  no-undo.
    define variable vhTpapp    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoexe    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhDtapp    as handle  no-undo.
    define buffer TrfPm for TrfPm.

    create query vhttquery.
    vhttBuffer = ghttTrfpm:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTrfpm:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTptrf, output vhTpapp, output vhNomdt, output vhNoexe, output vhNoapp, output vhDtapp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first TrfPm exclusive-lock
                where rowid(Trfpm) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer TrfPm:handle, 'TpTrf/TpApp/nomdt/noexe/noapp/dtapp: ', substitute('&1/&2/&3/&4/&5/&6', vhTptrf:buffer-value(), vhTpapp:buffer-value(), vhNomdt:buffer-value(), vhNoexe:buffer-value(), vhNoapp:buffer-value(), vhDtapp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete TrfPm no-error.
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

