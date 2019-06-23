/*-----------------------------------------------------------------------------
File        : tacheDommageOuvrage.p
Purpose     : 
Author(s)   : kantena - 2018/09/26
Notes       :
derniere revue:
-----------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{tache/include/tache.i}

{immeubleEtLot/include/dommageOuvrage.i}

procedure setDommageOuvrage:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContratConstruction as int64 no-undo.
    define input parameter table for ttDommageOuvrage.

    define variable vhTache as handle no-undo.

    empty temp-table ttTache.
    for each ttDommageOuvrage:
        create ttTache.
        assign
            ttTache.CRUD  = ttDommageOuvrage.CRUD
            ttTache.noita = ttDommageOuvrage.iNumeroTache
            ttTache.tpcon = {&TYPECONTRAT-construction}
            ttTache.nocon = piNumeroContratConstruction
            ttTache.tptac = {&TYPETACHE-dommageOuvrage}
            ttTache.notac = ttDommageOuvrage.iChronoTache
            ttTache.tpfin = ttDommageOuvrage.cPolice
            ttTache.tphon = ttDommageOuvrage.cGarantie
            ttTache.ntges = string(ttDommageOuvrage.iNumeroCompagnie)
            ttTache.tpges = string(ttDommageOuvrage.iNumeroCourtier)
            ttTache.pdges = ttDommageOuvrage.cCodeFournisseur
            ttTache.dtree = ttDommageOuvrage.daDateReception
            ttTache.dtdeb = ttDommageOuvrage.daDateDebut
            ttTache.dtfin = ttDommageOuvrage.daDateFin
            ttTache.cdhon = ttDommageOuvrage.cCommentaireTravaux
            ttTache.cdreg = ttDommageOuvrage.cCodetypeOuvrage
            ttTache.ntreg = ttDommageOuvrage.cCodeBatiment
            ttTache.dtTimestamp = ttDommageOuvrage.dtTimestamp
            ttTache.rRowid      = ttDommageOuvrage.rRowid
        .
    end.
    run crud/tache_CRUD.p persistent set vhTache.
    run getTokenInstance in vhTache(mToken:JSessionId).
    run setTache in vhTache(table ttTache by-reference).
    if valid-handle(vhTache) then run destroy in vhTache.

end procedure.
