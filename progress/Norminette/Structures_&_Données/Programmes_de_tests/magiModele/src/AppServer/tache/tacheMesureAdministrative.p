/*-----------------------------------------------------------------------------
File        : tacheMesureAdministrative.p
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
{immeubleEtLot/include/mesureAdministrative.i}

procedure setMesureAdministrative:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input parameter table for ttMesureAdministrative.
    define variable vcValeurReponse as character no-undo.

    define variable vhTache as handle no-undo.

    empty temp-table ttTache.
    for first ttMesureAdministrative:
        create ttTache.
        assign
            ttTache.noita = ttMesureAdministrative.iNumeroTache
            ttTache.tpcon = ttMesureAdministrative.cTypeContrat
            ttTache.nocon = ttMesureAdministrative.iNumeroContrat
            ttTache.tptac = {&TYPETACHE-mesureAdministrative}
            ttTache.notac = ttMesureAdministrative.iChronoTache
            ttTache.CRUD        = ttMesureAdministrative.CRUD
            ttTache.dtTimestamp = ttMesureAdministrative.dtTimestamp
            ttTache.rRowid      = ttMesureAdministrative.rRowid
        .
    end.
    for each ttMesureAdministrative:
        assign
            vcValeurReponse = if ttMesureAdministrative.lValeurReponse then {&oui} else {&non}
            vcValeurReponse = if ttMesureAdministrative.cCommentaire > ""
                              then substitute('&1&2&3', vcValeurReponse, separ[1], ttMesureAdministrative.cCommentaire)
                              else substitute('&1&2',   vcValeurReponse, separ[1])
            vcValeurReponse = if ttMesureAdministrative.daDateDebut <> ?
                              then substitute('&1&2&3', vcValeurReponse, separ[1], ttMesureAdministrative.daDateDebut)
                              else substitute('&1&2',   vcValeurReponse, separ[1])
            vcValeurReponse = if ttMesureAdministrative.daDateFin <> ?
                              then substitute('&1&2&3', vcValeurReponse, separ[1], ttMesureAdministrative.daDateFin)
                              else vcValeurReponse
        .
        case ttMesureAdministrative.cCodeReponse:
            when "CdPer" then ttTache.tpfin = vcValeurReponse.
            when "CdIns" then ttTache.ntges = vcValeurReponse.
            when "CdInj" then ttTache.tpges = vcValeurReponse.
            when "CdHis" then ttTache.dcreg = vcValeurReponse.
            when "CdHab" then ttTache.pdges = vcValeurReponse.
            when "CdRav" then ttTache.cdreg = vcValeurReponse.
            when "CdSau" then ttTache.ntreg = vcValeurReponse.
            when "CdCla" then ttTache.pdreg = vcValeurReponse.
        end case.
    end.
    if can-find(first ttTache) then do:
        run crud/tache_CRUD.p persistent set vhTache.
        run getTokenInstance in vhTache(mToken:JSessionId).
        run setTache in vhTache(table ttTache by-reference).
        run destroy in vhTache.
    end.
end procedure.
