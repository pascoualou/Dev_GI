/*------------------------------------------------------------------------------
File        : suppressionMandatSyndic.p
Purpose     : Suppression d'un mandat de syndic
Author(s)   : ofa 2019/01/23
Notes       : reprise du pgm adb/cont/delmdtsy.p
derniere revue: 2019/01/24 - npo: fonction controlesAvantSuppression OK 
------------------------------------------------------------------------*/

{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2tache.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2budget.i}
{preprocesseur/typeAppel.i}
{preprocesseur/mode2gestionFournisseurLoyer.i}

using parametre.pclie.parametragePayePegase.
using parametre.pclie.parametrageFournisseurLoyer.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/error.i}
{crud/include/aparm.i}
{application/include/glbsepar.i}
{tache/include/tache.i}
{crud/include/ctrat.i}
{crud/include/pclie.i}
{crud/include/tbent.i}
{crud/include/cumsa.i}
{crud/include/intnt.i}
{crud/include/ctctt.i}
{crud/include/txqtt.i}
{crud/include/perio.i}
{outils/include/lancementProgramme.i} // fonction lancementPgm, suppressionPgmPersistent
{adb/cpta/delmdcpt.i}                 // procédure suppressionMandatComptabilite
define temp-table ttEnteteImputationParticuliere no-undo /* table entip */
    field nocon     as int64
    field noimm     as integer
    field dtimp     as date
    field rRowid    as rowid
    field crud      as character
    .
define temp-table ttDetailImputationParticuliere no-undo /* table detip */
    field nocon     as int64
    field noimm     as integer
    field dtimp     as date
    field rRowid    as rowid
    field crud      as character
    .

define temp-table ttEnteteReleve no-undo /* table erlet */
    field nocon     as int64
    field norli     as integer
    field tpcpt     as character
    field norlv     as integer
    field rRowid    as rowid
    field crud      as character
    .
define temp-table ttDetailReleve no-undo /* table erldt */
    field norli     as integer
    field nolot     as integer
    field nocpt     as character
    field nocop     as integer
    field rRowid    as rowid
    field crud      as character
    .
define temp-table ttEnteteAppelFondsRoulement no-undo /* table apfet */
    field noimm     as integer
    field tpapp     as character
    field nofon     as integer
    field noapp     as integer
    field rRowid    as rowid
    field crud      as character
    .
define temp-table ttDetailAppelFondsRoulement no-undo /* table apfdt */
    field noimm     as integer
    field tpapp     as character
    field nofon     as integer
    field noapp     as integer
    field noecr     as integer
    field nolig     as integer
    field rRowid    as rowid
    field crud      as character
    .
define temp-table ttAppelHorsBudgetMatricule no-undo /* table ahbet */
    field noimm     as integer
    field noapp     as integer
    field rRowid    as rowid
    field crud      as character
    .
define temp-table ttEnteteAppelHorsBudget no-undo /* table ahbdt */
    field noimm     as integer
    field noapp     as integer
    field nocpt     as integer
    field noscp     as integer
    field cdeta     as integer
    field noecr     as integer
    field nolig     as integer
    field rRowid    as rowid
    field crud      as character
    .
define temp-table ttDetailAppelHorsBudget no-undo /* table ahbmt */
    field noimm     as integer
    field noapp     as integer
    field nolot     as integer
    field nocop     as integer
    field noecr     as integer
    field nolig     as integer
    field rRowid    as rowid
    field crud      as character
    .
define temp-table ttEnteteBudget no-undo /* table budge */
    field tpbud     as character
    field nobud     as integer
    field rRowid    as rowid
    field crud      as character
    .
define temp-table ttDetailAppelParLot no-undo /* table apbco */
    field tpbud     as character
    field nobud     as integer
    field tpapp     as character
    field noapp     as integer
    field typapptrx as character
    field noimm     as integer
    field cdcle     as character
    field nocop     as integer
    field rRowid    as rowid
    field crud      as character
    .
define temp-table ttEnteteFraisAdministratif no-undo /* table frset */
    field tpbud     as character
    field nobud     as integer
    field rRowid    as rowid
    field crud      as character
    .
define temp-table ttDetailFraisAdministratif no-undo /* table frsdt */
    field soc-cd    as integer
    field etab-cd   as integer
    field mois-cpt  as integer
    field fam-cle   as character
    field sfam-cle  as character
    field art-cle   as character
    field cdcle     as character
    field daech     as date
    field noord     as integer
    field rRowid    as rowid
    field crud      as character
    .
define temp-table ttMembreConseilSyndical no-undo /* table taint */
    field tpcon     as character
    field nocon     as integer
    field tptac     as character
    field notac     as integer
    field tpidt     as character
    field noidt     as integer
    field rRowid    as rowid
    field crud      as character
    .
define temp-table ttTableauFrequentationReelleRIE no-undo /* table FreReEt */
    field tpcon     as character
    field nocon     as integer
    field noexo     as integer
    field rRowid    as rowid
    field crud      as character
    .
define temp-table ttTableauFrequentationTheorRIE no-undo /* table FreThEt */
    field tpcon     as character
    field nocon     as integer
    field noexo     as integer
    field rRowid    as rowid
    field crud      as character
    .
define temp-table ttLienPeriodeTableau no-undo /* table tprtb */
    field tpcon     as character
    field nocon     as integer
    field noExe     as integer
    field NoPer     as integer
    field NoImm     as integer
    field TpCpt     as character
    field NoRlv     as integer
    field rRowid    as rowid
    field crud      as character
    .

define variable giNumeroMandat         as int64     no-undo.
define variable glMuet                 as logical   no-undo.
define variable gcTypeTrt              as character no-undo.
define variable giNumeroImmeuble       as int64     no-undo.
define variable giRefCopro             as integer   no-undo.
define variable ghProc                 as handle    no-undo.

