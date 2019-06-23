/*-----------------------------------------------------------------------------
File        : calindlo.p
Purpose     : calcul des indexations loyer selon les indices (lancé avant le module "calrevlo.p")
              (Copie du module "calrevlo.p" avec suppression de code)
Author(s)   : JC - 1999/06/03, Kantena - 2017/12/21
Notes       : reprise de adb/src/quit/calindlo.p
derniere revue: 2018/04/26 - phm: OK

01 14/06/1999  JC    Suppression des commentaires, des definitions de variables
02 05/04/2004  AF    Module prolongation apres expiration
03 20/10/2004  SY    1004/0063: Ajout stockage dans tache.lbdiv2 du mois de quitt de la quittance dans
                     laquelle a eu lieu la dernière révision (comme tache revision)
04 21/12/2004  SY    1204/0282: Ajout maj loyer contractuel révis + création tache révision pour que le suivi des révisions soit correct
05 24/12/2004  SY    1204/0039: Recalcul montant loyer revisé si il n'y a pas de tache Loyer Contractuel
06 09/11/2007  SY    0607/0148: correction calcul date prochaine révision (addmoidat et non Cl2Datfin) pour conserver le jour (pb 28/02)
07 06/03/2008  SY    0107/0373: AGF Lot 6 - nouveau calcul
08 12/03/2008  SY    0107/0373: AGF Lot 6 - Ajout maj dates révision, indice et flag rev dans les avis d'echéance >= révision
09 04/05/2011  PL    0411/0180: Pb de calcul du loyer révisé
10 23/05/2011  SY    0511/0138: Pb nouvelle zone révision fgidxconv pas mise à jour (c.f. fiche 0908/0110)
                     + création ligne de traitement dans revtrt lors d'une révision
-----------------------------------------------------------------------------*/
{preprocesseur/nature2contrat.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}

using parametre.pclie.parametrageRubriqueDepotGarantie.
using parametre.pclie.parametrageProlongationExpiration.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{application/include/glbsepar.i}
{bail/include/equit.i &nomtable=ttqtt}
{bail/include/tmprub.i}
{tache/include/tache.i}

define input  parameter pcTypeBail         as character no-undo.
define input  parameter piNumeroBail       as int64     no-undo.
define input  parameter piNumeroTraitement as integer   no-undo.
define input  parameter pdaDebutPeriode    as date      no-undo.
define input  parameter pdaFinPeriode      as date      no-undo.
define input-output parameter table for ttQtt.
define input-output parameter table for ttRub.
define output parameter pcCodeRetour       as character no-undo initial "00".

define variable gdeTauxRevision      as decimal  no-undo.
define variable gdeValeurRevision    as decimal  no-undo.
define variable gdaDateRevision      as date     no-undo.
define variable giMoisTraitement     as integer  no-undo.
define variable giNombreMois         as integer  no-undo.
define variable gdeNvoLoyer          as decimal  no-undo.
define variable ghProcTache          as handle   no-undo.
define variable ghProcIndiceRevision as handle   no-undo.
define variable ghProcAlimaj         as handle   no-undo.
define variable goCollection             as class collection                        no-undo.
define variable goProlongationExpiration as class parametrageProlongationExpiration no-undo.

run tache/tache.p persistent set ghProcTache.
run getTokenInstance in ghProcTache(mToken:JSessionId).
run adblib/indiceRevision_CRUD.p persistent set ghProcIndiceRevision.
run getTokenInstance in ghProcIndiceRevision(mToken:JSessionId).
run application/transfert/gi_alimaj.p persistent set ghProcAlimaj.
run getTokenInstance in ghProcAlimaj(mToken:JSessionId).
goProlongationExpiration = new parametrageProlongationExpiration().
run calindloPrivate.
run destroy in ghProcTache.
run destroy in ghProcAlimaj.
run destroy in ghProcIndiceRevision.
delete object goProlongationExpiration no-error.

function lecTacInd returns logical:
    /*-------------------------------------------------------------------------
    Purpose : lecture de la tache indexation loyer
    Notes   :
    -------------------------------------------------------------------------*/
    empty temp-table ttTache.
    run getTache in ghProcTache(pcTypeBail, piNumeroBail, {&TYPETACHE-indexationLoyer}, table ttTache by-reference).
    find first ttTache no-error.
    return not available ttTache.
end function.

