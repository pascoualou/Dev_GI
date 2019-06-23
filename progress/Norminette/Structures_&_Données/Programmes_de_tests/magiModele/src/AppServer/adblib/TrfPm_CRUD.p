/*------------------------------------------------------------------------
File        : trfpm_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table trfpm
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghtttrfpm as handle no-undo.     // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTptrf as handle, output phTpapp as handle, output phNomdt as handle, output phNoexe as handle, output phNoapp as handle, output phDtapp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tptrf/tpapp/nomdt/noexe/noapp/dtapp, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tptrf' then phTptrf = phBuffer:buffer-field(vi).
            when 'tpapp' then phTpapp = phBuffer:buffer-field(vi).
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
    Purpose: Lecture d'un enregistrement de la table trfpm 
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
    define buffer trfpm for trfpm.

    vhttBuffer = phttTrfpm:default-buffer-handle.
    for first trfpm no-lock
        where trfpm.tptrf = pcTptrf
          and trfpm.tpapp = pcTpapp
          and trfpm.nomdt = piNomdt
          and trfpm.noexe = piNoexe
          and trfpm.noapp = piNoapp
          and trfpm.dtapp = pdaDtapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trfpm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrfpm no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTrfpm:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table trfpm 
    Notes  : service externe. Critère piNoapp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTptrf as character  no-undo.
    define input parameter pcTpapp as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoexe as integer    no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter table-handle phttTrfpm.
    define variable vhttBuffer as handle  no-undo.
    define buffer trfpm for trfpm.

    vhttBuffer = phttTrfpm:default-buffer-handle.
    if piNoapp = ?
    then for each trfpm no-lock
        where trfpm.tptrf = pcTptrf
          and trfpm.tpapp = pcTpapp
          and trfpm.nomdt = piNomdt
          and trfpm.noexe = piNoexe:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trfpm:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each trfpm no-lock
        where trfpm.tptrf = pcTptrf
          and trfpm.tpapp = pcTpapp
          and trfpm.nomdt = piNomdt
          and trfpm.noexe = piNoexe
          and trfpm.noapp = piNoapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trfpm:handle, vhttBuffer).  // copy table physique vers temp-table
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
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTptrf    as handle  no-undo.
    define variable vhTpapp    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoexe    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhDtapp    as handle  no-undo.
    define buffer trfpm for trfpm.

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

            find first trfpm exclusive-lock
                where rowid(trfpm) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trfpm:handle, 'tptrf/tpapp/nomdt/noexe/noapp/dtapp: ', substitute('&1/&2/&3/&4/&5/&6', vhTptrf:buffer-value(), vhTpapp:buffer-value(), vhNomdt:buffer-value(), vhNoexe:buffer-value(), vhNoapp:buffer-value(), vhDtapp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer trfpm:handle, vhttBuffer, "U", mtoken:cUser)
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
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer trfpm for trfpm.

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

            create trfpm.
            if not outils:copyValidField(buffer trfpm:handle, vhttBuffer, "C", mtoken:cUser)
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
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTptrf    as handle  no-undo.
    define variable vhTpapp    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoexe    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhDtapp    as handle  no-undo.
    define buffer trfpm for trfpm.

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

            find first trfpm exclusive-lock
                where rowid(Trfpm) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trfpm:handle, 'tptrf/tpapp/nomdt/noexe/noapp/dtapp: ', substitute('&1/&2/&3/&4/&5/&6', vhTptrf:buffer-value(), vhTpapp:buffer-value(), vhNomdt:buffer-value(), vhNoexe:buffer-value(), vhNoapp:buffer-value(), vhDtapp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete trfpm no-error.
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

procedure deleteTrfpmSurMandat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer no-undo.
    
    define buffer trfpm for trfpm.

message "deleteTrfpmSurMandat "  piNumeroMandat.

blocTrans:
    do transaction:
        for each trfpm no-lock
           where trfpm.nomdt = piNumeroMandat:
            find current trfpm exclusive-lock.   
            delete trfpm no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