function affichageMessage return logical private (pcMessage as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcInfoMandat as character no-undo.

    if not glMuet and not gcTypeTrt begins "PURGE" then do:
        vcInfoMandat = outilFormatage:fSubst(outilTraduction:getLibelle(1000665), string(giNumeroMandat)).
        mError:createError({&information}, substitute("&1&2", vcInfoMandat, pcMessage)).
    end.
end function.

function controlesAvantSuppression return logical private ():
    /*------------------------------------------------------------------------------
    Purpose: Controle de la suppression d'un Mandat
    Notes  : Ancienne procédure CtrlDel
    ------------------------------------------------------------------------------*/
    define variable vlAnocontrole        as logical no-undo.

    define buffer ctrat   for ctrat.
    define buffer ctctt   for ctctt.
    define buffer intnt   for intnt.
    define buffer lprtb   for lprtb.
    define buffer erlet   for erlet.

    if not can-find(first ctrat no-lock
                    where ctrat.tpcon = {&TYPECONTRAT-mandat2Syndic}
                      and ctrat.nocon = giNumeroMandat) then do:
        affichageMessage (outilFormatage:fSubstGestion(outilTraduction:getLibelle(1000739), string(giNumeroMandat))). //Mandat &1 introuvable
        vlAnocontrole = yes.
    end.
    if can-find(first cecrln no-lock
                where cecrln.soc-cd  = giRefCopro
                  and cecrln.etab-cd = giNumeroMandat) then do:
        affichageMessage (outilTraduction:getLibelle(107475)). //Il existe des écritures en comptabilité (cecrln)
        vlAnocontrole = yes.
    end.
    if can-find(first cextln no-lock
                where cextln.soc-cd  = giRefCopro
                  and cextln.etab-cd = giNumeroMandat) then do:
        affichageMessage (outilTraduction:getLibelle(107476)). //Il existe des écritures en comptabilité (cextln)
        vlAnocontrole = yes.
    end.
    if can-find(first pregln no-lock
                where pregln.soc-cd  = giRefCopro
                  and pregln.etab-cd = giNumeroMandat) then do:
        affichageMessage (outilTraduction:getLibelle(107618)). //Il existe des écritures en comptabilité (pregln)
        vlAnocontrole = yes.
    end.
    if can-find(first cexmln no-lock
                where cexmln.soc-cd  = giRefCopro
                  and cexmln.etab-cd = giNumeroMandat) then do:
        affichageMessage (outilTraduction:getLibelle(107477)). //Il existe des écritures en comptabilité (cexmln)
        vlAnocontrole = yes.
    end.
    if can-find(first ifdhono no-lock
                where ifdhono.soc-cd  = giRefCopro
                  and ifdhono.etab-cd = giNumeroMandat) then do:
        affichageMessage (outilTraduction:getLibelle(107619)). //Il existe des honoraires sur ce mandat.
        vlAnocontrole = yes.
    end.
    for each ctctt no-lock
        where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
          and ctctt.noct1 = giNumeroMandat
          and ctctt.tpct2 = {&TYPECONTRAT-SalariePegase},
        first ctrat no-lock
        where ctrat.tpcon = ctctt.TpCt2
          and ctrat.nocon = ctctt.noct2:
        affichageMessage(outilFormatage:fSubstGestion(outilTraduction:getLibelle(107622), substitute('&2&1', separ[1], giNumeroMandat))). //Le mandat %1 a au moins un employé d'immeuble.
        vlAnocontrole = yes.
    end.
    for each ctctt no-lock
        where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
          and ctctt.noct1 = giNumeroMandat
          and ctctt.tpct2 = {&TYPECONTRAT-mutation},
        first ctrat
        where ctrat.tpcon = ctctt.tpct2
        and   ctrat.nocon = ctctt.noct2:
        affichageMessage(outilTraduction:getLibelle(107625)). //Vous avez passé une mutation sur ce mandat.
        vlAnocontrole = yes.
    end.
    for each lprtb no-lock
        where lprtb.tpcon = {&TYPECONTRAT-mandat2Syndic}
        and   lprtb.nocon = giNumeroMandat,
        first erlet no-lock
        where erlet.noimm = giNumeroImmeuble
        and   erlet.norlv = lprtb.norlv:
        affichageMessage(outilTraduction:getLibelle(107624)). //Vous avez saisi un rélévé d'eau sur ce mandat.
        vlAnocontrole = yes.
    end.
    if can-find(first bupre no-lock
                where bupre.nobud >= giNumeroMandat * 100000
                and   bupre.nobud <= giNumeroMandat * 100000 + 99999) then do:
        affichageMessage(outilTraduction:getLibelle(107626)). //Vous avez saisi un budget sur ce mandat.
        vlAnocontrole = yes.
    end.
    if giNumeroImmeuble > 0
        and can-find(first ahbet no-lock
                     where ahbet.noimm = giNumeroImmeuble) then do:
        affichageMessage(outilTraduction:getLibelle(107627)). //Vous avez créé un appel hors-budget sur ce mandat.
        vlAnocontrole = yes.
    end.
    if giNumeroImmeuble > 0
        and can-find(first apfet no-lock
                     where apfet.noimm = giNumeroImmeuble) then do:
        affichageMessage(outilTraduction:getLibelle(107628)). //Vous avez créé un appel de fonds sur ce mandat.
        vlAnocontrole = yes.
    end.
    if can-find(first eaget no-lock
                where eaget.tpcon = {&TYPECONTRAT-mandat2Syndic}
                and   eaget.nocon = giNumeroMandat) then do:
        affichageMessage(outilTraduction:getLibelle(107629)). //Vous avez créé une assemblée générale sur ce mandat.
        vlAnocontrole = yes.
    end.
    if can-find(first ctctt no-lock
                where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                and   ctctt.noct1 = giNumeroMandat
                and   ctctt.tpct2 = {&TYPECONTRAT-assuranceSyndic}) then do:
        affichageMessage(outilTraduction:getLibelle(107630)). //Vous avez créé une assurance sur ce mandat.
        vlAnocontrole = yes.
    end.
    if can-find(first ctctt no-lock
                where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                and   ctctt.noct1 = giNumeroMandat
                and   ctctt.tpct2 = {&TYPECONTRAT-travaux}) then do:
        affichageMessage(outilTraduction:getLibelle(107631)). //Vous avez créé un contrat travaux sur ce mandat.
        vlAnocontrole = yes.
    end.
    if can-find(first trfev no-lock
                where trfev.nomdt = giNumeroMandat) then do:
        affichageMessage(outilTraduction:getLibelle(110013)). //Vous avez une demande de tirage en attente pour ce mandat
        vlAnocontrole = yes.
    end.
    return vlAnocontrole.

end function.

procedure lanceSuppressionMandatSyndic:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table for ttError.
    define input parameter piNumeroMandat as int64     no-undo.
    define input parameter plMuet         as logical   no-undo.
    define input parameter pcTypeTrt      as character no-undo.
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define buffer intnt for intnt.

mLogger:writeLog(0, substitute("lanceSuppressionMandatSyndic mandat : &1 muet : &2 type trt : &3", piNumeroMandat, plMuet, pcTypeTrt)).

    assign
        giNumeroMandat = piNumeroMandat
        glMuet         = plMuet
        gcTypeTrt      = pcTypeTrt
        giRefCopro     = integer(mToken:cRefCopro)
    .
    for first intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
          and intnt.nocon = giNumeroMandat
          and intnt.tpidt = {&TYPEBIEN-immeuble}:
        giNumeroImmeuble = intnt.noidt.
    end.
    if gcTypeTrt <> "PURGE" and gcTypeTrt <> "PURGE-MANPOWER" and controlesAvantSuppression() then return.

    run suppressionMandatSyndic(input-output poCollectionHandlePgm).

end procedure.

procedure suppressionMandatSyndic private:
    /*------------------------------------------------------------------------------
    Purpose: Suppression du Mandat
    Notes  : Ancienne procédure DelMdtSy
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

mLogger:writeLog(0, "suppressionMandatSyndic.p suppressionMandatSyndic").

    if not glMuet and not gcTypeTrt begins "PURGE" and outils:questionnaire(107720, table ttError by-reference) <= 2 then return.

    if gcTypeTrt <> "PURGE" then do:
        run suppressionMandatComptabilite(giRefCopro, giNumeroMandat, input-output poCollectionHandlePgm).
        if mError:erreur() then return.
    end.

    run suppressionLienMandatSyndicat(input-output poCollectionHandlePgm).
    run suppressionTitreCopropriete(input-output poCollectionHandlePgm).
    run suppressionLienCoproGerance(input-output poCollectionHandlePgm).
    run suppressionCompensationParLot(input-output poCollectionHandlePgm).
    run suppressionMandatSepa(input-output poCollectionHandlePgm).
    run suppressionMutation(input-output poCollectionHandlePgm).
    run suppressionContratsEntretien(input-output poCollectionHandlePgm).
    run suppressionAssembleesGenerales(input-output poCollectionHandlePgm).
    run suppressionImputationsParticulieres(input-output poCollectionHandlePgm).
    run suppressionReleves(input-output poCollectionHandlePgm).
    run suppressionAppelsDeFondsEtBudget(input-output poCollectionHandlePgm).
    run suppressionFraisAdministratifs(input-output poCollectionHandlePgm).
    run suppressionDossiersTravauxEtInterventions(input-output poCollectionHandlePgm).
    run suppressionTaches(input-output poCollectionHandlePgm).
    run suppressionMembresConseilSyndical(input-output poCollectionHandlePgm).
    run suppressionPeriodes(input-output poCollectionHandlePgm).
    run suppressionFrequentationRIE(input-output poCollectionHandlePgm).
    run suppressionRoleSyndicatEtLiens(input-output poCollectionHandlePgm).
    run suppressionDetailAlertes(input-output poCollectionHandlePgm).
    run suppressionPaie(input-output poCollectionHandlePgm).
    run suppressionRattachementLot(input-output poCollectionHandlePgm).
    run suppressionAttestationsTravaux(input-output poCollectionHandlePgm).
    run suppressionTransferts(input-output poCollectionHandlePgm).
    run suppressionHistoriqueHonoraires(input-output poCollectionHandlePgm).
    run suppressionPclie(input-output poCollectionHandlePgm).
    run suppressionIntnt(input-output poCollectionHandlePgm).
    run suppressionClesRepartition(input-output poCollectionHandlePgm).
    run suppressionCtCtt(input-output poCollectionHandlePgm).
    run suppressionContratMandat2Syndic(input-output poCollectionHandlePgm).
    //run SupEvenementiel({&TYPECONTRAT-mandat2Syndic}, giNumeroMandat).

    //Mise à jour des sequences
    ghProc = lancementPgm("adblib/majseq.p", poCollectionHandlePgm).
    run lanceMajseq in ghProc.
    if mError:erreur() then return.

end procedure.

procedure suppressionAppelsDeFondsEtBudget:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define buffer budge   for budge.
    define buffer ahbet   for ahbet.
    define buffer ahbdt   for ahbdt.
    define buffer ahbmt   for ahbmt.
    define buffer apfet   for apfet.
    define buffer apfdt   for apfdt.
    define buffer apbco   for apbco.
    define buffer ctrat   for ctrat.

    empty temp-table ttEnteteAppelHorsBudget.
    empty temp-table ttDetailAppelHorsBudget.
    empty temp-table ttAppelHorsBudgetMatricule.
    empty temp-table ttEnteteAppelFondsRoulement.
    empty temp-table ttDetailAppelFondsRoulement.

    for each ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-budget}
        and   ctrat.nocon >= giNumeroMandat * 100000 + 00001
        and   ctrat.nocon <= giNumeroMandat * 100000 + 00099:

        /*LbTmpPdt = {&TYPECONTRAT-mandat2Syndic}
                + "|" + STRING(giNumeroMandat)
                + "|" + bud_ctrat.tpcon
                + "|" + STRING(bud_ctrat.nocon)
                + "|" + TpTrtUse
        .

        {RunPgExp.i &Path       = RpRunLibADB
                    &Prog       = "'Delbud00.p'"
                    &Parameter  = "INPUT LbTmpPdt
                                    , OUTPUT CdRetUse
                                    , OUTPUT LbDivSor"}*/
    end.

    if giNumeroImmeuble > 0 then do:
        for each ahbet no-lock
            where   ahbet.noimm = giNumeroImmeuble:
            create ttEnteteAppelHorsBudget.
            buffer-copy ahbet to ttEnteteAppelHorsBudget
            assign
                ttEnteteAppelHorsBudget.rRowid = rowid(ahbet)
                ttEnteteAppelHorsBudget.crud = "D"
                .
        end.
        if can-find(first ttEnteteAppelHorsBudget) then do:
            ghProc = lancementPgm("crud/ahbet_CRUD.p", poCollectionHandlePgm).
            run setAhbet in ghProc(table ttEnteteAppelHorsBudget by-reference).
            if mError:erreur() then return.
        end.
        for each ahbdt no-lock
            where   ahbdt.noimm = giNumeroImmeuble:
            create ttDetailAppelHorsBudget.
            buffer-copy ahbdt to ttDetailAppelHorsBudget
            assign
                ttDetailAppelHorsBudget.rRowid = rowid(ahbdt)
                ttDetailAppelHorsBudget.crud = "D"
                .
        end.
        if can-find(first ttDetailAppelHorsBudget) then do:
            ghProc = lancementPgm("crud/ahbdt_CRUD.p", poCollectionHandlePgm).
            run setAhbdt in ghProc(table ttDetailAppelHorsBudget by-reference).
            if mError:erreur() then return.
        end.
        for each ahbmt no-lock
            where   ahbmt.noimm = giNumeroImmeuble:
            create ttAppelHorsBudgetMatricule.
            buffer-copy ahbmt to ttAppelHorsBudgetMatricule
            assign
                ttAppelHorsBudgetMatricule.rRowid = rowid(ahbmt)
                ttAppelHorsBudgetMatricule.crud = "D"
                .
        end.
        if can-find(first ttAppelHorsBudgetMatricule) then do:
            ghProc = lancementPgm("crud/ahbmt_CRUD.p", poCollectionHandlePgm).
            run setAhbmt in ghProc(table ttAppelHorsBudgetMatricule by-reference).
            if mError:erreur() then return.
        end.
        for each apfet no-lock
            where   apfet.noimm = giNumeroImmeuble:
            create ttEnteteAppelFondsRoulement.
            buffer-copy apfet to ttEnteteAppelFondsRoulement
            assign
                ttEnteteAppelFondsRoulement.rRowid = rowid(apfet)
                ttEnteteAppelFondsRoulement.crud = "D"
                .
        end.
        if can-find(first ttEnteteAppelFondsRoulement) then do:
            ghProc = lancementPgm("crud/apfet_CRUD.p", poCollectionHandlePgm).
            run setApfet in ghProc(table ttEnteteAppelFondsRoulement by-reference).
            if mError:erreur() then return.
        end.
        for each apfdt no-lock
            where   apfdt.noimm = giNumeroImmeuble:
            create ttDetailAppelFondsRoulement.
            buffer-copy apfdt to ttDetailAppelFondsRoulement
            assign
                ttDetailAppelFondsRoulement.rRowid = rowid(apfdt)
                ttDetailAppelFondsRoulement.crud = "D"
                .
        end.
        if can-find(first ttDetailAppelFondsRoulement) then do:
            ghProc = lancementPgm("crud/apfdt_CRUD.p", poCollectionHandlePgm).
            run setApfdt in ghProc(table ttDetailAppelFondsRoulement by-reference).
            if mError:erreur() then return.
        end.
    end.

    //suppression de l'entete FRx FSx (budge)
    empty temp-table ttEnteteBudget.
    for each Budge no-lock
        where budge.tpbud = {&TYPEBUDGET-fondsDeRoulement}
        and   budge.nobud >= giNumeroMandat * 100000
        and   budge.nobud <= giNumeroMandat * 100000 + 99999:
        create ttEnteteBudget.
        buffer-copy budge to ttEnteteBudget
        assign
            ttEnteteBudget.rRowid = rowid(budge)
            ttEnteteBudget.crud = "D"
            .
    end.
    for each Budge no-lock
        where budge.tpbud = {&TYPEBUDGET-fondsDeReserve}
        and   budge.nobud >= giNumeroMandat * 100000
        and   budge.nobud <= giNumeroMandat * 100000 + 99999:
        create ttEnteteBudget.
        buffer-copy budge to ttEnteteBudget
        assign
            ttEnteteBudget.rRowid = rowid(budge)
            ttEnteteBudget.crud = "D"
            .
    end.
    if can-find(first ttEnteteBudget) then do:
        ghProc = lancementPgm("crud/budge_CRUD.p", poCollectionHandlePgm).
        run setBudge in ghProc(table ttEnteteBudget by-reference).
        if mError:erreur() then return.
    end.
    empty temp-table ttDetailAppelParLot.
    for each apbco no-lock
        where apbco.nomdt = giNumeroMandat:
        create ttDetailAppelParLot.
        buffer-copy apbco to ttDetailAppelParLot
        assign
            ttDetailAppelParLot.rRowid = rowid(apbco)
            ttDetailAppelParLot.crud = "D"
            .
    end.
    if can-find(first ttDetailAppelParLot) then do:
        ghProc = lancementPgm("crud/apbco_CRUD.p", poCollectionHandlePgm).
        run setApbco in ghProc(table ttDetailAppelParLot by-reference).
        if mError:erreur() then return.
    end.
end procedure.

procedure suppressionReleves:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define buffer erlet   for erlet.
    define buffer erldt   for erldt.

    empty temp-table ttEnteteReleve.
    empty temp-table ttDetailReleve.
    for each erlet no-lock
        where erlet.noimm = giNumeroImmeuble:
        for each erldt no-lock
            where erldt.norli = erlet.norli:
            create ttDetailReleve.
            buffer-copy erldt to ttDetailReleve
            assign
                ttDetailReleve.rRowid = rowid(erldt)
                ttDetailReleve.crud = "D"
                .
        end.
        create ttEnteteReleve.
        buffer-copy erlet to ttEnteteReleve
        assign
            ttEnteteReleve.rRowid = rowid(erlet)
            ttEnteteReleve.crud = "D"
            .
    end.
    if can-find(first ttEnteteReleve) then do:
        ghProc = lancementPgm("crud/erlet_CRUD.p", poCollectionHandlePgm).
        run setErlet in ghProc(table ttEnteteReleve by-reference).
        if mError:erreur() then return.
    end.
    if can-find(first ttDetailReleve) then do:
        ghProc = lancementPgm("crud/erldt_CRUD.p", poCollectionHandlePgm).
        run setErldt in ghProc(table ttDetailReleve by-reference).
        if mError:erreur() then return.
    end.
end procedure.

procedure suppressionFraisAdministratifs:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define buffer frset   for frset.
    define buffer frsdt   for frsdt.

    empty temp-table ttEnteteFraisAdministratif.
    for each frset no-lock
        where frset.tpmdt = {&TYPECONTRAT-mandat2Syndic}
        and   frset.nomdt = giNumeroMandat:
        create ttEnteteFraisAdministratif.
        buffer-copy frset to ttEnteteFraisAdministratif
        assign
            ttEnteteFraisAdministratif.rRowid = rowid(frset)
            ttEnteteFraisAdministratif.crud = "D"
            .
    end.
    if can-find(first ttEnteteFraisAdministratif) then do:
        ghProc = lancementPgm("crud/frset_CRUD.p", poCollectionHandlePgm).
        run setFrset in ghProc(table ttEnteteFraisAdministratif by-reference).
        if mError:erreur() then return.
    end.
    empty temp-table ttDetailFraisAdministratif.
    for each frsdt no-lock
        where frsdt.tpmdt = {&TYPECONTRAT-mandat2Syndic}
        and   frsdt.nomdt = giNumeroMandat:
        create ttDetailFraisAdministratif.
        buffer-copy frsdt to ttDetailFraisAdministratif
        assign
            ttDetailFraisAdministratif.rRowid = rowid(frsdt)
            ttDetailFraisAdministratif.crud = "D"
            .
    end.
    if can-find(first ttDetailFraisAdministratif) then do:
        ghProc = lancementPgm("crud/frsdt_CRUD.p", poCollectionHandlePgm).
        run setFrsdt in ghProc(table ttDetailFraisAdministratif by-reference).
        if mError:erreur() then return.
    end.
end procedure.

procedure suppressionFrequentationRIE:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define buffer FreReEt for FreReEt.
    define buffer FreReDt for FreReDt.
    define buffer FreThEt for FreThEt.
    define buffer FreThDt for FreThDt.

    empty temp-table ttTableauFrequentationReelleRIE.
    for each FreReEt no-lock
        where FreReEt.TpCon = {&TYPECONTRAT-mandat2Syndic}
        and   FreReEt.Nocon = giNumeroMandat:
        create ttTableauFrequentationReelleRIE.
        buffer-copy FreReEt to ttTableauFrequentationReelleRIE.
        assign
            ttTableauFrequentationReelleRIE.rRowid = rowid(FreReEt)
            ttTableauFrequentationReelleRIE.CRUD   = 'D'
        .
    end.
    if can-find(first ttTableauFrequentationReelleRIE) then do:
        ghProc = lancementPgm("crud/FreReEt_CRUD.p", poCollectionHandlePgm).
        run setFreReEt in ghProc(table ttTableauFrequentationReelleRIE by-reference).
        if mError:erreur() then return.
    end.
    empty temp-table ttTableauFrequentationTheorRIE.
    for each FreThEt no-lock
        where FreThEt.TpCon = {&TYPECONTRAT-mandat2Syndic}
        and   FreThEt.Nocon = giNumeroMandat:
        create ttTableauFrequentationTheorRIE.
        buffer-copy FreThEt to ttTableauFrequentationTheorRIE.
        assign
            ttTableauFrequentationTheorRIE.rRowid = rowid(FreThEt)
            ttTableauFrequentationTheorRIE.CRUD   = 'D'
        .
    end.
    if can-find(first ttTableauFrequentationTheorRIE) then do:
        ghProc = lancementPgm("crud/FreThEt_CRUD.p", poCollectionHandlePgm).
        run setFreThEt in ghProc(table ttTableauFrequentationTheorRIE by-reference).
        if mError:erreur() then return.
    end.

end procedure.

procedure suppressionRoleSyndicatEtLiens:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    for first roles no-lock
        where roles.tprol = {&TYPEROLE-syndicat2copro}
        and   roles.norol = giNumeroMandat:
        for each iLienAdresse exclusive-lock
            where iLienAdresse.cTypeIdentifiant = roles.tprol
              and iLienAdresse.iNumeroIdentifiant = roles.norol:
            delete iLienAdresse.
        end.
        //Contrat bloc-notes
        for each intnt no-lock
            where intnt.tpidt = roles.tprol
            and   intnt.noidt = roles.norol
            and   intnt.tpcon = {&TYPECONTRAT-blocNote}:
            for each ctrat no-lock
                where ctrat.tpcon = intnt.tpcon
                and   ctrat.nocon = intnt.nocon:
                delete ctrat.
            end.
            delete intnt.
        end.
        delete roles.
    end.

end procedure.

procedure suppressionPeriodes:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define buffer perio   for perio.
    define buffer lprtb   for lprtb.

    empty temp-table ttPerio.
    for each perio no-lock
        where perio.tpctt = {&TYPECONTRAT-mandat2Syndic}
        and   perio.nomdt = giNumeroMandat:
        create ttPerio.
        buffer-copy perio to ttPerio
        assign
            ttPerio.dtTimestamp = datetime(perio.dtmsy, perio.hemsy)
            ttPerio.rRowid      = rowid(perio)
            ttPerio.CRUD        = "D"
        .
    end.
    if can-find(first ttPerio) then do:
        ghProc = lancementPgm("crud/perio_CRUD.p", poCollectionHandlePgm).
        run setPerio in ghProc(table ttPerio by-reference).
        if mError:erreur() then return.
    end.

    empty temp-table ttLienPeriodeTableau.
    for each lprtb no-lock
        where lprtb.tpcon = {&TYPECONTRAT-mandat2Syndic}
        and   lprtb.nocon = giNumeroMandat:
        create ttLienPeriodeTableau.
        buffer-copy lprtb to ttLienPeriodeTableau.
        assign
            ttLienPeriodeTableau.rRowid = rowid(lprtb)
            ttLienPeriodeTableau.CRUD   = 'D'
        .
    end.
    if can-find(first ttLienPeriodeTableau) then do:
        ghProc = lancementPgm("crud/lprtb_CRUD.p", poCollectionHandlePgm).
        run setLprtb in ghProc(table ttLienPeriodeTableau by-reference).
        if mError:erreur() then return.
    end.

end procedure.

procedure suppressionDetailAlertes:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define buffer gadet   for gadet.

    for each gadet no-lock
        where gadet.tpctt = {&TYPECONTRAT-mandat2Syndic}
        and   gadet.noctt = DEC(giNumeroMandat):
        delete gadet.
    end.
    for each gadet no-lock
        where gadet.tpctt begins "AP":
        if num-entries(gadet.tpctt, "-") >= 2 and integer(entry(2, gadet.tpctt, "-")) = giNumeroMandat then delete gadet.
    end.

end procedure.

procedure suppressionPaie:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define buffer etabl   for etabl.
    define buffer qipay   for qipay.
    define buffer ctctt   for ctctt.
    define buffer cumsa   for cumsa.

    /* salaries (Ancienne paye)*/
    for each ctctt no-lock
        where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
          and ctctt.noct1 = giNumeroMandat
          and ctctt.tpct2 = {&TYPECONTRAT-Salarie}:
        ghProc = lancementPgm("adblib/delsalarie.p", poCollectionHandlePgm).
        run DelCttSal in ghProc({&TYPEROLE-salarie}, ctctt.noct2, ctctt.tpct2, ctctt.noct1, ctctt.tpct1, gcTypeTrt, no, input-output poCollectionHandlePgm).
        if mError:erreur() then return.
    end.

    /* historiques de paie des salariés anciennement épurés */
    empty temp-table ttCumsa.
    for each cumsa no-lock
        // whole-index corrige par la creation dans la version d'un index sur nomdt
        where cumsa.tpmdt = {&TYPECONTRAT-mandat2Syndic}
          and cumsa.nomdt = giNumeroMandat:
        create ttCumsa.
        assign
            ttCumsa.antrt       = cumsa.antrt
            ttCumsa.tpmdt       = cumsa.tpmdt
            ttCumsa.nomdt       = cumsa.nomdt
            ttCumsa.tprol       = cumsa.tprol
            ttCumsa.norol       = cumsa.norol
            ttCumsa.nomod       = cumsa.nomod
            ttCumsa.CRUD        = "D"
            ttCumsa.dtTimestamp = datetime(cumsa.dtmsy, cumsa.hemsy)
            ttCumsa.rRowid      = rowid(cumsa)
         .
    end.
    if can-find(first ttCumsa) then do:
        ghProc = lancementPgm("crud/cumsa_CRUD.p", poCollectionHandlePgm).
        run setCumsa in ghProc(table ttCumsa by-reference).
        if mError:erreur() then return.
    end.

    /* conges payes des salariés anciennement épurés */
    if can-find(first conge no-lock
                where conge.tprol = {&TYPEROLE-salarie}
                  and conge.norol >= giNumeroMandat * 100 + 01
                  and conge.norol <= giNumeroMandat * 100 + 99) then do:
        ghProc = lancementPgm("crud/conge_CRUD.p", poCollectionHandlePgm).
        run deleteCongeSurPlageRole in ghProc({&TYPEROLE-salarie}, integer(string(giNumeroMandat, "9999") + "01"), integer(string(giNumeroMandat, "9999") + "99")).
        if mError:erreur() then return.
    end.

    /* jours maladie des salariés anciennement épurés */
    if can-find(first malad no-lock
                where malad.tprol = {&TYPEROLE-salarie}
                  and malad.norol >= giNumeroMandat * 100 + 01
                  and malad.norol <= giNumeroMandat * 100 + 99) then do:
        ghProc = lancementPgm("crud/malad_CRUD.p", poCollectionHandlePgm).
        run deleteMaladSurPlageRole in ghProc({&TYPEROLE-salarie}, integer(string(giNumeroMandat, "9999") + "01"), integer(string(giNumeroMandat, "9999") + "99")).
        if mError:erreur() then return.
    end.

    /* histo paie des salariés anciennement épurés */
    if can-find(first apaie no-lock
                where apaie.tprol = {&TYPEROLE-salarie}
                  and apaie.norol >= giNumeroMandat * 100 + 01
                  and apaie.norol <= giNumeroMandat * 100 + 99) then do:
        ghProc = lancementPgm("crud/apaie_CRUD.p", poCollectionHandlePgm).
        run deleteApaieSurRole in ghProc({&TYPEROLE-salarie}, integer(string(giNumeroMandat, "9999") + "01"), integer(string(giNumeroMandat, "9999") + "99")).
        if mError:erreur() then return.
    end.

    /* salaries Pégase */
    for each ctctt no-lock
       where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
         and ctctt.noct1 = giNumeroMandat
         and ctctt.tpct2 = {&TYPECONTRAT-SalariePegase}:
        ghProc = lancementPgm("adblib/delsalarie.p", poCollectionHandlePgm).
        run DelCttSal in ghProc({&TYPEROLE-salariePegase}, ctctt.noct2, ctctt.tpct2, ctctt.noct1, ctctt.tpct1, gcTypeTrt, no, input-output poCollectionHandlePgm).
        if mError:erreur() then return.
    end.

    for each etabl no-lock
        where etabl.tpcon = {&TYPECONTRAT-mandat2Syndic}
        and   etabl.nocon = giNumeroMandat:
        delete Etabl.
    end.

    for each qipay no-lock
        where qipay.tpmdt = {&TYPECONTRAT-mandat2Syndic}
        and   qipay.nomdt = giNumeroMandat:
        delete qipay.
    end.

end procedure.

procedure suppressionRattachementLot:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define buffer ratlo   for ratlo.

    for each ratlo no-lock
        where ratlo.tpmdt = {&TYPECONTRAT-mandat2Syndic}
        and   ratlo.nomdt = giNumeroMandat:
        delete ratlo.
    end.

end procedure.

procedure suppressionAttestationsTravaux:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define buffer attra   for attra.

    for each attra  no-lock
        where attra.tpcon = {&TYPECONTRAT-mandat2Syndic}
        and   attra.nocon = giNumeroMandat:
        delete attra.
    end.

end procedure.

procedure suppressionTransferts:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    if can-find(first trfpm no-lock
                where trfpm.nomdt = giNumeroMandat) then do:
        ghProc = lancementPgm("crud/trfpm_CRUD.p", poCollectionHandlePgm).
        run deleteTrfpmSurMandat in ghProc(giNumeroMandat).
        if mError:erreur() then return.
    end.

    if can-find(first trfev no-lock
                where trfev.nomdt = giNumeroMandat) then do:
        ghProc = lancementPgm("crud/trfev_CRUD.p", poCollectionHandlePgm).
        run deleteTrfevSurMandat in ghProc(giNumeroMandat).
        if mError:erreur() then return.
    end.

    if can-find(first trftx no-lock
                where trftx.nomdt = giNumeroMandat) then do:
        ghProc = lancementPgm("crud/trftx_CRUD.p", poCollectionHandlePgm).
        run deleteTrftxSurMandat in ghProc(giNumeroMandat).
        if mError:erreur() then return.
    end.

    if can-find(first adas2 no-lock
                where adas2.nomdt = giNumeroMandat) then do:
        ghProc = lancementPgm("crud/adas2_CRUD.p", poCollectionHandlePgm).
        run deleteAdas2SurMandat in ghProc(giNumeroMandat).
        if mError:erreur() then return.
    end.

end procedure.

procedure suppressionHistoriqueHonoraires:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    if can-find(first ahon2 no-lock
                where ahon2.nomdt = giNumeroMandat) then do:
        ghProc = lancementPgm("crud/ahon2_CRUD.p", poCollectionHandlePgm).
        run deleteAhon2SurMandat in ghProc(giNumeroMandat).
        if mError:erreur() then return.
    end.

    if can-find(first ahono no-lock
                where ahono.tpmdt = {&TYPECONTRAT-mandat2Syndic}
                  and ahono.nomdt = giNumeroMandat) then do:
        ghProc = lancementPgm("crud/ahono_CRUD.p", poCollectionHandlePgm).
        run deleteAhonoSurMandat in ghProc({&TYPECONTRAT-mandat2Syndic}, giNumeroMandat).
        if mError:erreur() then return.
    end.

end procedure.

procedure suppressionPclie:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define buffer pclie   for pclie.

    //Suppression d'une éventuelle trace dans les purges de pec erronées
    empty temp-table ttPclie.
    for each pclie no-lock
        where   pclie.tppar = "PECEC"
        and     pclie.zon01 = {&TYPECONTRAT-mandat2Syndic}
        and     pclie.int01 = giNumeroMandat:
        create ttPclie.
        assign
            ttPclie.tppar       = pclie.tppar
            ttPclie.zon01       = pclie.zon01
            ttPclie.dtTimestamp = datetime(pclie.dtmsy, pclie.hemsy)
            ttPclie.rRowid      = rowid(pclie)
            ttPclie.CRUD        = "D"
        .
    end.

    /* Param enquete de charges */
    for each pclie no-lock
        where pclie.tppar = "ECSA1"
        and integer(pclie.zon01) =  giNumeroMandat:
        create ttPclie.
        assign
            ttPclie.tppar       = pclie.tppar
            ttPclie.zon01       = pclie.zon01
            ttPclie.dtTimestamp = datetime(pclie.dtmsy, pclie.hemsy)
            ttPclie.rRowid      = rowid(pclie)
            ttPclie.CRUD        = "D"
        .
    end.

    if can-find(first ttPclie) then do:
        ghProc = lancementPgm("crud/pclie_CRUD.p", poCollectionHandlePgm).
        run setPclie in ghProc(table ttPclie by-reference).
        if mError:erreur() then return.
    end.

end procedure.

procedure suppressionIntnt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define buffer intnt for intnt.
    define buffer imble for imble.

    //suppression du lien mandat Syndic - Immeuble (en dernier car le lien immeuble est utilisé dans les prog de suppressions)
    for first intnt no-lock
        where intnt.tpidt = {&TYPEBIEN-immeuble}
        and   intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
        and   intnt.nocon = giNumeroMandat:
        create ttIntnt.
        buffer-copy intnt except fgpay to ttIntnt
        assign
            ttIntnt.rRowid      = rowid(intnt)
            ttIntnt.dtTimestamp = datetime(intnt.dtmsy, intnt.hemsy)
            ttIntnt.CRUD        = 'D'
        .
        //Immeuble - lots - actes de propriétés
        for first imble exclusive-lock
            where imble.noimm = giNumeroImmeuble:
            imble.norol = 0. //RAZ no syndicat Immeuble
        end.
    end.

    //suppression de tous les autres liens
    for each intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
        and   intnt.nocon = giNumeroMandat:
        delete intnt.
        create ttIntnt.
        buffer-copy intnt except fgpay to ttIntnt
        assign
            ttIntnt.rRowid      = rowid(intnt)
            ttIntnt.dtTimestamp = datetime(intnt.dtmsy, intnt.hemsy)
            ttIntnt.CRUD        = 'D'
        .
    end.
    if can-find(first ttIntnt) then do:
        ghProc = lancementPgm("crud/intnt_CRUD.p", poCollectionHandlePgm).
        run setIntnt in ghProc(table ttIntnt by-reference).
        if mError:erreur() then return.
    end.

end procedure.

procedure suppressionClesRepartition:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    //Suppression des clés du mandat
    if can-find(first clemi no-lock
                where clemi.tpcon = {&TYPECONTRAT-mandat2Syndic}
                  and clemi.nocon = giNumeroMandat) then do:
        ghProc = lancementPgm("crud/clemi_CRUD.p", poCollectionHandlePgm).
        run deleteClemitEtLienSurImmeuble in ghProc({&TYPECONTRAT-mandat2Syndic}, giNumeroMandat).
        if mError:erreur() then return.
    end.

end procedure.

procedure suppressionCtCtt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define buffer ctctt for ctctt.

    //Suppression des contrats travaux
    for each ctctt no-lock
        where   ctctt.TpCt1 = {&TYPECONTRAT-mandat2Syndic}
        and     ctctt.NoCt1 = giNumeroMandat
        and     ctctt.TpCt2 = {&TYPECONTRAT-travaux}:
        /*run VALUE ( RpRunCtt + "DelCtTrx.p" ) (input ctctt.noct2
                                            , input TpSupUse + "|" + TpTrtUse
                                            , output FgRetSup ).*/
    end.

    for each ctctt no-lock
        where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
          and ctctt.noct1 = giNumeroMandat
          and ctctt.tpct2 = {&TYPECONTRAT-assuranceSyndic}:
        /*run VALUE (RpRunCtt + "DelCtAss.p") (input ctctt.tpct2
                                        ,input  ctctt.noct2
                                        ,input TpSupUse + "|" + TpTrtUse
                                        ,output FgRetSup
                                        ,output LbDivSor).*/
        ghProc = lancementPgm("mandat/suppressionContratAssurance.p", poCollectionHandlePgm).
        run SupAssurance in ghProc(table ttError, giNumeroMandat, {&TYPECONTRAT-mandat2Syndic}, gcTypeTrt, input-output poCollectionHandlePgm).
        if mError:erreur() then return.
    end.

    //gestionnaire
    empty temp-table ttCtctt.
    for each ctctt no-lock
        where ctctt.tpct1 = {&TYPECONTRAT-serviceGestion}
          and ctctt.tpct2 = {&TYPECONTRAT-mandat2Syndic}
          and ctctt.noct2 = giNumeroMandat:
        create ttCtctt.
        assign
            ttCtctt.tpct1       = ctctt.tpct1
            ttCtctt.noct1       = ctctt.noct1
            ttCtctt.tpct2       = ctctt.tpct1
            ttCtctt.noct2       = ctctt.noct2
            ttCtctt.CRUD        = "D"
            ttCtctt.dtTimestamp = datetime(ctctt.dtmsy, ctctt.hemsy)
            ttCtctt.rRowid      = rowid(ctctt)
        .
    end.
    //Suppression du Lien Contrat/Contrat
    for each ctctt no-lock
        where ctctt.tpct2 = {&TYPECONTRAT-mandat2Syndic}
        and   ctctt.noct2 = giNumeroMandat:
        create ttCtctt.
        assign
            ttCtctt.tpct1       = ctctt.tpct1
            ttCtctt.noct1       = ctctt.noct1
            ttCtctt.tpct2       = ctctt.tpct1
            ttCtctt.noct2       = ctctt.noct2
            ttCtctt.CRUD        = "D"
            ttCtctt.dtTimestamp = datetime(ctctt.dtmsy, ctctt.hemsy)
            ttCtctt.rRowid      = rowid(ctctt)
        .
    end.
    if can-find(first ttCtctt) then do:
        ghProc = lancementPgm("crud/ctctt_CRUD.p", poCollectionHandlePgm).
        run setCtctt in ghProc(table ttCtctt by-reference).
        if mError:erreur() then return.
    end.
    //Suppression liens résiduels avec les autres contrats
    if can-find(first ctctt no-lock
                where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                  and ctctt.noct1 = giNumeroMandat)
    then do:
        ghProc = lancementPgm("crud/ctctt_CRUD.p", poCollectionHandlePgm).
        run deleteCtcttSurContratPrincipal in ghProc({&TYPECONTRAT-mandat2Syndic}, giNumeroMandat).
        if mError:erreur() then return.
    end.

end procedure.

procedure suppressionContratMandat2Syndic:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define buffer ctrat for ctrat.

    if can-find(first cthis no-lock
                where cthis.tpcon = {&TYPECONTRAT-mandat2Syndic}
                  and cthis.nocon = giNumeroMandat) then do:
        ghProc = lancementPgm("crud/cthis_CRUD.p", poCollectionHandlePgm).
        run deleteCthisSurContrat in ghProc({&TYPECONTRAT-mandat2Syndic}, giNumeroMandat).
        if mError:erreur() then return.
    end.

    if can-find(first rlctt no-lock
                where rlctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                  and rlctt.noct1 = giNumeroMandat) then do:
        ghProc = lancementPgm("crud/rlctt_CRUD.p", poCollectionHandlePgm).
        run deleteRlcttSurContratMaitre in ghProc({&TYPECONTRAT-mandat2Syndic}, giNumeroMandat).
        if mError:erreur() then return.
    end.

    for first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Syndic}
        and   ctrat.nocon = giNumeroMandat:
        empty temp-table ttCtrat.
        create ttCtrat.
        assign
            ttCtrat.tpcon       = ctrat.tpcon
            ttCtrat.nocon       = ctrat.nocon
            ttCtrat.CRUD        = "D"
            ttCtrat.dtTimestamp = datetime(ctrat.dtmsy, ctrat.hemsy)
            ttCtrat.rRowid      = rowid(ctrat)
            ghProc              = lancementPgm("crud/ctrat_CRUD.p", poCollectionHandlePgm)
        .
        run setCtrat in ghProc(table ttCtrat by-reference).
        if mError:erreur() then return.
    end.