function recDatBai returns logical(output pcNatureContrat as character, output piNumeroDoc as integer):
    /*----------------------------------------------------------------------------
    Purpose : recherche date fin bail ou date résiliation contrat.
    Notes   :
    ----------------------------------------------------------------------------*/
    define buffer ctrat for ctrat.
    for first ctrat no-lock
        where ctrat.tpcon = pcTypeBail
          and ctrat.nocon = piNumeroBail:
        assign
            pcNatureContrat = ctrat.ntcon
            piNumeroDoc     = ctrat.nodoc
        .
        if (ctrat.dtree <> ? and ctrat.dtree < ttTache.dtfin)          /* Date de resiliation du contrat bail. */
        or (ctrat.TpRen <> "00001"                                     /* Si pas Tacite reconduction: tester Expiration */
            and not goProlongationExpiration:isQuittancementProlonge() /* Uniquement si module prolongation apres expiration non ouvert */
            and ctrat.dtfin < ttTache.dtfin)
        then return true.                            /* pas de revision */
        return false.                                /* revision */
    end.
    return true.                                     /* pas de revision */
end function.

procedure calindloPrivate private:
    /*-------------------------------------------------------------------------
    Purpose :
    Notes   :
    -------------------------------------------------------------------------*/
    define variable vcNatureContrat  as character no-undo.
    define variable viNumeroDocument as integer   no-undo.
    define variable viNumeroIndice   as integer   no-undo.
    define buffer bxrbp for bxrbp.

    if lecTacInd()                                                              /* Lecture de la tâche indexation loyer */
    or recDatBai(output vcNatureContrat, output viNumeroDocument) then return.  /* Recherche de la date de fin du contrat bail ou date de résiliation du contrat. */

    /* Recuperation du taux d'indexation */
    run recTauInd.
    /* Calcule de la date d'indexation. */
    run calPrcDat.
    /* Creation d'un nouveau calendrier ou d'une nouvelle echelle (Application du taux d'indexation sur chaque montant)
       puis recalcul des montants loyer pour chaque mois de quit avec le nouveau calendrier genere */
    goCollection = new collection().
    goCollection:set("cTypeContrat", pcTypeBail).                // tpBailUse-in
    goCollection:set("i64NumeroContrat", piNumeroBail).          // NoBaiUse-IN
    goCollection:set("TxIndLoy10000", gdeTauxRevision * 10000).  // TxIndLoy * 10000
    goCollection:set("daIndexation", ttTache.dtfin).             // DtPrcInd
    goCollection:set("TxIndLoy", gdeTauxRevision * 10000000000). // TxIndLoy * 10000000000
    goCollection:set("lRegularisation", false).
    goCollection:set("cTypeTraitement", "CALID").
    goCollection:set("iNumeroTraitement", piNumeroTraitement).   // NoQttUse-IN
    goCollection:set("daDebutPeriode", pdaDebutPeriode).         // DtDebPer-IN
    goCollection:set("daFinPeriode", pdaFinPeriode).             // DtFinPer-IN
    if ttTache.cdhon = {&TYPETACHE-calendrierEvolutionLoyer}
    then run adb/calcalid.p(goCollection).        /* Calendrier d'evolution des loyers */
    else run adb/calechid.p(                      /* Echelle mobile des loyers         */
        pcTypeBail, piNumeroBail, gdeTauxRevision * 10000, ttTache.dtfin, input-output table ttQtt by-reference, input-output table ttRub by-reference
    ).

    /* Recherche du mois de quitt de la revision */
    viNumeroIndice = integer(string(ttTache.ntreg, "99") + string(integer(ttTache.cdreg) + ttTache.duree, "9999")).
    for first ttQtt
        where ttQtt.NoLoc = piNumeroBail
          and ttQtt.NoQtt = piNumeroTraitement:
        assign
            ttQtt.cdrev       = "00002"              /*locataire ayant subi une révision auto.*/
            ttQtt.dtrev       = gdaDateRevision
            ttQtt.dtprv       = today
            ttQtt.noidc       = viNumeroIndice
            giMoisTraitement = ttQtt.msqtt
            giNombreMois      = integer(substring(ttQtt.pdqtt, 1, 3, "character"))
            gdeNvoLoyer       = 0
        .
        /* Montant loyer révisé (Majloyqt déjà appelé) */
        for each ttRub
            where ttRub.NoLoc = ttQtt.NoLoc
              and ttRub.NoQtt = ttQtt.NoQtt
              and ttRub.cdgen = "00001"
         , first bxrbp no-lock
            where bxrbp.ntbai = ttQtt.ntbai
              and bxrbp.norub = ttRub.norub
              and bxrbp.nolib = ttRub.nolib
              and bxrbp.prg02 = "00001"
              and bxrbp.cdfam < 2: /* PL : 0411/0180 le 04/05/2011 Je ne sais pas s'il faut aussi ajouter la notion de rubrique 111 et 114 pour Méhaignerie */
            gdeNvoLoyer = gdeNvoLoyer + ttRub.mttot.
        end.
    end.
    /* Ajout SY le 12/03/2008 */
    for each ttQtt
        where ttQtt.NoLoc = piNumeroBail
          and ttQtt.NoQtt > piNumeroTraitement:
        assign
            ttQtt.cdmaj = 1
            ttQtt.dtrev = gdaDateRevision
            ttQtt.dtprv = today
            ttQtt.noidc = viNumeroIndice
        .
    end.
    /* Creation de la prochaine tache Indexation ET de la prochaine tache Revision */
    run creTacInd("0", ttTache.dtfin, gdaDateRevision, viNumeroDocument).
