/*-----------------------------------------------------------------------------
File        : tacheImmeuble.p
Purpose     : 
Author(s)   : kantena - 2017/12/18
Notes       :
derniere revue: 2018/07/12 - phm: KO
        traiter les todo
-----------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2bien.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{tache/include/tache.i}
{immeubleEtLot/include/plan.i}

procedure setPlan:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls et beLot.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContratConstruction as int64   no-undo.
    define input parameter piNumeroBien                as integer no-undo. /* Numéro lot si privatif (si appelé par beLot.cls) */
    define input parameter table for ttPlan.

    define variable vhTache as handle no-undo.

    define buffer local for local.
    define buffer taint for taint.
    define buffer ttTache for ttTache.

    run crud/tache_CRUD.p persistent set vhTache.
    run getTokenInstance in vhTache(mToken:JSessionId).
    empty temp-table ttTache.
    for each ttPlan:
        create ttTache.
        assign
            ttTache.noita = ttPlan.iNumeroPlan
            ttTache.tpcon = {&TYPECONTRAT-construction}
            ttTache.nocon = piNumeroContratConstruction
            ttTache.tptac = {&TYPETACHE-plan}
            ttTache.notac = ttPlan.iChronoTache
            ttTache.DcReg = ttPlan.cTypePlan
            ttTache.ntreg = ttPlan.cCodeBatiment
            ttTache.pdreg = if ttPlan.lPrivatif then "TRUE" else "FALSE"
            ttTache.utreg = ttPlan.cNomOrganisme
            ttTache.dtdeb = ttPlan.daDatePlan
            ttTache.cdreg = ttPlan.cCommentaire
            ttTache.CRUD        = ttPlan.CRUD
            ttTache.dtTimestamp = ttPlan.dtTimestamp
            ttTache.rRowid      = ttPlan.rRowid
        .
        run setTache in vhTache(table ttTache by-reference).
        if available ttTache and ttPlan.lprivatif then do:
            // Suppression des lots privatifs
            // todo   Il y a un service local_CRUD ??? Si oui l'utiliser, sinon, le faire.
            if ttPlan.crud = 'D' then do:
                find first local no-lock
                    where local.noloc = piNumeroBien no-error.
                if available local
                then for first taint exclusive-lock
                    where taint.tpcon = {&TYPECONTRAT-construction}
                      and taint.nocon = piNumeroContratConstruction
                      and taint.tptac = {&TYPETACHE-plan}
                      and taint.notac = ttTache.notac
                      and taint.noidt = local.noloc
                      and taint.tpidt = {&TYPEBIEN-lot}:
                    delete taint.
                end.
            end.
            // Création et modification des lots privatifs
            if ttPlan.crud = 'C' or ttPlan.crud = 'U' then do:
                find first local no-lock
                    where local.noloc = piNumeroBien no-error.
                if available local and not can-find(first taint no-lock
                    where taint.tpcon = {&TYPECONTRAT-construction}
                      and taint.nocon = piNumeroContratConstruction
                      and taint.tptac = {&TYPETACHE-plan}
                      and taint.notac = ttTache.notac
                      and taint.noidt = local.noloc
                      and taint.tpidt = {&TYPEBIEN-lot})
                then do:
                    create taint.
                    assign
                        taint.tpcon = {&TYPECONTRAT-construction}
                        taint.nocon = piNumeroContratConstruction
                        taint.tptac = {&TYPETACHE-plan}
                        taint.notac = ttTache.notac
                        taint.noidt = local.noloc
                        taint.tpidt = {&TYPEBIEN-lot}
                    .
                end.
            end.
        end.
        delete ttTache no-error.
    end.
    run destroy in vhTache.

end procedure.