end procedure.

procedure suppressionMembresConseilSyndical:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define buffer taint   for taint.

    //Suppression des membres du conseil syndical
    empty temp-table ttMembreConseilSyndical.
    for each taint no-lock
        where taint.tpcon = {&TYPECONTRAT-mandat2Syndic}
        and   taint.nocon = giNumeroMandat:
        delete taint.
        create ttMembreConseilSyndical.
        buffer-copy taint to ttMembreConseilSyndical.
        assign
            ttMembreConseilSyndical.rRowid = rowid(taint)
            ttMembreConseilSyndical.CRUD   = 'D'
        .
    end.
    if can-find(first ttMembreConseilSyndical) then do:
        ghProc = lancementPgm("crud/taint_CRUD.p", poCollectionHandlePgm).
        run setTaint in ghProc(table ttMembreConseilSyndical by-reference).
        if mError:erreur() then return.
    end.

end procedure.

procedure suppressionTaches:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define buffer tache   for tache.

    if can-find(first tache no-lock
                where tache.tpcon = {&TYPECONTRAT-mandat2Syndic}
                  and tache.nocon = giNumeroMandat) then do:
        ghProc = lancementPgm("crud/tache_CRUD.p", poCollectionHandlePgm).
        run deleteTacheSurContrat in ghProc({&TYPECONTRAT-mandat2Syndic}, giNumeroMandat).
        if mError:erreur() then return.
    end.

    if can-find(first cttac no-lock
                where cttac.tpcon = {&TYPECONTRAT-mandat2Syndic}
                  and cttac.nocon = giNumeroMandat) then do:
        ghProc = lancementPgm("crud/cttac_CRUD.p", poCollectionHandlePgm).
        run deleteCttacSurContrat in ghProc({&TYPECONTRAT-mandat2Syndic}, giNumeroMandat).
        if mError:erreur() then return.
    end.

    empty temp-table ttTache.
    for each tache no-lock
        where tache.tptac = {&TYPETACHE-travauxImmeubleSaisieManuelle}
          and tache.tpfin = {&TYPECONTRAT-mandat2Syndic}
          and tache.duree = giNumeroMandat:
        create ttTache.
        assign
            ttTache.tpcon       = tache.tpcon
            ttTache.nocon       = tache.nocon
            ttTache.tptac       = tache.tptac
            ttTache.notac       = tache.notac
            ttTache.CRUD        = "D"
            ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy)
            ttTache.rRowid      = rowid(tache)
        .
    end.
    if can-find(first ttTache) then do:
        ghProc = lancementPgm("crud/tache_CRUD.p", poCollectionHandlePgm).
        run setTache in ghProc(table ttTache by-reference).
        if mError:erreur() then return.
    end.