end procedure.

procedure creTacInd:
    /*----------------------------------------------------------------------------
    Purpose : Procedure de création de la prochaine table tache (Indexation loyer).
    Notes   : + tache révision pour suivre l'historique
    ----------------------------------------------------------------------------*/
    define input parameter pcLibelle        as character no-undo.
    define input parameter pdaPrecedente    as date      no-undo.
    define input parameter pdaSuivante      as date      no-undo.
    define input parameter piNumeroDocument as integer   no-undo.
    define buffer tache   for tache.
    define buffer vbTache for tache.
    define buffer revtrt  for revtrt.
    define buffer indrv   for indrv.

    define variable vdeMontantRevision  as decimal   no-undo.
    define variable viNextEtape         as integer   no-undo initial 1.
    define variable vcPeriodeTraitement as character no-undo.
    define variable viNombreMois        as integer   no-undo.
    define variable vcLibelleIndice     as character no-undo.

    run getLibelleIndice in ghProcIndiceRevision("3", integer(ttTache.cdreg) + ttTache.duree, ttTache.ntreg, "c", output vcLibelleIndice).
    assign
        ttTache.lbdiv  = substitute("&1&&&2#&3#&4", entry(1, ttTache.lbdiv, "&"), vcLibelleIndice, gdeValeurRevision, gdeTauxRevision)
        ttTache.tptac  = {&TYPETACHE-indexationLoyer}
        ttTache.dtdeb  = pdaPrecedente
        ttTache.dtfin  = pdaSuivante
        ttTache.cdreg  = string(integer(ttTache.cdreg) + ttTache.duree)
        ttTache.mtreg  = 0
        ttTache.utreg  = pcLibelle
        ttTache.lbdiv2 = string(giMoisTraitement)
        ttTache.dtreg  = today
        ttTache.crud   = "C"
    .
    /* Création nouvel enregistrement indexation loyer */
    run setTache in ghProcTache(table ttTache by-reference).
    /*--> Mise a jour de la tache 'loyer contractuel' */
    for first ttTache
      , first tache exclusive-lock
        where tache.tptac = {&TYPETACHE-loyerContractuel}
          and tache.tpcon = ttTache.tpcon
          and tache.nocon = ttTache.nocon:
        assign
            vdeMontantRevision = (tache.mtreg * gdeTauxRevision) / 100
            tache.mtreg        = round(tache.mtreg + vdeMontantRevision, 2)
            gdeNvoLoyer        = round((tache.mtreg / 12) * giNombreMois, 2)
        .
    end.
    /* Création tache révision pour suivi */
    for first ttTache
      , last tache no-lock
        where tache.tpcon = ttTache.tpcon
          and tache.nocon = ttTache.nocon
          and tache.tptac = {&TYPETACHE-revision}:
        assign
            ttTache.lbdiv     = substitute("&1&&&2#&3#&4&5",
                                    entry(1, tache.lbdiv, "&"), vcLibelleIndice, gdeValeurRevision, gdeTauxRevision,
                                    if num-entries(tache.lbdiv, "&") > 2 then "&" + entry(3, tache.lbdiv, "&") else "")
            ttTache.tptac     = {&TYPETACHE-revision}
            ttTache.tpfin     = tache.tpfin
            ttTache.duree     = tache.duree
            ttTache.ntges     = tache.ntges
            ttTache.tpges     = tache.tpges
            ttTache.pdges     = tache.pdges
            ttTache.cdreg     = string(integer(ttTache.cdreg) + ttTache.duree)
            ttTache.mtreg     = gdeNvoLoyer
            ttTache.utreg     = "0"
            ttTache.dtreg     = today
            ttTache.tphon     = tache.tphon
            ttTache.cdhon     = tache.cdhon
            ttTache.lbdiv2    = string(giMoisTraitement)
            ttTache.lbmotif   = tache.lbmotif
            ttTache.fgidxconv = tache.fgidxconv
            ttTache.crud      = "C"
        .
        run setTache in ghProcTache(table ttTache by-reference).
    end.
    /* Ajout SY le 23/05/2011 : création ligne de traitement */
    {&_proparse_ prolint-nowarn(wholeindex)}
    find last revtrt no-lock no-error.
    if available revtrt then viNextEtape = revtrt.inotrtrev + 1.

    for first ttTache            // récupère les champ ttTache.noita et ttTache.notac
      , first tache no-lock
        where tache.noita = ttTache.noita:
        find last vbTache no-lock
            where vbTache.tpcon = tache.tpcon
              and vbTache.nocon = tache.nocon
              and vbTache.tptac = {&TYPETACHE-quittancement} no-error.
        if available vbTache then vcPeriodeTraitement = vbTache.pdges.
        create revtrt.
        assign
            revtrt.inotrtrev = viNextEtape
            revtrt.tpcon = tache.tpcon
            revtrt.nocon = tache.nocon
            revtrt.cdtrt = "00300"        /* traitement des révisions (c.f. RVCTR) */
            revtrt.notrt = tache.notac    /* No ordre traitement */
            revtrt.cdact = "00301"        /* Indexation automatique (c.f. RVCAC) */
            revtrt.dtdeb = tache.dtdeb
            revtrt.dtfin = tache.dtcsy    /* date du traitement de l'action */
            revtrt.msqtt = integer(tache.lbdiv2)
            revtrt.cdirv = integer(tache.dcreg)
            revtrt.anirv = integer(tache.cdreg)
            revtrt.noirv = integer(tache.ntreg)
            revtrt.lbcom = substitute("Révision traitée le &1 à &2&3taux de révision = &4%",
                                      string(tache.dtcsy, "99/99/9999"), string(tache.hecsy, "HH:MM:SS"), separ[1], gdeTauxRevision)
            revtrt.tprol = tache.tptac
            revtrt.norol = tache.noita
            revtrt.dtcsy = today
            revtrt.hecsy = time
            revtrt.cdcsy = mToken:cUser + "calindlo.p"
        .
        find first indrv no-lock
            where indrv.cdirv = revtrt.cdirv
              and indrv.anper = revtrt.anirv
              and Indrv.noper = revtrt.noirv no-error.
        if available indrv then revtrt.vlirv = indrv.vlirv.
        /* montant loyer */
        viNombreMois = integer(substring(vcPeriodeTraitement, 1, 3, "character")).
        if viNombreMois <> 0 then revtrt.mtloyann = round((12 / viNombreMois) * gdeNvoLoyer, 2).
        /* Taux de la révision */
        revtrt.tphis = string(gdeTauxRevision).
        mLogger:writeLog(9, substitute("Revision auto calendrier - locataire &1 - &2 Date de révision &3 Indice &4-&5/&6 taux = &7 mois de quitt = &8",
                            tache.tpcon, tache.nocon, string(tache.dtdeb, "99/99/9999"),
                            revtrt.cdirv, revtrt.anirv, revtrt.noirv, gdeTauxRevision, tache.lbdiv2)).

    end.
    /*--> Flager le bail pour MAJ lors du transfert */
    run majTrace in ghProcAlimaj(integer(mToken:cRefGerance), 'SADB', 'ctrat', string(piNumeroDocument, '>>>>>>>>9')).    // NoRefGer remplacé par
