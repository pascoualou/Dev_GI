/*------------------------------------------------------------------------
File        : tache.p
Purpose     :
Author(s)   : kantena - 2016/12/08
                      - 2017/07/03 suppression l_tache_ext.p
Notes       :
              13/10/2017  npo  #7589 add valeur etiquette nrj et climat
              16/10/2017  npo  #7791 modif  iVolume -> cVolume + add cNumero
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2bien.i}

using parametre.pclie.parametrageDefautBail.
using parametre.pclie.parametrageDefautMandat.
{oerealm/include/instanciateTokenOnModel.i}       /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{tache/include/tache.i}
define variable ghtttache as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(
    phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phTptac as handle, output phNotac as handle, output phNoita as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noita, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'tptac' then phTptac = phBuffer:buffer-field(vi).
            when 'notac' then phNotac = phBuffer:buffer-field(vi).
            when 'noita' then phNoita = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTache private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : deux numero de tache noita: séquence et notac: numero de tache
    ------------------------------------------------------------------------------*/
    run deleteTache.
    run updateTache.
    run createTache.
end procedure.

procedure setTache:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (appel depuis les differents pgms de maintenance tache)
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTache.
    ghttTache = phttTache.
    run crudTache.
    delete object phttTache.
end procedure.

procedure readTache:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par genoffqt.p, calrevlo.p
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as integer   no-undo.
    define input parameter pcTypeTache     as character no-undo.
    define input parameter piNumeroTache   as integer   no-undo.
    define input parameter table-handle phttTache.

    define variable vhttBuffer as handle no-undo.
    define buffer tache for tache.

    vhttBuffer = phttTache:default-buffer-handle.
    {&_proparse_ prolint-nowarn(noeffect)}
    integer(pcTypeTache) no-error.
    if error-status:error then do:
        mError:createError({&error}, error-status:get-message(1)).
        error-status:error = false no-error.
        return.
    end.
    if length(pcTypeTache, 'character') < 5 then pcTypeTache = string(integer(pcTypeTache), '99999').
    if piNumeroTache = ? or piNumeroTache = 0
    then for each tache no-lock
        where tache.TpCon = pcTypeContrat
          and tache.nocon = piNumeroContrat
          and tache.tptac = pcTypeTache:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tache:handle, vhttBuffer).
    end.
    else for each tache no-lock
        where tache.TpCon = pcTypeContrat
          and tache.nocon = piNumeroContrat
          and tache.tptac = pcTypeTache
          and tache.notac = piNumeroTache:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tache:handle, vhttBuffer).
    end.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.


procedure getTache:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as integer   no-undo.
    define input parameter pcTypeTache     as character no-undo.
    define input parameter table-handle phttTache.

    define variable vhttBuffer as handle no-undo.
    define buffer tache for tache.

    vhttBuffer = phttTache:default-buffer-handle.
    {&_proparse_ prolint-nowarn(noeffect)}
    integer(pcTypeTache) no-error.
    if error-status:error then do:
        mError:createError({&error}, error-status:get-message(1)).
        error-status:error = false no-error.
        return.
    end.
    if pcTypeTache > ""
    then do:
        if length(pcTypeTache, 'character') < 5 then pcTypeTache = string(integer(pcTypeTache), '99999').
        for each tache no-lock
            where tache.TpCon = pcTypeContrat
              and tache.nocon = piNumeroContrat
              and tache.tptac = pcTypeTache:
            vhttBuffer:buffer-create().
            outils:copyValidField(buffer tache:handle, vhttBuffer).
        end.
    end.
    else for each tache no-lock
        where tache.TpCon = pcTypeContrat
          and tache.nocon = piNumeroContrat:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tache:handle, vhttBuffer).
    end.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure readExistingLastTache:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par ...
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define input  parameter pcTypeTache     as character no-undo.
    define input  parameter table-handle phttTache.

    ghttTache = phttTache.
    run readOneTache(pcTypeContrat, piNumeroContrat, pcTypeTache, false, true).
    delete object phttTache.
end procedure.
procedure readLastTache:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par ...
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define input  parameter pcTypeTache     as character no-undo.
    define input  parameter table-handle phttTache.

    ghttTache = phttTache.
    run readOneTache(pcTypeContrat, piNumeroContrat, pcTypeTache, false, false).
    delete object phttTache.
end procedure.

procedure readExistingFirstTache:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par ...
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define input  parameter pcTypeTache     as character no-undo.
    define input  parameter table-handle phttTache.

    ghttTache = phttTache.
    run readOneTache(pcTypeContrat, piNumeroContrat, pcTypeTache, true, true).
    delete object phttTache.