end procedure.

procedure suppressionDossiersTravauxEtInterventions:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define buffer trdos   for trdos.
    define buffer inter   for inter.

    //Suppression des Dossiers travaux et interventions
    for each trdos no-lock
        where trdos.tpcon = {&TYPECONTRAT-mandat2Syndic}
        and   Trdos.nocon = giNumeroMandat :
        /*{RunPgExp.i
            &Path       = RpRunLibADB
            &Prog       = "'SupTrdos.p'"
            &Parameter  = "INPUT trdos.tpcon
                            , INPUT trdos.nocon
                            , INPUT trdos.nodos
                            , INPUT LbChnEnt
                            ,OUTPUT CdRetUse
                            ,OUTPUT LbChnSor"}*/
    end.
    for each inter no-lock
        where inter.TpCon = {&TYPECONTRAT-mandat2Syndic}
        and   inter.NoCon = giNumeroMandat:
        /*{RunPgExp.i
            &Path       = RpRunLibADB
            &Prog       = "'SupInter.p'"
            &Parameter  = "INPUT inter.tpcon
                            , INPUT inter.nocon
                            , INPUT inter.noint
                            , INPUT LbChnEnt
                            ,OUTPUT CdRetUse
                            ,OUTPUT LbChnSor"}*/
    end.

