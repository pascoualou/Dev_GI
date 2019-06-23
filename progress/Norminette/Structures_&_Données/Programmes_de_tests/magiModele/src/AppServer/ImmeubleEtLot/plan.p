/*------------------------------------------------------------------------
File        : plan.p
Purpose     :
Author(s)   : kantena - 2017/06/01
Notes       :
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2bien.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{immeubleEtLot/include/plan.i}
{role/include/role.i &nomTable=ttRolePlan}

procedure getPlanImmeuble:
    /*------------------------------------------------------------------------------
    Purpose: Récupérer les informations Plans d'un immeuble
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroImmeuble            as integer no-undo.
    define input parameter piNumeroContratConstruction as int64   no-undo.
    define output parameter table for ttPlan.

    define buffer tache for tache.

    for each tache no-lock
        where tache.tpcon = {&TYPECONTRAT-construction}
          and tache.nocon = piNumeroContratConstruction
          and tache.tptac = {&TYPETACHE-plan}:
        run createttPlan(piNumeroImmeuble, 0, buffer tache).
    end.

end procedure.

procedure getPlanLot:
    /*------------------------------------------------------------------------------
    Purpose: Récupérer les informations Plans d'un lot
    Notes  : service utilisé par beLot.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroImmeuble            as integer no-undo.
    define input parameter piNumeroBien                as int64   no-undo.
    define input parameter piNumeroContratConstruction as int64   no-undo.
    define output parameter table for ttPlan.

    define buffer taint for taint.
    define buffer local for local.
    define buffer tache for tache.

    for each taint no-lock
       where taint.tpcon = {&TYPECONTRAT-construction}
         and taint.nocon = piNumeroContratConstruction
         and taint.tptac = {&TYPETACHE-plan}
         and taint.tpidt = {&TYPEBIEN-lot}
         and taint.noidt = piNumeroBien
     , first local no-lock
       where local.noloc = taint.noidt
     ,  each tache no-lock
       where tache.tpcon = taint.tpcon
         and tache.nocon = taint.nocon
         and tache.tptac = taint.tptac
         and tache.notac = taint.notac:
        run createttPlan(piNumeroImmeuble, local.nolot, buffer tache).
    end.
end procedure.

procedure createttPlan private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroImmeuble as integer no-undo.
    define input parameter piNumeroLot      as integer no-undo.
    define parameter buffer tache for tache.

    create ttPlan.
    assign
        ttPlan.CRUD            = 'R'
        ttPlan.iNumeroPlan     = tache.noita
        ttPlan.cTypeContrat    = tache.tpcon
        ttPlan.iNumeroContrat  = tache.nocon
        ttPlan.cCodeTypeTache  = tache.tptac
        ttPlan.iChronoTache    = tache.notac
        ttPlan.iNumeroImmeuble = piNumeroImmeuble
        ttPlan.iNumeroLot      = piNumeroLot
        ttPlan.cTypePlan       = tache.dcreg
        ttPlan.cLibellePlan    = outilTraduction:getLibelleParam("CDPLA", Tache.dcreg)
        ttPlan.cCodeBatiment   = tache.ntreg
        ttPlan.lPrivatif       = (tache.pdreg = "TRUE")
        ttPlan.cNomOrganisme   = tache.utreg
        ttPlan.daDatePlan      = tache.dtdeb
        ttPlan.cCommentaire    = tache.cdreg
        ttPlan.dtTimestamp     = datetime(tache.dtmsy, tache.hemsy)
        ttPlan.rRowid          = rowid(tache)
    .
end procedure.