end procedure.

procedure recTauInd:
    /*----------------------------------------------------------------------------
    Purpose : récupération du taux d'indexation.
    Notes
    -----------------------------------------------------------------------------*/
    define variable voCollectionIndice as class collection no-undo.

    if ttTache.duree = 1 then do:
        run readIndiceRevision2 in ghProcIndiceRevision(ttTache.dcreg, integer(ttTache.cdreg), ttTache.ntreg, ttTache.duree, output voCollectionIndice).
        if voCollectionIndice:getLogical("lTrouve")
        then assign
            gdeValeurRevision = voCollectionIndice:getDecimal("dValeurRevision")
            gdeTauxRevision   = voCollectionIndice:getDecimal("dTauxRevision")
        .
        delete object voCollectionIndice.
    end.
    if ttTache.duree > 1 then do:
        run readIndiceRevision3 in ghProcIndiceRevision(ttTache.dcreg, integer(ttTache.cdreg) + ttTache.duree, ttTache.ntreg, ttTache.duree, output voCollectionIndice).
        if voCollectionIndice:getLogical("lTrouve")
        then assign
            gdeValeurRevision = voCollectionIndice:getDecimal("dValeurRevision")
            gdeTauxRevision   = voCollectionIndice:getDecimal("dTauxRevision")
        .
        delete object voCollectionIndice.
    end.
end procedure.

procedure calPrcDat:
    /*----------------------------------------------------------------------------
    Purppose : Procedure de mise à jour des dates de révision.
    Notes    :
    ----------------------------------------------------------------------------*/
    define variable viNombreMois    as integer    no-undo.
    assign
        viNombreMois    = if ttTache.pdreg = '00001' then 12 * ttTache.duree else ttTache.duree
        gdaDateRevision = add-interval(ttTache.dtfin, viNombreMois, "months")
    .
end procedure.