end procedure.

procedure suppressionImputationsParticulieres:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define buffer entip   for entip.
    define buffer detip   for detip.

    empty temp-table ttEnteteImputationParticuliere.
    for each entip no-lock
        where entip.nocon = giNumeroMandat:
        create ttEnteteImputationParticuliere.
        buffer-copy entip to ttEnteteImputationParticuliere
        assign
            ttEnteteImputationParticuliere.rRowid = rowid(entip)
            ttEnteteImputationParticuliere.crud = "D"
            .
    end.
    if can-find(first ttEnteteImputationParticuliere) then do:
        ghProc = lancementPgm("crud/entip_CRUD.p", poCollectionHandlePgm).
        run setEntip in ghProc(table ttEnteteImputationParticuliere by-reference).
        if mError:erreur() then return.
    end.
    empty temp-table ttDetailImputationParticuliere.
    for each detip no-lock
        where detip.nocon = giNumeroMandat:
        create ttDetailImputationParticuliere.
        buffer-copy detip to ttDetailImputationParticuliere
        assign
            ttDetailImputationParticuliere.rRowid = rowid(detip)
            ttDetailImputationParticuliere.crud = "D"
            .
    end.
    if can-find(first ttDetailImputationParticuliere) then do:
        ghProc = lancementPgm("crud/detip_CRUD.p", poCollectionHandlePgm).
        run setEntip in ghProc(table ttDetailImputationParticuliere by-reference).
        if mError:erreur() then return.
    end.

