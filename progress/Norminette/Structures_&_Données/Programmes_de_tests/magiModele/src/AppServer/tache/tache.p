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
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure genTacAuto private:
    /*------------------------------------------------------------------------------
    Purpose: Génération des Tâches Automatiques de Type "Gestion".
    Notes  : todo: pas utilisé ??!!
    ------------------------------------------------------------------------------*/
    define input parameter piNumContrat    as integer   no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter pcNatureContrat as character no-undo.

    define variable voDefautBail   as class parametrageDefautBail   no-undo.
    define variable voDefautMandat as class parametrageDefautMandat no-undo.
    define variable vcCodeModGes as character no-undo.
    define variable vcTmpPdt     as character no-undo.
    define variable vcPthAut     as character no-undo.
    define variable vcCodeRetAut as character no-undo.

    define buffer vbtache for tache.
    define buffer sys_pg  for sys_pg.
    define buffer vbSyspg for sys_pg.
    define buffer ctrat   for ctrat.
    define buffer cttac   for cttac.
    define buffer vbCttac for cttac.
    define buffer tache   for tache.

    /* Récupérer la Date de Début du Contrat.  */
    find first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumContrat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, error-status:get-message(1)).
        error-status:error = false no-error.
        return.
    end.
bloc:
    do transaction:
        assign
            voDefautBail   = new parametrageDefautBail(pcNatureContrat)
            voDefautMandat = new parametrageDefautMandat()
        .
        /* recherche des tâches de gestion obligatoires et automatiques à générer. */
