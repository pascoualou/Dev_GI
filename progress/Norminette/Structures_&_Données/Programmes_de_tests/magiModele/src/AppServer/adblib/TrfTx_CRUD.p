/*------------------------------------------------------------------------
File        : trftx_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table trftx
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghtttrftx as handle no-undo.     // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTptrf as handle, output phTpapp as handle, output phTptxt as handle, output phNomdt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tptrf/tpapp/tptxt/nomdt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tptrf' then phTptrf = phBuffer:buffer-field(vi).
            when 'tpapp' then phTpapp = phBuffer:buffer-field(vi).
            when 'tptxt' then phTptxt = phBuffer:buffer-field(vi).
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTrftx private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTrftx.
    run updateTrftx.
    run createTrftx.
end procedure.

procedure setTrftx:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTrftx.
    ghttTrftx = phttTrftx.
    run crudTrftx.
    delete object phttTrftx.
end procedure.

procedure readTrftx:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table trftx 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTptrf as character  no-undo.
    define input parameter pcTpapp as character  no-undo.
    define input parameter pcTptxt as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter table-handle phttTrftx.
    define variable vhttBuffer as handle no-undo.
    define buffer trftx for trftx.

    vhttBuffer = phttTrftx:default-buffer-handle.
    for first trftx no-lock
        where trftx.tptrf = pcTptrf
          and trftx.tpapp = pcTpapp
          and trftx.tptxt = pcTptxt
          and trftx.nomdt = piNomdt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trftx:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrftx no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTrftx:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table trftx 
    Notes  : service externe. Critère pcTptxt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTptrf as character  no-undo.
    define input parameter pcTpapp as character  no-undo.
    define input parameter pcTptxt as character  no-undo.
    define input parameter table-handle phttTrftx.
    define variable vhttBuffer as handle  no-undo.
    define buffer trftx for trftx.

    vhttBuffer = phttTrftx:default-buffer-handle.
    if pcTptxt = ?
    then for each trftx no-lock
        where trftx.tptrf = pcTptrf
          and trftx.tpapp = pcTpapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trftx:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each trftx no-lock
        where trftx.tptrf = pcTptrf
          and trftx.tpapp = pcTpapp
          and trftx.tptxt = pcTptxt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer trftx:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTrftx no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTrftx private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTptrf    as handle  no-undo.
    define variable vhTpapp    as handle  no-undo.
    define variable vhTptxt    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define buffer trftx for trftx.

    create query vhttquery.
    vhttBuffer = ghttTrftx:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTrftx:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTptrf, output vhTpapp, output vhTptxt, output vhNomdt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first trftx exclusive-lock
                where rowid(trftx) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trftx:handle, 'tptrf/tpapp/tptxt/nomdt: ', substitute('&1/&2/&3/&4', vhTptrf:buffer-value(), vhTpapp:buffer-value(), vhTptxt:buffer-value(), vhNomdt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer trftx:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTrftx private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer trftx for trftx.

    create query vhttquery.
    vhttBuffer = ghttTrftx:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTrftx:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create trftx.
            if not outils:copyValidField(buffer trftx:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTrftx private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTptrf    as handle  no-undo.
    define variable vhTpapp    as handle  no-undo.
    define variable vhTptxt    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define buffer trftx for trftx.

    create query vhttquery.
    vhttBuffer = ghttTrftx:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTrftx:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTptrf, output vhTpapp, output vhTptxt, output vhNomdt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first trftx exclusive-lock
                where rowid(Trftx) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer trftx:handle, 'tptrf/tpapp/tptxt/nomdt: ', substitute('&1/&2/&3/&4', vhTptrf:buffer-value(), vhTpapp:buffer-value(), vhTptxt:buffer-value(), vhNomdt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete trftx no-error.
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

procedure deleteTrftxSurMandat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer no-undo.
    
    define buffer trftx for trftx.

message "deleteTrftxSurMandat "  piNumeroMandat.

blocTrans:
    do transaction:
        for each trftx no-lock
           where trftx.nomdt = piNumeroMandat:
            find current trftx exclusive-lock.   
            delete trftx no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