end procedure.

procedure suppressionAssembleesGenerales:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define buffer eaget   for eaget.

    for each eaget no-lock
        where eaget.tpcon = {&TYPECONTRAT-mandat2Syndic}
        and   eaget.nocon = giNumeroMandat:

        /*run VALUE (RpRunLibADB + "Delassge.p") (input {&TYPECONTRAT-mandat2Syndic}
                                        ,input giNumeroMandat
                                        ,input eaget.noint
                                        ,input TpSupUse + "|" + TpTrtUse
                                        ,output FgRetSup
                                        ,output LbDivSor).*/
    end.

end procedure.

procedure suppressionDossiersMutation:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define buffer ctctt   for ctctt.
    define buffer ctrat   for ctrat.

    for each ctctt no-lock
        where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
        and   ctctt.noct1 = giNumeroMandat
        and   ctctt.tpct2 =  {&TYPECONTRAT-DossierMutation}:

        /*run VALUE (RpRunLibADB + "Deldomut.p") (input {&TYPECONTRAT-mandat2Syndic}
                                        ,input giNumeroMandat
                                        ,input ctctt.tpct2
                                        ,input ctctt.noct2
                                        ,input TpSupUse + "|" + TpTrtUse
                                        ,output FgRetSup
                                        ,output LbDivSor).*/
    end.

    for each ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mutation}
        and   ctrat.nocon >= giNumeroMandat * 100000 + 00001
        and   ctrat.nocon <= giNumeroMandat * 100000 + 99999:
        /*run VALUE (RpRunLibADB + "Delmut00.p") (input {&TYPECONTRAT-mandat2Syndic}
                                        ,input giNumeroMandat
                                        ,input mut_ctrat.tpcon
                                        ,input mut_ctrat.nocon
                                        ,input TpSupUse + "|" + TpTrtUse
                                        ,output FgRetSup
                                        ,output LbDivSor).*/
    end.


