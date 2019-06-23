/*-----------------------------------------------------------------------------
File        : tacheGardienLoge.p
Purpose     : 
Author(s)   : kantena - 2018/09/26
Notes       :
derniere revue:
-----------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2bien.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{tache/include/tache.i}
{immeubleEtLot/include/gardienLoge.i}
{immeubleEtLot/include/horairesOuverture.i}
{role/include/role.i}


function formatHoraireSerie1 returns character private ():
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    return ttHorairesOuvSerie1.cHeureDebut1 + separ[2] + ttHorairesOuvSerie1.cHeureFin1 + separ[1]
           + ttHorairesOuvSerie1.cHeureDebut2 + separ[2] + ttHorairesOuvSerie1.cHeureFin2 + separ[1]
           + string(ttHorairesOuvSerie1.lJourOuverture[1], '1/0')
           + string(ttHorairesOuvSerie1.lJourOuverture[2], '1/0')
           + string(ttHorairesOuvSerie1.lJourOuverture[3], '1/0')
           + string(ttHorairesOuvSerie1.lJourOuverture[4], '1/0')
           + string(ttHorairesOuvSerie1.lJourOuverture[5], '1/0')
           + string(ttHorairesOuvSerie1.lJourOuverture[6], '1/0')
           + string(ttHorairesOuvSerie1.lJourOuverture[7], '1/0').

end function.

function formatHoraireSerie2 returns character private ():
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    return ttHorairesOuvSerie2.cHeureDebut1 + separ[2] + ttHorairesOuvSerie2.cHeureFin1 + separ[1]
           + ttHorairesOuvSerie2.cHeureDebut2 + separ[2] + ttHorairesOuvSerie2.cHeureFin2 + separ[1]
           + string(ttHorairesOuvSerie2.lJourOuverture[1], '1/0')
           + string(ttHorairesOuvSerie2.lJourOuverture[2], '1/0')
           + string(ttHorairesOuvSerie2.lJourOuverture[3], '1/0')
           + string(ttHorairesOuvSerie2.lJourOuverture[4], '1/0')
           + string(ttHorairesOuvSerie2.lJourOuverture[5], '1/0')
           + string(ttHorairesOuvSerie2.lJourOuverture[6], '1/0')
           + string(ttHorairesOuvSerie2.lJourOuverture[7], '1/0').

end function.

function lControleHoraire returns logical private(input-output pcHeureMinute as character):
    /*------------------------------------------------------------------------------
    Purpose: controle le format d'une heure
    Notes  : doit être de la forme 'xx:xx' avec xx 0-9 ou vide et compris entre 0-23:0-59
    ------------------------------------------------------------------------------*/
    define variable viHeure  as integer no-undo.
    define variable viMinute as integer no-undo.

    if pcHeureMinute = ? or pcHeureMinute = "" then return true. // si aucun horaire n'est saisi

    assign
        viHeure  = integer(entry(1, pcHeureMinute, ':'))
        viMinute = integer(entry(2, pcHeureMinute, ':'))
    no-error.
    if error-status:error or viHeure > 23 or viMinute > 59 then do:
        mError:createError({&error}, 211708).
        return false.
    end.
    pcHeureMinute = substitute('&1:&2', string(viHeure, '99'), string(viMinute, '99')).
    return true.

end function.

