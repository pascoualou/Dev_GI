/*------------------------------------------------------------------------
File        : gadet_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table gadet
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/09/13 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttgadet as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phTpidt as handle, output phNoidt as handle, output phAgence as handle, output phNotac as handle, output phNoord as handle, output phNolig as handle, output phTpctt as handle, output phNoctt as handle, output phTpct1 as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpidt/noidt/agence/notac/noord/nolig/tpctt/noctt/tpct1/noct1/tpct2/noct2, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpidt'  then phTpidt  = phBuffer:buffer-field(vi).
            when 'noidt'  then phNoidt  = phBuffer:buffer-field(vi).
            when 'agence' then phAgence = phBuffer:buffer-field(vi).
            when 'notac'  then phNotac  = phBuffer:buffer-field(vi).
            when 'noord'  then phNoord  = phBuffer:buffer-field(vi).
            when 'nolig'  then phNolig  = phBuffer:buffer-field(vi).
            when 'tpctt'  then phTpctt  = phBuffer:buffer-field(vi).
            when 'noctt'  then phNoctt  = phBuffer:buffer-field(vi).
            when 'tpct1'  then phTpct1  = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudGadet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteGadet.
    run updateGadet.
    run createGadet.
end procedure.

procedure setGadet:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttGadet.
    ghttGadet = phttGadet.
    run crudGadet.
    delete object phttGadet.
end procedure.

procedure readGadet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table gadet 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt  as character no-undo.
    define input parameter piNoidt  as int64     no-undo.
    define input parameter piAgence as integer   no-undo.
    define input parameter piNotac  as integer   no-undo.
    define input parameter piNoord  as integer   no-undo.
    define input parameter piNolig  as integer   no-undo.
    define input parameter pcTpctt  as character no-undo.
    define input parameter pdeNoctt as decimal   no-undo.
    define input parameter pcTpct1  as character no-undo.
    define input parameter table-handle phttGadet.

    define variable vhttBuffer as handle no-undo.
    define buffer gadet for gadet.

    vhttBuffer = phttGadet:default-buffer-handle.
    for first gadet no-lock
        where gadet.tpidt = pcTpidt
          and gadet.noidt = piNoidt
          and gadet.agence = piAgence
          and gadet.notac = piNotac
          and gadet.noord = piNoord
          and gadet.nolig = piNolig
          and gadet.tpctt = pcTpctt
          and gadet.noctt = pdeNoctt
          and gadet.tpct1 = pcTpct1:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer gadet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGadet no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getGadet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table gadet 
    Notes  : service externe. Critère pcTpct1 = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt  as character no-undo.
    define input parameter piNoidt  as int64     no-undo.
    define input parameter piAgence as integer   no-undo.
    define input parameter piNotac  as integer   no-undo.
    define input parameter piNoord  as integer   no-undo.
    define input parameter piNolig  as integer   no-undo.
    define input parameter pcTpctt  as character no-undo.
    define input parameter pdeNoctt as decimal   no-undo.
    define input parameter pcTpct1  as character no-undo.
    define input parameter table-handle phttGadet.

    define variable vhttBuffer as handle  no-undo.
    define buffer gadet for gadet.

    vhttBuffer = phttGadet:default-buffer-handle.
    if pcTpct1 = ?
    then for each gadet no-lock
        where gadet.tpidt = pcTpidt
          and gadet.noidt = piNoidt
          and gadet.agence = piAgence
          and gadet.notac = piNotac
          and gadet.noord = piNoord
          and gadet.nolig = piNolig
          and gadet.tpctt = pcTpctt
          and gadet.noctt = pdeNoctt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer gadet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each gadet no-lock
        where gadet.tpidt = pcTpidt
          and gadet.noidt = piNoidt
          and gadet.agence = piAgence
          and gadet.notac = piNotac
          and gadet.noord = piNoord
          and gadet.nolig = piNolig
          and gadet.tpctt = pcTpctt
          and gadet.noctt = pdeNoctt
          and gadet.tpct1 = pcTpct1:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer gadet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttGadet no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateGadet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define variable vhAgence   as handle  no-undo.
    define variable vhNotac    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define variable vhTpctt    as handle  no-undo.
    define variable vhNoctt    as handle  no-undo.
    define variable vhTpct1    as handle  no-undo.
    define buffer gadet for gadet.

    create query vhttquery.
    vhttBuffer = ghttGadet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttGadet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt, output vhAgence, output vhNotac, output vhNoord, output vhNolig, output vhTpctt, output vhNoctt, output vhTpct1).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first gadet exclusive-lock
                where rowid(gadet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer gadet:handle, 'tpidt/noidt/agence/notac/noord/nolig/tpctt/noctt/tpct1/noct1/tpct2/noct2: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhAgence:buffer-value(), vhNotac:buffer-value(), vhNoord:buffer-value(), vhNolig:buffer-value(), vhTpctt:buffer-value(), vhNoctt:buffer-value(), vhTpct1:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer gadet:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createGadet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer gadet for gadet.

    create query vhttquery.
    vhttBuffer = ghttGadet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttGadet:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create gadet.
            if not outils:copyValidField(buffer gadet:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteGadet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define variable vhAgence   as handle  no-undo.
    define variable vhNotac    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define variable vhNolig    as handle  no-undo.
    define variable vhTpctt    as handle  no-undo.
    define variable vhNoctt    as handle  no-undo.
    define variable vhTpct1    as handle  no-undo.
    define buffer gadet for gadet.

    create query vhttquery.
    vhttBuffer = ghttGadet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttGadet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt, output vhAgence, output vhNotac, output vhNoord, output vhNolig, output vhTpctt, output vhNoctt, output vhTpct1).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first gadet exclusive-lock
                where rowid(Gadet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer gadet:handle, 'tpidt/noidt/agence/notac/noord/nolig/tpctt/noctt/tpct1/noct1/tpct2/noct2: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhAgence:buffer-value(), vhNotac:buffer-value(), vhNoord:buffer-value(), vhNolig:buffer-value(), vhTpctt:buffer-value(), vhNoctt:buffer-value(), vhTpct1:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete gadet no-error.
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

procedure deleteGadetSurContrat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter pdNumeroContrat as decimal   no-undo.
    
    define buffer gadet for gadet.

blocTrans:
    do transaction:
// whole-index corrige par la creation dans la version d'un index sur tpctt noctt
        for each gadet exclusive-lock   
            where gadet.tpctt = pcTypeContrat
              and gadet.noctt = pdNumeroContrat:
            delete gadet no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