end procedure.

procedure suppressionContratsEntretien:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define buffer ctctt   for ctctt.

    for each ctctt no-lock
        where ctctt.TpCt1 = {&TYPECONTRAT-mandat2Syndic}
        and   ctctt.NoCt1 = giNumeroMandat
        and   ctctt.TpCt2 = {&TYPECONTRAT-fournisseur}:

        /*run VALUE (RpRunLibADB + "Delctent.p") (input {&TYPECONTRAT-mandat2Syndic}
                                        ,input giNumeroMandat
                                        ,input ctctt.tpct2
                                        ,input ctctt.noct2
                                        ,input TpSupUse + "|" + TpTrtUse
                                        ,output FgRetSup
                                        ,output LbDivSor).*/
    end.

end procedure.

procedure suppressionMandatSepa:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    if can-find(first mandatSepa no-lock
                where mandatSepa.tpmandat = {&TYPECONTRAT-sepa}
                  and mandatSepa.tpcon    = {&TYPECONTRAT-mandat2Syndic}
                  and mandatSepa.nocon    = giNumeroMandat) then do:
        ghProc = lancementPgm("crud/mandatSEPA_CRUD.p", poCollectionHandlePgm).
        run deleteMandatSepaSurContrat in ghProc({&TYPECONTRAT-sepa}, {&TYPECONTRAT-mandat2Syndic}, giNumeroMandat).
        if mError:erreur() then return.
    end.

