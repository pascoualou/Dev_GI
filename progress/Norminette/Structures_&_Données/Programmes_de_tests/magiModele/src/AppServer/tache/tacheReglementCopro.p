/*-----------------------------------------------------------------------------
File        : tacheReglementCopro.p
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
{immeubleEtLot/include/reglementCopropriete.i}

{role/include/role.i}

procedure setReglementCopropriete:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContratConstruction as int64 no-undo.
    define input parameter table for ttReglementCopropriete.

    define variable vhTache as handle no-undo.

    empty temp-table ttTache.
    for each ttReglementCopropriete:
        create ttTache.
        assign
            ttTache.noita = ttReglementCopropriete.iNumeroReglement
            ttTache.tpcon = {&TYPECONTRAT-construction}
            ttTache.nocon = piNumeroContratConstruction
            ttTache.tptac = {&TYPETACHE-reglement2copro}
            ttTache.notac = ttReglementCopropriete.iChronoTache
            ttTache.dtdeb = ttReglementCopropriete.daDateReglement
            ttTache.tpfin = ttReglementCopropriete.cLieuReglement
            ttTache.dtfin = ttReglementCopropriete.daDatePublication
            ttTache.ntges = ttReglementCopropriete.cNomBureau
            ttTache.tpges = string(ttReglementCopropriete.iNumeroNotaire)
            ttTache.pdges = ttReglementCopropriete.cVolume                  // npo #7791
            ttTache.pdreg = ttReglementCopropriete.cNumero                  // npo #7791
            ttTache.duree = ttReglementCopropriete.iTotalLot
            ttTache.cdreg = string(ttReglementCopropriete.iNombreLotsPrincipaux)
            ttTache.ntreg = ttReglementCopropriete.cCommentaire
            ttTache.CRUD        = ttReglementCopropriete.CRUD
            ttTache.dtTimestamp = ttReglementCopropriete.dtTimestamp
            ttTache.rRowid      = ttReglementCopropriete.rRowid
        .
    end.
    if can-find(first ttTache) then do:
        run crud/tache_CRUD.p persistent set vhTache.
        run getTokenInstance in vhTache(mToken:JSessionId).
        run setTache in vhTache(table ttTache by-reference).
        run destroy in vhTache.
    end.

end procedure.
