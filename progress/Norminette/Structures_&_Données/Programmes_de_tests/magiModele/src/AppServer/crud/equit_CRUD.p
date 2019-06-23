/*------------------------------------------------------------------------
File        : equit_CRUD.p
Purpose     : 
Author(s)   :  - 2017/12/22
Notes       : reprise de L_Equit_ext.p
derniere revue: 2018/08/14 - phm: 
------------------------------------------------------------------------*/
{preprocesseur/nature2contrat.i}
{preprocesseur/type2contrat.i}
{preprocesseur/param2locataire.i}
using parametre.pclie.parametrageFournisseurLoyer.
using parametre.pclie.parametrageComptabilisationEchus.

{oerealm/include/instanciateTokenOnModel.i}       // Doit être positionnée juste après using
define variable ghttequit as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phNoloc as handle, output phNoqtt as handle, output phNoint as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noint, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noloc' then phNoloc = phBuffer:buffer-field(vi).
            when 'noqtt' then phNoqtt = phBuffer:buffer-field(vi).
            when 'noint' then phNoint = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEquit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEquit.
    run updateEquit.
    run createEquit.
end procedure.

procedure setEquit:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEquit.
    ghttEquit = phttEquit.
    run crudEquit.
    delete object phttEquit.
end procedure.

/**** npo ancien code en attente de suppression
procedure readEquit:
    /*------------------------------------------------------------------------------
    Purpose: Procedure Qui recupere un enregistrement de la table equit
    Notes  : service utilisé par ???
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroLocataire     as integer no-undo.
    define input parameter piNumeroQuittance     as integer no-undo.
    define input parameter piNumeroMoisQuittance as integer no-undo.
    define output parameter table for ttEquit.

    define buffer equit for equit.

    /* Si NoQttSel <> 0 : On Recherche sur le numero 
       Sinon  sur le mois de quittancement */
    if (piNumeroQuittance <> ? and piNumeroMoisQuittance <> 0) 
    then find first equit no-lock
        where equit.noloc = piNumeroLocataire
          and equit.noqtt = piNumeroQuittance no-error.
    else find first equit no-lock
             where equit.noloc = piNumeroLocataire
               and equit.msqtt = piNumeroQuittance no-error.
    if not available equit then return.

    create ttEquit.
    outils:copyValidField(buffer equit:handle, buffer ttEquit:handle).

end procedure.
****/
procedure readEquit:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table equit 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoloc as int64    no-undo.
    define input parameter piNoqtt as integer  no-undo.
    define input parameter table-handle phttEquit.

    define variable vhttBuffer as handle no-undo.
    define buffer equit for equit.

    vhttBuffer = phttEquit:default-buffer-handle.
    for first equit no-lock
        where equit.noloc = piNoloc
          and equit.noqtt = piNoqtt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer equit:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEquit no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEquit:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table equit 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter piNoloc as int64    no-undo.
    define input parameter piNoqtt as integer  no-undo.
    define input parameter table-handle phttEquit.

    define variable vhttBuffer as handle  no-undo.
    define buffer equit for equit.

    vhttBuffer = phttEquit:default-buffer-handle.
    if piNoqtt = ?
    then for each equit no-lock
        where equit.noloc = piNoloc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer equit:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each equit no-lock
        where equit.noloc = piNoloc
          and equit.noqtt = piNoqtt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer equit:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEquit no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEquit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define variable vhNoqtt    as handle  no-undo.
    define variable vhNoint    as handle  no-undo.
    define buffer equit for equit.

    create query vhttquery.
    vhttBuffer = ghttEquit:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEquit:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoloc, output vhNoqtt, output vhNoint).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first equit exclusive-lock
                where rowid(equit) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer equit:handle, 'noloc/noqtt: ', substitute('&1/&2', vhNoloc:buffer-value(), vhNoqtt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer equit:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEquit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define variable vhNoqtt    as handle  no-undo.
    define variable vhNoint    as handle  no-undo.
    define variable viNoint    as int64   no-undo.
    
    define buffer equit for equit.

    create query vhttquery.
    vhttBuffer = ghttEquit:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEquit:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoloc, output vhNoqtt, output vhNoint).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            run getNextNoInt(output viNoint).
            vhNoint:buffer-value() = viNoint.
            
            create equit.
            if not outils:copyValidField(buffer equit:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEquit private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define variable vhNoqtt    as handle  no-undo.
    define variable vhNoint    as handle  no-undo.
    define buffer equit for equit.

    create query vhttquery.
    vhttBuffer = ghttEquit:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEquit:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoloc, output vhNoqtt, output vhNoint).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first equit exclusive-lock
                where rowid(Equit) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer equit:handle, 'noloc/noqtt: ', substitute('&1/&2', vhNoloc:buffer-value(), vhNoqtt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete equit no-error.
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

procedure deleteEquitSurMandat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer no-undo.
    
    define buffer equit for equit.

blocTrans:
    do transaction:
        // whole-index corrige par la creation dans la version d'un index sur nomdt
        for each equit exclusive-lock
            where equit.nomdt = piNumeroMandat:
            delete equit no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.            
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

procedure deleteEquitSurLocataire:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroLocataire as int64 no-undo.
    
    define buffer equit for equit.

blocTrans:
    do transaction:
        for each equit exclusive-lock
            where equit.noloc = piNumeroLocataire:
            delete equit no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.            
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

procedure getNextNoInt private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  :
    ------------------------------------------------------------------------------*/
    define output parameter piNextNoInt as int64 no-undo init 1.

    define buffer equit for equit.

    for last equit no-lock:
        piNextNoInt = equit.noint + 1.
    end.

end procedure.
