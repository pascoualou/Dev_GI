/*-----------------------------------------------------------------------------
File        : tacheDigicode.p
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

{immeubleEtLot/include/digicode.i}
{role/include/role.i}

procedure setDigicode:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContratConstruction as int64 no-undo.
    define input parameter table for ttDigicode.
    define input parameter table for ttDigicodeImmeuble.

    define variable vhTache as handle no-undo.

    empty temp-table ttTache.
    for each ttDigicodeImmeuble:
        create ttTache.
        assign
            ttTache.CRUD  = ttDigicodeImmeuble.CRUD
            ttTache.noita = ttDigicodeImmeuble.iNumeroDigicode
            ttTache.tpcon = {&TYPECONTRAT-construction}
            ttTache.nocon = piNumeroContratConstruction
            ttTache.tptac = {&TYPETACHE-digicode}
            ttTache.notac = ttDigicodeImmeuble.iChronoTache
            ttTache.TpFin = ttDigicodeImmeuble.cCodeBatiment
            ttTache.CdHon = ttDigicodeImmeuble.cCodeEntree
            ttTache.tphon = ttDigicodeImmeuble.cCodeEscalier
            /* THK : Abandonné
            ttTache.PdGes = string(ttDigicodeImmeuble.lJourOuverture[1], "1/0")
                          + string(ttDigicodeImmeuble.lJourOuverture[2], "1/0")
                          + string(ttDigicodeImmeuble.lJourOuverture[3], "1/0")
                          + string(ttDigicodeImmeuble.lJourOuverture[4], "1/0")
                          + string(ttDigicodeImmeuble.lJourOuverture[5], "1/0")
                          + string(ttDigicodeImmeuble.lJourOuverture[6], "1/0")
                          + string(ttDigicodeImmeuble.lJourOuverture[7], "1/0")
            ttTache.CdReg = ttDigicodeImmeuble.cHeureDebut
            ttTache.NtReg = ttDigicodeImmeuble.cHeureFin
            */
            ttTache.dtTimestamp = ttDigicodeImmeuble.dtTimestamp
            ttTache.rRowid      = ttDigicodeImmeuble.rRowid
        .
    end.
    for each ttDigicode:
        find first ttTache
            where ttTache.CRUD  = ttDigicode.CRUD
              and ttTache.noita = ttDigicode.iNumeroDigicode
              and ttTache.tpcon = {&TYPECONTRAT-construction}
              and ttTache.nocon = piNumeroContratConstruction
              and ttTache.tptac = {&TYPETACHE-digicode}
              and ttTache.notac = ttDigicode.iChronoTache no-error.
        if not available ttTache
        then do:
            create ttTache.
            assign
                ttTache.CRUD   = ttDigicode.CRUD
                ttTache.noita  = ttDigicode.iNumeroDigicode
                ttTache.tpcon  = {&TYPECONTRAT-construction}
                ttTache.nocon  = piNumeroContratConstruction
                ttTache.tptac  = {&TYPETACHE-digicode}
                ttTache.notac  = ttDigicode.iChronoTache
                ttTache.dtTimestamp = ttDigicode.dtTimestamp
                ttTache.rRowid      = ttDigicode.rRowid
            .
        end.
        case ttDigicode.iExtent:
            when 1 then assign
                ttTache.lbdiv  = ttDigicode.cLibelleDigicode
                ttTache.ntges  = ttDigicode.cAncienDigicode
                ttTache.dtfin  = ttDigicode.daDateFin
                ttTache.tpges  = ttDigicode.cNouveauDigicode
                ttTache.dtdeb  = ttDigicode.daDateDebut
            .
            when 2 then assign
                ttTache.lbdiv2 = ttDigicode.cLibelleDigicode
                ttTache.utreg  = ttDigicode.cAncienDigicode
                ttTache.dtree  = ttDigicode.daDateFin
                ttTache.pdreg  = ttDigicode.cNouveauDigicode
                ttTache.dtreg  = ttDigicode.daDateDebut
        .
        end case.
    end.
    run crud/tache_CRUD.p persistent set vhTache.
    run getTokenInstance in vhTache(mToken:JSessionId).
    run setTache in vhTache(table ttTache by-reference).
    if valid-handle(vhTache) then run destroy in vhTache.

end procedure.

