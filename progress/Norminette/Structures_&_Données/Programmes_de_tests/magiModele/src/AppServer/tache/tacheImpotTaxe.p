/*-----------------------------------------------------------------------------
File        : tacheImpotTaxe.p
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
{immeubleEtLot/include/impotTaxeImmeuble.i}

procedure setImpotTaxe:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContratConstruction as int64 no-undo.
    define input parameter table for ttImpotTaxe.

    define variable vhTache as handle no-undo.

    empty temp-table ttTache.
    for each ttImpotTaxe:
        create ttTache.
        assign
            ttTache.CRUD        = ttImpotTaxe.CRUD
            ttTache.noita       = ttImpotTaxe.iNumeroTache
            ttTache.tpcon       = {&TYPECONTRAT-construction}
            ttTache.nocon       = piNumeroContratConstruction
            ttTache.tptac       = {&TYPETACHE-organismesSociaux}
            ttTache.notac       = ttImpotTaxe.iChronoTache
            ttTache.tpfin       = ttImpotTaxe.cCodeTypeOrganisme
            ttTache.ntges       = ttImpotTaxe.cNumeroOrganisme
            ttTache.dtTimestamp = ttImpotTaxe.dtTimestamp
            ttTache.rRowid      = ttImpotTaxe.rRowid
        .
    end.
    if can-find(first ttTache) then do:
        run crud/tache_CRUD.p persistent set vhTache.
        run getTokenInstance in vhTache(mToken:JSessionId).
        run setTache in vhTache(table ttTache by-reference).
        run destroy in vhTache.
    end.
end procedure.