procedure setLoges:
    /*------------------------------------------------------------------------------
    Purpose: Maj tache avec horaires de la loge
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input parameter table for ttLoge.
    define input parameter table for ttHorairesOuvSerie1.
    define input parameter table for ttHorairesOuvSerie2.

    define variable vhTache as handle no-undo.

    empty temp-table ttTache.
    for each ttLoge:
        create ttTache.
        assign
            ttTache.CRUD        = ttLoge.CRUD
            ttTache.notac       = 1
            ttTache.noita       = ttLoge.iNumeroTache
            ttTache.nocon       = ttLoge.iNumeroContrat
            ttTache.tpcon       = ttLoge.cTypeContrat
            ttTache.tptac       = ttLoge.cTypeTache
            ttTache.tpges       = if ttLoge.cNomTiersDepannage  <> ? then ttLoge.cNomTiersDepannage  else ""
            ttTache.cdreg       = if ttLoge.cCodeTiersDepannage <> ? then ttLoge.cCodeTiersDepannage else ""
            ttTache.lbdiv       = substitute('&1&2&2', ttLoge.cCommentaire, separ[1])      // ne pas enlever !!! legacy (3 entrées separ[1])
            ttTache.dcreg       = ttLoge.cCoordonneeContact1  + separ[1] + ttLoge.cCoordonneeContact2
            ttTache.lbdiv2      = ''  // ne pas enlever !!! legacy
            ttTache.lbdiv3      = ''  // ne pas enlever !!! legacy
            ttTache.dtTimestamp = ttLoge.dtTimestamp
            ttTache.rRowid      = ttLoge.rRowid
        .
        for first ttHorairesOuvSerie1
            where ttLoge.iNumeroLoge = ttHorairesOuvSerie1.iNumeroIdentifiant:
            if not lControleHoraire(input-output ttHorairesOuvSerie1.cHeureDebut1)
            or not lControleHoraire(input-output ttHorairesOuvSerie1.cHeureFin1)
            or not lControleHoraire(input-output ttHorairesOuvSerie1.cHeureDebut2)
            or not lControleHoraire(input-output ttHorairesOuvSerie1.cHeureFin2) then return.

            ttTache.tphon = formatHoraireSerie1().
        end.
        for first ttHorairesOuvSerie2
            where ttLoge.iNumeroLoge = ttHorairesOuvSerie2.iNumeroIdentifiant:
            if not lControleHoraire(input-output ttHorairesOuvSerie2.cHeureDebut1)
            or not lControleHoraire(input-output ttHorairesOuvSerie2.cHeureFin1)
            or not lControleHoraire(input-output ttHorairesOuvSerie2.cHeureDebut2)
            or not lControleHoraire(input-output ttHorairesOuvSerie2.cHeureFin2) then return.

            ttTache.ntges = formatHoraireSerie2().
        end.
    end.
    if can-find(first ttTache) then do:
        run crud/tache_CRUD.p persistent set vhTache.
        run getTokenInstance in vhTache(mToken:JSessionId).
        run setTache in vhTache(table ttTache by-reference).
        run destroy in vhTache.
    end.    
end procedure.

procedure setGardien:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContratConstruction as int64 no-undo.
    define input parameter table for ttGardien.
    define input parameter table for ttRole.
    define input parameter table for ttHorairesOuvSerie1.
    define input parameter table for ttHorairesOuvSerie2.

    define variable vhTache as handle no-undo.

    empty temp-table ttTache.
    for each ttGardien:
        create ttTache.
        assign
            ttTache.CRUD        = ttGardien.CRUD
            ttTache.noita       = ttGardien.iNumeroTache
            ttTache.tpcon       = {&TYPECONTRAT-construction}
            ttTache.nocon       = piNumeroContratConstruction
            ttTache.tptac       = {&TYPETACHE-gardien}
            ttTache.notac       = ttGardien.iChronoTache
            ttTache.tpges       = ttGardien.cNomGardien when ttGardien.cNomGardien > ""
            ttTache.dcreg       = ttGardien.cCoordonneeContact1 + separ[1] + ttGardien.cCoordonneeContact2
            ttTache.dtTimestamp = ttGardien.dtTimestamp
            ttTache.rRowid      = ttGardien.rRowid
            ttTache.fgrev       = ttGardien.lPrincipal
            ttTache.tpfin       = ttGardien.cCodeBatiment
            ttTache.CdHon       = ttGardien.cCodeEntree
            ttTache.utreg       = ttGardien.cCodeEscalier
            tttache.lbdiv2      = ttGardien.cCommentaire
            ttTache.tprol       = ttGardien.cCodeTypeRole
            ttTache.norol       = ttGardien.iNumeroRole
        .
        for first ttHorairesOuvSerie1
            where ttHorairesOuvSerie1.iNumeroRole   = ttGardien.iNumeroRole
              and ttHorairesOuvSerie1.cCodeTypeRole = ttGardien.cCodeTypeRole:
            if not lControleHoraire(input-output ttHorairesOuvSerie1.cHeureDebut1)
            or not lControleHoraire(input-output ttHorairesOuvSerie1.cHeureFin1)
            or not lControleHoraire(input-output ttHorairesOuvSerie1.cHeureDebut2)
            or not lControleHoraire(input-output ttHorairesOuvSerie1.cHeureFin2) then return.
            ttTache.tphon = formatHoraireSerie1().
            
        end.
        for first ttHorairesOuvSerie2
            where ttHorairesOuvSerie2.iNumeroIdentifiant = ttGardien.iNumeroTache:
            if not lControleHoraire(input-output ttHorairesOuvSerie2.cHeureDebut1)
            or not lControleHoraire(input-output ttHorairesOuvSerie2.cHeureFin1)
            or not lControleHoraire(input-output ttHorairesOuvSerie2.cHeureDebut2)
            or not lControleHoraire(input-output ttHorairesOuvSerie2.cHeureFin2) then return.
            ttTache.ntges = formatHoraireSerie2().
        end.
    end.
    if can-find(first ttTache) then do:
        run crud/tache_CRUD.p persistent set vhTache.
        run getTokenInstance in vhTache(mToken:JSessionId).
        run setTache in vhTache(table ttTache by-reference).
        run destroy in vhTache.
    end.
end procedure.

