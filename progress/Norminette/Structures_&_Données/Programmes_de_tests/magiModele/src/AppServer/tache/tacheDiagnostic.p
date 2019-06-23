/*-----------------------------------------------------------------------------
File        : tacheDiagnostic.p
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

{immeubleEtLot/include/diagnostic.i}
{role/include/role.i}

procedure setDiagnosticEtude:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls et beLot.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContratConstruction as int64   no-undo.
    define input parameter piNumeroBien                as integer no-undo. /* Numéro lot si privatif (si appelé par beLot.cls) */
    define input parameter table for ttDiagnosticEtude.

    define variable vhTache as handle no-undo.
    define buffer taint   for taint.
    define buffer ttTache for ttTache.

    run crud/tache_CRUD.p persistent set vhTache.
    run getTokenInstance in vhTache(mToken:JSessionId).
    empty temp-table ttTache.
    for each ttDiagnosticEtude:
        create ttTache.
        assign
            ttTache.noita         = ttdiagnosticEtude.iNumeroTache
            ttTache.tpcon         = {&TYPECONTRAT-construction}
            ttTache.nocon         = piNumeroContratConstruction
            ttTache.tptac         = ttdiagnosticEtude.cCodeTypeTache
            ttTache.notac         = ttdiagnosticEtude.iChronoTache
            ttTache.cdhon         = if ttdiagnosticEtude.cCodeOrganisme > "" then substitute("FOU,&1", ttdiagnosticEtude.cCodeOrganisme) else ""
            ttTache.utreg         = ttdiagnosticEtude.cLibelleOrganisme
            ttTache.DcReg         = ttdiagnosticEtude.cCodeDisposition
            ttTache.ntreg         = ttdiagnosticEtude.cCodeBatiment
            ttTache.dtdeb         = ttdiagnosticEtude.daDateRecherche
            ttTache.tpfin         = ttdiagnosticEtude.cCodeResultatRecherche
            ttTache.dtfin         = ttdiagnosticEtude.daDatePrevueDT
            ttTache.dtree         = ttdiagnosticEtude.daDateRealiseeDT
            ttTache.dtreg         = ttdiagnosticEtude.daDateControle
            ttTache.NtGes         = string(ttdiagnosticEtude.lControle, {&ouiNon})
            ttTache.tpGes         = string(ttdiagnosticEtude.lSurveillance, {&ouiNon})
            ttTache.PdGes         = string(ttdiagnosticEtude.lTravaux, {&ouiNon})
            ttTache.cdreg         = ttdiagnosticEtude.cCommentaire
            ttTache.etqenergie    = ttdiagnosticEtude.cEtiquetteEnergie
            ttTache.etqclimat     = ttdiagnosticEtude.cEtiquetteClimat
            ttTache.valetqenergie = ttdiagnosticEtude.iValeurEtiquetteEnergie
            ttTache.valetqclimat  = ttdiagnosticEtude.iValeurEtiquetteClimat
            ttTache.pdreg         = if ttdiagnosticEtude.lPrivatif then "TRUE" else "FALSE"
            ttTache.CRUD          = ttDiagnosticEtude.CRUD
            ttTache.dtTimestamp   = ttdiagnosticEtude.dtTimestamp
            ttTache.rRowid        = ttdiagnosticEtude.rRowid
        .
        run setTache in vhTache(table ttTache by-reference).
        if available ttTache and ttDiagnosticEtude.lPrivatif then do:
            if ttDiagnosticEtude.crud = 'D' then do:
                if can-find(first local no-lock
                            where local.noloc = piNumeroBien)
                then for first taint exclusive-lock
                    where taint.tpcon = {&TYPECONTRAT-construction}
                      and taint.nocon = piNumeroContratConstruction
                      and taint.tptac = ttdiagnosticEtude.cCodeTypeTache
                      and taint.notac = ttTache.notac
                      and taint.noidt = piNumeroBien
                      and taint.tpidt = {&TYPEBIEN-lot}:
                    delete taint.
                end.
            end.
            if (ttDiagnosticEtude.crud = 'C' or ttDiagnosticEtude.crud = 'U')
            and can-find(first local no-lock
                         where local.noloc = piNumeroBien)
            and not can-find(first taint no-lock
                             where taint.tpcon = {&TYPECONTRAT-construction}
                               and taint.nocon = piNumeroContratConstruction
                               and taint.tptac = ttdiagnosticEtude.cCodeTypeTache
                               and taint.notac = ttTache.notac
                               and taint.noidt = piNumeroBien
                               and taint.tpidt = {&TYPEBIEN-lot})
            then do:
                create taint.
                assign
                    taint.tpcon = {&TYPECONTRAT-construction}
                    taint.nocon = piNumeroContratConstruction
                    taint.tptac = ttdiagnosticEtude.cCodeTypeTache
                    taint.notac = ttTache.notac
                    taint.noidt = piNumeroBien
                    taint.tpidt = {&TYPEBIEN-lot}
                .
            end.
        end.
        delete ttTache no-error.
    end.
    run destroy in vhTache.

end procedure.