boucleTache:
        for each sys_pg no-lock
           where sys_pg.tppar = 'R_CTA'
             and sys_pg.zone1 = pcNatureContrat
              by sys_pg.zone2:
            /* Récupérer le Type de Tâche ('G' ou 'C'). */
            find first vbSyspg no-lock
                 where vbSyspg.tppar = 'O_TAE'
                   and vbSyspg.cdpar = sys_pg.zone2 no-error.
            if not available vbSyspg then next boucleTache.

            /* Stocker l'Entree du Mode de Gestion. */
            vcCodeModGes = entry(3, vbSyspg.zone9, "@").
            /* Ne gérer que les Tâches de Type 'G' Auto ('A'). */
            if entry(1, vbSyspg.zone9, '@') = 'G' and vcCodeModGes = 'A'
            then do:
                /* Récuperation du numéro réel de la tâche. */
                find last tache exclusive-lock
                    where tache.tptac = sys_pg.zone2
                      and tache.tpcon = pcTypeContrat
                      and tache.nocon = piNumContrat no-wait no-error.
                if not available tache
                then do:
                    if locked tache then do:
                        mLogger:writeLog(0, substitute(outilTraduction:getLibelle(211652), pcTypeContrat + string(piNumContrat))).
                        mError:createError({&error}, 211652, pcTypeContrat + ': ' + string(piNumContrat)).
                        undo bloc, leave bloc.
                    end.
                    empty temp-table ttTache.
                    create ttTache.
                    assign
                        ttTache.noIta = next-value (Sq_NoTac01)
                        ttTache.DtDeb = ctrat.dtdeb
                        ttTache.tpTac = sys_pg.zone2
                        ttTache.notac = 1
                        ttTache.tpCon = pcTypeContrat
                        ttTache.noCon = piNumContrat
                    .
                    /* Tester si Borne Maximale Atteinte.  */
                    if ttTache.noIta = ? then do:
                        mError:createError({&error}, 211658, 'Sq_NoTac01').
                        undo bloc, leave bloc.
                    end.
                    if Sys_pg.zone2 = {&TYPETACHE-depotGarantieBail}
                    and (pcTypeContrat = {&TYPECONTRAT-Bail} or pcTypeContrat = {&TYPECONTRAT-preBail})
                    then do:
                        /* par défaut DG reverse */
                        ttTache.ntges = "18008".
                        find last vbTache no-lock
                            where vbtache.tpcon = {&TYPECONTRAT-mandat2Gerance}
                              and vbtache.nocon = int64(truncate(piNumContrat / 100000, 0))   // integer(substring(string(piNumContrat, "9999999999"), 1, 5, 'character'))
                              and vbtache.tptac = {&TYPETACHE-depotGarantieMandat} no-error.
                        if available vbtache
                        then ttTache.ntges = vbtache.ntges.
                        else do:
                            /*Si tache absente, rechercher dans param def mandat */
                            if voDefautMandat:isDbParameter
                            then assign
                                vcTmpPdt = entry(3, voDefautMandat:zon02 ,separ[1])
                                vcTmpPdt = entry(3, vcTmpPdt, separ[2])
                            .
                            if vcTmpPdt > "18000" then ttTache.ntges = vcTmpPdt.
                        end.
                        assign
                            ttTache.tpGes = "1"
                            ttTache.pdges = "00002"
                            ttTache.cdreg = "00001"    /* mode de calcul */
                            ttTache.utreg = {&non}     /* reactu a la baisse = non */
                        .
                        if voDefautBail:isDbParameter then do:
                            if num-entries(voDefautBail:zon10, separ[1]) >= 2 then ttTache.tpGes = entry(2, voDefautBail:zon10, separ[1]).
                            if num-entries(voDefautBail:zon10, separ[1]) >= 3 then ttTache.pdges = entry(3, voDefautBail:zon10, separ[1]).
                            if num-entries(voDefautBail:zon10, separ[1]) >= 4 then ttTache.cdreg = entry(4, voDefautBail:zon10, separ[1]).
                            if num-entries(voDefautBail:zon10, separ[1]) >= 5 then ttTache.utreg = entry(5, voDefautBail:zon10, separ[1]).
                        end.
                    end.
                    create tache.
                    tache.noita = ttTache.noIta no-error.
                    if error-status:error then do:
                        mError:createError({&error}, error-status:get-message(1)).
                        undo bloc, leave bloc.
                    end.
                    if not outils:copyValidField(buffer tache:handle, buffer ttTache:handle, 'C', mtoken:cUser) then undo bloc, leave bloc.
                    next boucleTache.
                end.
            end.
            /* Gérer les Taches Automatiques à lancer en Externe (par un Prog commencant par "Aut"). */
            if entry(1, vbSyspg.zone9, '@') = 'G' and vcCodeModGes = 'AS'
            then do:
                vcPthAut = 'tache/aut' + vbSyspg.nmprg.
                if search(replace(vcPthAut, '.p', '.r')) = ? or search(vcPthAut) = ?
                then do:
                    mError:createError(211660, vcPthAut).
                    undo bloc, leave bloc.
                end.
                // On évite, tant que faire se peut, de faire un run VALUE(..)
                case vbSyspg.nmprg:
                    when 'asatt' then run tache/autasatt.p('', pcTypeContrat, piNumContrat, ttTache.TpTac, output vcCodeRetAut).
                    when 'syimp' then run tache/autsyimp.p('', pcTypeContrat, piNumContrat, ttTache.TpTac, output vcCodeRetAut).
                end case.

                if vcCodeRetAut <> "00"
                then do:
                    mError:createError(211659, vcPthAut).
                    undo bloc, leave bloc.
                end.
            end.
        end.
        /*  Création automatique lien cttac Bail
          - tache refacturation mandat {&TYPETACHE-refacturationDepMandat2} si le mandat à la tache {&TYPETACHE-refacturationDepMandat1} */
        if ctrat.tpcon = {&TYPECONTRAT-preBail} or ctrat.tpcon = {&TYPECONTRAT-Bail}
        then for first vbCttac no-lock
            where vbCttac.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and vbCttac.nocon = int64(truncate(ctrat.nocon / 100000, 0))  // int64(substring(string(ctrat.nocon, "9999999999"), 1, 5, 'character'))
              and vbCttac.tptac = {&TYPETACHE-refacturationDepMandat1}:
            if not can-find(first cttac no-lock
                 where cttac.tpcon = ctrat.tpcon
                   and cttac.nocon = ctrat.nocon
                   and cttac.tptac = {&TYPETACHE-refacturationDepMandat2})
            then do:
                create cttac.
                assign
                    cttac.TpTac = {&TYPETACHE-refacturationDepMandat2}
                    cttac.TpCon = ctrat.tpcon
                    cttac.NoCon = ctrat.NoCon
                    cttac.DtCSy = today
                    cttac.HeCSy = mtime
                    cttac.CdCSy = mToken:cUser + "@GenTacAuto"
                .
            end.
        end.
    end.
    delete object voDefautMandat.
    delete object voDefautBail.
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