end procedure.
procedure readFirstTache:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par ...
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define input  parameter pcTypeTache     as character no-undo.
    define input  parameter table-handle phttTache.

    ghttTache = phttTache.
    run readOneTache(pcTypeContrat, piNumeroContrat, pcTypeTache, true, false).
    delete object phttTache.
end procedure.
procedure readOneTache private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define input  parameter pcTypeTache     as character no-undo.
    define input  parameter plFirst         as logical   no-undo.
    define input  parameter plGestionErreur as logical   no-undo.
    define variable vcWhereClause as character no-undo.
    define variable vhttBuffer    as handle no-undo.
    define buffer tache for tache.

    assign
        vhttBuffer    = ghttTache:default-buffer-handle
        vcWhereClause = substitute("where tache.tpcon = '&1' and tache.nocon = &2 and tache.tptac = '&3'", pcTypeContrat, piNumeroContrat, pcTypeTache)
    .
    if plFirst
    then buffer tache:find-first(vcWhereClause, no-lock) no-error.
    else buffer tache:find-last( vcWhereClause, no-lock) no-error.
    if buffer tache:available
    then do:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tache:handle, vhttBuffer).
    end.
    else if plGestionErreur
         then mError:createError({&error}, 1000365, outilTraduction:getLibelleProg ("O_TAE", pcTypeTache, "l")). // 1000365 0 "La Tache &1 n'existe plus. Mise à jour impossible"
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure getNextTache private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define input  parameter pcTypeTache     as character no-undo.
    define output parameter piNextNoita     as int64     no-undo.
    define output parameter piNextNoTac     as integer   no-undo initial 1.

    define buffer tache for tache.

    run getNextTacheSansCalculNotac(output piNextNoita).
    if piNextNoita <> ?
    then for last tache no-lock          /* Récuperation du numero réel de la tache  */
        where tache.tpcon = pcTypeContrat
          and tache.nocon = piNumeroContrat
          and tache.tptac = pcTypeTache:
        piNextNoTac = tache.notac + 1.
    end.
end procedure.

procedure getNextTacheSansCalculNotac private:
    /*------------------------------------------------------------------------------
    Purpose: recherche prochain numero interne de la tache (noita) sans calcul du numero chronologique (notac) 
    Notes  :
    ------------------------------------------------------------------------------*/
    define output parameter piNextNoita     as int64     no-undo.

    piNextNoita = next-value(sq_noTac01).
    if piNextNoita = ?
    then mError:createError({&error}, 211658, 'Sq_NoTac01').
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatetache private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTptac    as handle  no-undo.
    define variable vhNotac    as handle  no-undo.
    define variable vhNoita    as handle  no-undo.
    define buffer tache for tache.

    create query vhttquery.
    vhttBuffer = ghttTache:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTache:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTptac, output vhNotac, output vhNoita).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tache exclusive-lock
                where rowid(tache) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tache:handle,
                                'tpcon/nocon/tptac/notac: ',
                                substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTptac:buffer-value(), vhNotac:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer tache:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttquery.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTache private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTptac    as handle  no-undo.
    define variable vhNotac    as handle  no-undo.
    define variable vhNoita    as handle  no-undo.
    define variable viNoita    as int64   no-undo.
    define variable viNotac    as integer no-undo.
    define buffer tache for tache.

    create query vhttquery.
    vhttBuffer = ghttTache:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTache:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTptac, output vhNotac, output vhNoita).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            viNotac = vhNotac:buffer-value().
            if viNotac > 0
            then run getNextTacheSansCalculNotac(output viNoita).
            else run getNextTache(vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTptac:buffer-value(), output viNoita, output viNotac).
            assign
                vhNoita:buffer-value() = viNoita
                vhNotac:buffer-value() = viNotac
            .
            create tache.
            if not outils:copyValidField(buffer tache:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttquery.    
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTache private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTptac    as handle  no-undo.
    define variable vhNotac    as handle  no-undo.
    define variable vhNoita    as handle  no-undo.
    define buffer tache for tache.

    create query vhttquery.
    vhttBuffer = ghttTache:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTache:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTptac, output vhNotac, output vhNoita).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tache exclusive-lock
                where rowid(Tache) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tache:handle,
                                'tpcon/nocon/tptac/notac: ',
                                substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTptac:buffer-value(), vhNotac:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete tache no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    vhttquery:query-close().
    delete object vhttquery.    
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTacheSurContrat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.
    
    define buffer tache for tache.

message "deleteTacheSurContrat "  pcTypeContrat "// " piNumeroContrat.

blocTrans:
    do transaction:
        for each tache exclusive-lock 
           where tache.tpcon = pcTypeContrat 
             and tache.nocon = piNumeroContrat:
            delete tache no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
