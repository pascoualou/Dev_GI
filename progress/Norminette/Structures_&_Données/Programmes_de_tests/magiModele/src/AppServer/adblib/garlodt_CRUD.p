/*------------------------------------------------------------------------
File        : garlodt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table garlodt
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttgarlodt as handle no-undo.     // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpgar as handle, output phNogar as handle, output phMsqtt as handle, output phTpmdt as handle, output phNomdt as handle, output phTprol as handle, output phNorol as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpgar/nogar/msqtt/tpmdt/nomdt/tprol/norol, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpgar' then phTpgar = phBuffer:buffer-field(vi).
            when 'nogar' then phNogar = phBuffer:buffer-field(vi).
            when 'msqtt' then phMsqtt = phBuffer:buffer-field(vi).
            when 'tpmdt' then phTpmdt = phBuffer:buffer-field(vi).
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'tprol' then phTprol = phBuffer:buffer-field(vi).
            when 'norol' then phNorol = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGarlodt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGarlodt.
    run updateGarlodt.
    run createGarlodt.
end procedure.

procedure setGarlodt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGarlodt.
    ghttGarlodt = phttGarlodt.
    run crudGarlodt.
    delete object phttGarlodt.
end procedure.

procedure readGarlodt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table garlodt 0808/0042 - Garantie loyer calculÃ©e par locataire
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpgar as character  no-undo.
    define input parameter piNogar as integer    no-undo.
    define input parameter piMsqtt as integer    no-undo.
    define input parameter pcTpmdt as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter pcTprol as character  no-undo.
    define input parameter pdeNorol as decimal    no-undo.
    define input parameter table-handle phttGarlodt.
    define variable vhttBuffer as handle no-undo.
    define buffer garlodt for garlodt.

    vhttBuffer = phttGarlodt:default-buffer-handle.
    for first garlodt no-lock
        where garlodt.tpgar = pcTpgar
          and garlodt.nogar = piNogar
          and garlodt.msqtt = piMsqtt
          and garlodt.tpmdt = pcTpmdt
          and garlodt.nomdt = piNomdt
          and garlodt.tprol = pcTprol
          and garlodt.norol = pdeNorol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer garlodt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGarlodt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGarlodt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table garlodt 0808/0042 - Garantie loyer calculÃ©e par locataire
    Notes  : service externe. Critère pcTprol = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpgar as character  no-undo.
    define input parameter piNogar as integer    no-undo.
    define input parameter piMsqtt as integer    no-undo.
    define input parameter pcTpmdt as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter pcTprol as character  no-undo.
    define input parameter table-handle phttGarlodt.
    define variable vhttBuffer as handle  no-undo.
    define buffer garlodt for garlodt.

    vhttBuffer = phttGarlodt:default-buffer-handle.
    if pcTprol = ?
    then for each garlodt no-lock
        where garlodt.tpgar = pcTpgar
          and garlodt.nogar = piNogar
          and garlodt.msqtt = piMsqtt
          and garlodt.tpmdt = pcTpmdt
          and garlodt.nomdt = piNomdt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer garlodt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each garlodt no-lock
        where garlodt.tpgar = pcTpgar
          and garlodt.nogar = piNogar
          and garlodt.msqtt = piMsqtt
          and garlodt.tpmdt = pcTpmdt
          and garlodt.nomdt = piNomdt
          and garlodt.tprol = pcTprol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer garlodt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGarlodt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGarlodt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpgar    as handle  no-undo.
    define variable vhNogar    as handle  no-undo.
    define variable vhMsqtt    as handle  no-undo.
    define variable vhTpmdt    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define buffer garlodt for garlodt.

    create query vhttquery.
    vhttBuffer = ghttGarlodt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGarlodt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpgar, output vhNogar, output vhMsqtt, output vhTpmdt, output vhNomdt, output vhTprol, output vhNorol).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first garlodt exclusive-lock
                where rowid(garlodt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer garlodt:handle, 'tpgar/nogar/msqtt/tpmdt/nomdt/tprol/norol: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhTpgar:buffer-value(), vhNogar:buffer-value(), vhMsqtt:buffer-value(), vhTpmdt:buffer-value(), vhNomdt:buffer-value(), vhTprol:buffer-value(), vhNorol:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer garlodt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGarlodt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer garlodt for garlodt.

    create query vhttquery.
    vhttBuffer = ghttGarlodt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGarlodt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create garlodt.
            if not outils:copyValidField(buffer garlodt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGarlodt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpgar    as handle  no-undo.
    define variable vhNogar    as handle  no-undo.
    define variable vhMsqtt    as handle  no-undo.
    define variable vhTpmdt    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define buffer garlodt for garlodt.

    create query vhttquery.
    vhttBuffer = ghttGarlodt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGarlodt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpgar, output vhNogar, output vhMsqtt, output vhTpmdt, output vhNomdt, output vhTprol, output vhNorol).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first garlodt exclusive-lock
                where rowid(Garlodt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer garlodt:handle, 'tpgar/nogar/msqtt/tpmdt/nomdt/tprol/norol: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhTpgar:buffer-value(), vhNogar:buffer-value(), vhMsqtt:buffer-value(), vhTpmdt:buffer-value(), vhNomdt:buffer-value(), vhTprol:buffer-value(), vhNorol:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete garlodt no-error.
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

procedure deleteGarlodtSurLocataire:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeRole        as character no-undo.
    define input parameter piNumeroLocataire as decimal   no-undo.

    define buffer garlodt for garlodt.

blocTrans:
    do transaction:
        for each garlodt no-lock 
            where garlodt.tprol = pcTypeRole
              and garlodt.norol = piNumeroLocataire:
            find current garlodt exclusive-lock.        
            delete garlodt no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status
    
end procedure.

procedure deleteGarlodtSurMandat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat   as character no-undo.
    define input parameter piNumeroMandat as integer   no-undo.

    define buffer garlodt for garlodt.

blocTrans:
    do transaction:
        for each garlodt exclusive-lock 
           where garlodt.tpmdt = pcTypeMandat
             and garlodt.nomdt = piNumeroMandat:
            delete garlodt no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
