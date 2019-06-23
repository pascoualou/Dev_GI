/*------------------------------------------------------------------------
File        : eprov_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table eprov
Author(s)   : generation automatique le 01/24/18 + SPo le 01/30/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}       // Doit être positionnée juste après using
{application/include/error.i}
define variable ghtteprov as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phTpctt as handle, output phNomdt as handle, output phNoexo as handle, output phNoloc as handle, output phCdrub as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpctt/nomdt/noexo/noloc/cdrub, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpctt' then phTpctt = phBuffer:buffer-field(vi).
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'noexo' then phNoexo = phBuffer:buffer-field(vi).
            when 'noloc' then phNoloc = phBuffer:buffer-field(vi).
            when 'cdrub' then phCdrub = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEprov private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEprov.
    run updateEprov.
    run createEprov.
end procedure.

procedure setEprov:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle vhttEprov.
    ghttEprov = vhttEprov.
    run crudEprov.
end procedure.

procedure readEprov:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table eprov Montant réel provisions quittancées
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpctt as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoexo as integer    no-undo.
    define input parameter piNoloc as int64      no-undo.
    define input parameter piCdrub as integer    no-undo.
    define input parameter table-handle phttEprov.
    define variable vhttBuffer as handle no-undo.
    define buffer eprov for eprov.

    vhttBuffer = phttEprov:default-buffer-handle.
    for first eprov no-lock
        where eprov.tpctt = pcTpctt
          and eprov.nomdt = piNomdt
          and eprov.noexo = piNoexo
          and eprov.noloc = piNoloc
          and eprov.cdrub = piCdrub:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer eprov:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEprov no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEprov:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table eprov Montant réel provisions quittancées
    Notes  : service externe. Critère piNoloc = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpctt as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoexo as integer    no-undo.
    define input parameter piNoloc as int64      no-undo.
    define input parameter table-handle phttEprov.
    define variable vhttBuffer as handle  no-undo.
    define buffer eprov for eprov.

    vhttBuffer = phttEprov:default-buffer-handle.
    if piNoloc = ?
    then for each eprov no-lock
        where eprov.tpctt = pcTpctt
          and eprov.nomdt = piNomdt
          and eprov.noexo = piNoexo:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer eprov:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each eprov no-lock
        where eprov.tpctt = pcTpctt
          and eprov.nomdt = piNomdt
          and eprov.noexo = piNoexo
          and eprov.noloc = piNoloc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer eprov:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEprov no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEprov private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpctt    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoexo    as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define variable vhCdrub    as handle  no-undo.
    define buffer eprov for eprov.

    create query vhttquery.
    vhttBuffer = ghttEprov:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEprov:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpctt, output vhNomdt, output vhNoexo, output vhNoloc, output vhCdrub).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first eprov exclusive-lock
                where rowid(eprov) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer eprov:handle, 'tpctt/nomdt/noexo/noloc/cdrub: ', substitute('&1/&2/&3/&4/&5', vhTpctt:buffer-value(), vhNomdt:buffer-value(), vhNoexo:buffer-value(), vhNoloc:buffer-value(), vhCdrub:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer eprov:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEprov private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer eprov for eprov.

    create query vhttquery.
    vhttBuffer = ghttEprov:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEprov:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create eprov.
            if not outils:copyValidField(buffer eprov:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEprov private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpctt    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoexo    as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define variable vhCdrub    as handle  no-undo.
    define buffer eprov for eprov.

    create query vhttquery.
    vhttBuffer = ghttEprov:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEprov:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpctt, output vhNomdt, output vhNoexo, output vhNoloc, output vhCdrub).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first eprov exclusive-lock
                where rowid(Eprov) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer eprov:handle, 'tpctt/nomdt/noexo/noloc/cdrub: ', substitute('&1/&2/&3/&4/&5', vhTpctt:buffer-value(), vhNomdt:buffer-value(), vhNoexo:buffer-value(), vhNoloc:buffer-value(), vhCdrub:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete eprov no-error.
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

procedure deleteEprovSurLocataire:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroLocataire as int64 no-undo.
    
    define buffer eprov for eprov.

message "deleteEprovSurLocataire "  piNumeroLocataire.

blocTrans:
    do transaction:
        for each eprov no-lock   
           where eprov.noloc = piNumeroLocataire:
            find current eprov exclusive-lock.    
            delete eprov no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

procedure deleteEprovSurMandat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat   as character no-undo.
    define input parameter piNumeroMandat as integer no-undo.
    
    define buffer eprov for eprov.

message "deleteEprovSurMandat "  pcTypeMandat "// " piNumeroMandat.

blocTrans:
    do transaction:
        for each eprov exclusive-lock
           where eprov.tpctt = pcTypeMandat
             and eprov.nomdt = piNumeroMandat:
            delete eprov no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