end procedure.

procedure suppressionCompensationParLot:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define buffer compenslot for compenslot.

    for each compenslot exclusive-lock
        where compenslot.tpctp = {&TYPECONTRAT-mandat2Syndic}
        and   compenslot.noctp = giNumeroMandat:
        delete compenslot.
    end.

end procedure.

procedure suppressionLienCoproGerance:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define buffer synge   for synge.

    for each synge exclusive-lock
        where synge.tpctp = {&TYPECONTRAT-mandat2Syndic}
        and   synge.noctp = giNumeroMandat:
        delete synge.
    end.

end procedure.
procedure suppressionLienMandatSyndicat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define buffer intnt   for intnt.
    define buffer roles   for roles.
    define buffer iLienAdresse   for iLienAdresse.
    define buffer vbIntnt   for intnt.
    define buffer ctrat   for ctrat.

    for first intnt exclusive-lock
        where intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
        and   intnt.nocon = giNumeroMandat
        and   intnt.tpidt = {&TYPEROLE-syndicat2copro}:
        for first roles exclusive-lock
            where roles.tprol = intnt.tpidt
            and   roles.norol = intnt.noidt
            and   roles.norol <> 1: //ne pas supprimer le role temporaire
            for each iLienAdresse exclusive-lock
                where iLienAdresse.cTypeIdentifiant = roles.tprol
                  and iLienAdresse.iNumeroIdentifiant = roles.norol:
                delete iLienAdresse.
            end.
            //run SupEvenementiel(roles.tprol, roles.norol).
            for each vbIntnt exclusive-lock
                where vbIntnt.tpidt = roles.tprol
                and   vbIntnt.noidt = roles.norol
                and   vbIntnt.tpcon = {&TYPECONTRAT-blocNote}:
                for each ctrat exclusive-lock
                    where ctrat.tpcon = vbIntnt.tpcon
                    and   ctrat.nocon = vbIntnt.nocon:
                    delete ctrat.
                end.
                delete vbIntnt.
            end.
            delete roles.
        end.
        delete intnt.
    end.

end procedure.

procedure suppressionTitreCopropriete:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define buffer ctrat   for ctrat.

    for each ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-titre2copro}
        and   ctrat.nocon >= giNumeroMandat * 100000 + 00001
        and   ctrat.nocon <= giNumeroMandat * 100000 + 99999 :
        ghProc = lancementPgm("adblib/deltitco.p", poCollectionHandlePgm).
        run delTitreCopro in ghProc(ctrat.tpcon, ctrat.nocon, input-output poCollectionHandlePgm).
        if mError:erreur() then return.
    end.

end procedure.
