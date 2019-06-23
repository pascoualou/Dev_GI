/*-----------------------------------------------------------------------------
File        : calindlo.p
Purpose     : calcul des indexations loyer selon les indices (lancé avant le module "calrevlo.p")
              (Copie du module "calrevlo.p" avec suppression de code)
Author(s)   : JC - 1999/06/03, Kantena - 2017/12/21
Notes       : reprise de adb/src/quit/calindlo.p
derniere revue: 2018/09/13 - phm: 

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
{oerealm/include/instanciateTokenOnModel.i}          // Doit être positionnée juste après using
{application/include/glbsepar.i}
{bail/include/tbtmpqtt.i}
{bail/include/tbtmprub.i}
{tache/include/tache.i}

{outils/include/lancementProgramme.i}                // fonctions lancementPgm, suppressionPgmPersistent
{bail/quittancement/procedureCommuneQuittance2.i}    // fonctions dateFinBail, chgTaux

define variable goCollectionHandlePgm    as class collection no-undo.
define variable goCollectionContrat      as class collection no-undo.
define variable goCollectionQuittance    as class collection no-undo.
define variable goProlongationExpiration as class parametrageProlongationExpiration no-undo.
define variable ghProc               as handle    no-undo.
define variable gcTypeBail           as character no-undo.
define variable giNumeroBail         as int64     no-undo.
define variable giNumeroQuittance    as integer   no-undo.
define variable gdaDebutPeriode      as date      no-undo.
define variable gdaFinPeriode        as date      no-undo.
define variable gdeTauxRevision      as decimal   no-undo.
define variable gdeValeurRevision    as decimal   no-undo.
define variable gdaDateRevision      as date      no-undo.
define variable giMoisTraitement     as integer   no-undo.
define variable giNombreMois         as integer   no-undo.
define variable gdeNvoLoyer          as decimal   no-undo.
define variable ghProcTache          as handle    no-undo.
define variable ghProcIndiceRevision as handle    no-undo.
define variable ghProcAlimaj         as handle    no-undo.

procedure lancementCalindlo:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   : service externe
    ------------------------------------------------------------------------*/
    define input parameter poCollectionContrat   as class collection no-undo.    
    define input parameter poCollectionQuittance as class collection no-undo.
    define input-output parameter table for ttQtt.
    define input-output parameter table for ttRub.
   
    assign
        gcTypeBail                 = poCollectionContrat:getCharacter("cTypeContrat")
        giNumeroBail               = poCollectionContrat:getInt64("iNumeroContrat")
        giNumeroQuittance          = poCollectionQuittance:getInteger("iNumeroQuittance")
        gdaDebutPeriode            = poCollectionQuittance:getDate("daDebutPeriode")
        gdaFinPeriode              = poCollectionQuittance:getDate("daFinPeriode")
        goCollectionContrat        = poCollectionContrat
        goCollectionQuittance      = poCollectionQuittance
        goCollectionHandlePgm      = new collection()
        goProlongationExpiration   = new parametrageProlongationExpiration()
    .

message "lancementCalindlo " gcTypeBail "/" giNumeroBail "/" giNumeroQuittance "/" gdaDebutPeriode "/" gdaFinPeriode .

    assign
        ghProcTache          = lancementPgm("crud/tache_CRUD.p", goCollectionHandlePgm)
        ghProcIndiceRevision = lancementPgm("crud/indrv_CRUD.p", goCollectionHandlePgm)
        ghProcAlimaj         = lancementPgm("application/transfert/gi_alimaj.p", goCollectionHandlePgm)
    .
    run calindloPrivate.
    delete object goProlongationExpiration no-error.
    suppressionPgmPersistent(goCollectionHandlePgm).

end procedure.

function lectureTacheIndexation returns logical private:
    /*-------------------------------------------------------------------------
    Purpose : lecture de la tache indexation loyer
    Notes   :
    -------------------------------------------------------------------------*/
    define buffer tache for tache.
    empty temp-table ttTache.
    for last tache no-lock
        where tache.tpcon = gcTypeBail
          and tache.nocon = giNumeroBail
          and tache.tptac = {&TYPETACHE-indexationLoyer}:
        create ttTache.
        outils:copyValidField(buffer tache:handle, buffer ttTAche:handle).
    end.
    return can-find(first ttTache).
end function.

function recDatBai returns logical private(output pcNatureContrat as character, output piNumeroDoc as integer):
    /*----------------------------------------------------------------------------
    Purpose : recherche date fin bail ou date résiliation contrat.
    Notes   :
    ----------------------------------------------------------------------------*/
    define buffer ctrat for ctrat.
    for first ctrat no-lock
        where ctrat.tpcon = gcTypeBail
          and ctrat.nocon = giNumeroBail:
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
    define variable vlIndParu        as logical   no-undo.
    define buffer bxrbp for bxrbp.

    if not lectureTacheIndexation()                                             /* Lecture de la tâche indexation loyer */
    or recDatBai(output vcNatureContrat, output viNumeroDocument) then return.  /* Recherche de la date de fin du contrat bail ou date de résiliation du contrat. */

    /* Recuperation du taux d'indexation */
    run chgTaux(integer(ttTache.dcreg), 
                integer(ttTache.cdreg), 
                integer(ttTache.ntreg), 
                ttTache.duree, 
                output gdeValeurRevision, 
                output gdeTauxRevision,
                output vlIndParu).
    /* Calcule de la date d'indexation. */
    run calPrcDat.
    /* Creation d'un nouveau calendrier ou d'une nouvelle echelle (Application du taux d'indexation sur chaque montant)
       puis recalcul des montants loyer pour chaque mois de quit avec le nouveau calendrier genere */
    goCollectionQuittance:set("TxIndLoy10000", gdeTauxRevision * 10000).  // TxIndLoy * 10000
    goCollectionQuittance:set("daIndexation", ttTache.dtfin).             // DtPrcInd
    goCollectionQuittance:set("TxIndLoy", gdeTauxRevision * 10000000000). // TxIndLoy * 10000000000
    goCollectionQuittance:set("lRegularisation", false).
    goCollectionQuittance:set("cTypeTraitement", "CALID").
    goCollectionQuittance:set("iNumeroTraitement", giNumeroQuittance).   // NoQttUse-IN
    if ttTache.cdhon = {&TYPETACHE-calendrierEvolutionLoyer}
    then do:
        ghProc = lancementPgm("bail/quittancement/calcalid.p", goCollectionHandlePgm).
        run lancementCalcalid in ghProc (goCollectionContrat, goCollectionQuittance, input-output table ttQtt by-reference, input-output table ttRub by-reference).
    end.
    else do:
        ghProc = lancementPgm("bail/quittancement/calechid.p", goCollectionHandlePgm).
        run lancementCalechid in ghProc (gcTypeBail, 
                                         giNumeroBail, 
                                         gdeTauxRevision * 10000, 
                                         ttTache.dtfin, 
                                         input-output table ttQtt by-reference, input-output table ttRub by-reference ).
    end.

    /* Recherche du mois de quitt de la revision */
    viNumeroIndice = integer(ttTache.ntreg) * 10000 + integer(ttTache.cdreg) + ttTache.duree.    // integer(string(ttTache.ntreg, "99") + string(integer(ttTache.cdreg) + ttTache.duree, "9999")).
    for first ttQtt
        where ttQtt.iNumeroLocataire = giNumeroBail
          and ttQtt.iNoQuittance = giNumeroQuittance:
        assign
            ttQtt.cCodeRevisionDeLaQuittance       = "00002"              /*locataire ayant subi une révision auto.*/
            ttQtt.daProchaineRevision       = gdaDateRevision
            ttQtt.daTraitementRevision       = today
            ttQtt.iPeriodeAnneeIndiceRevision       = viNumeroIndice
            giMoisTraitement = ttQtt.iMoisTraitementQuitt
            giNombreMois      = integer(substring(ttQtt.cPeriodiciteQuittancement, 1, 3, "character"))
            gdeNvoLoyer       = 0
        .
        /* Montant loyer révisé (Majloyqt déjà appelé) */
        for each ttRub
            where ttRub.iNumeroLocataire = ttQtt.iNumeroLocataire
              and ttRub.iNoQuittance = ttQtt.iNoQuittance
              and ttRub.cCodeGenre = "00001"
         , first bxrbp no-lock
            where bxrbp.ntbai = ttQtt.cNatureBail
              and bxrbp.norub = ttRub.iNorubrique
              and bxrbp.nolib = ttRub.iNoLibelleRubrique
              and bxrbp.prg02 = "00001"
              and bxrbp.cdfam < 2:
            gdeNvoLoyer = gdeNvoLoyer + ttRub.dMontantTotal.
        end.
    end.
    /* Ajout SY le 12/03/2008 */
    for each ttQtt
        where ttQtt.iNumeroLocataire = giNumeroBail
          and ttQtt.iNoQuittance > giNumeroQuittance:
        assign
            ttQtt.cdmaj = 1
            ttQtt.daProchaineRevision = gdaDateRevision
            ttQtt.daTraitementRevision = today
            ttQtt.iPeriodeAnneeIndiceRevision = viNumeroIndice
        .
    end.
    /* Creation de la prochaine tache Indexation ET de la prochaine tache Revision */
    run creTacInd("0", ttTache.dtfin, gdaDateRevision, viNumeroDocument).
end procedure.

procedure creTacInd private:
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
    define variable vcDdreg             as character no-undo.
    define variable vcNtreg             as character no-undo.
    define variable vcPdreg             as character no-undo.
    define variable vcDcreg             as character no-undo.

    run getLibelleIndiceSurPeriodicite in ghProcIndiceRevision(3, integer(ttTache.cdreg) + ttTache.duree, ttTache.ntreg, "l", output vcLibelleIndice).
    /* Création nouvel enregistrement indexation loyer */
    assign             // on est positionne sur ttTache lu dans fonction lectureTacheIndexation donc on conserve l'enregistrement en changeant les infos necessaires pour creation nouvelle tache
        vcDdreg           = string(integer(ttTache.cdreg) + ttTache.duree)
        vcNtreg           = ttTache.ntreg
        vcPdreg           = ttTache.pdreg
        vcDcreg           = ttTache.dcreg
        ttTache.notac     = 0
        ttTache.lbdiv     = substitute("&1&&&2#&3#&4", entry(1, ttTache.lbdiv, "&"), vcLibelleIndice, gdeValeurRevision, gdeTauxRevision)
        ttTache.lbdiv-dev = ttTache.lbdiv 
        ttTache.dtdeb     = pdaPrecedente
        ttTache.dtfin     = pdaSuivante
        ttTache.cdreg     = string(integer(ttTache.cdreg) + ttTache.duree)
        ttTache.mtreg     = 0
        ttTache.utreg     = pcLibelle
        ttTache.lbdiv2    = string(giMoisTraitement)
        ttTache.dtreg     = today
        ttTache.crud      = "C"     
    .
    /*--> Mise a jour de la tache 'loyer contractuel' */
    for first tache no-lock
        where tache.tpcon = gcTypeBail
          and tache.nocon = giNumeroBail
          and tache.tptac = {&TYPETACHE-loyerContractuel}:
        create ttTache.
        assign
            ttTache.noita       = tache.noita
            ttTache.tpcon       = tache.tpcon
            ttTache.nocon       = tache.nocon
            ttTache.tptac       = tache.tptac
            ttTache.notac       = tache.notac
            ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy)
            ttTache.CRUD        = 'U'
            ttTache.rRowid      = rowid(tache)
            vdeMontantRevision  = (tache.mtreg * gdeTauxRevision) / 100
            ttTache.mtreg       = round(tache.mtreg + vdeMontantRevision, 2)
            gdeNvoLoyer         = round((ttTache.mtreg / 12) * giNombreMois, 2)
        .
    end.
    /* Création tache révision pour suivi */
    for last tache no-lock
       where tache.tpcon = gcTypeBail
         and tache.nocon = giNumeroBail
         and tache.tptac = {&TYPETACHE-revision}:
        create ttTache.
        assign 
            ttTache.noita     = 0
            ttTache.tpcon     = tache.tpcon
            ttTache.nocon     = tache.nocon
            ttTache.tptac     = tache.tptac
            ttTache.notac     = 0
            ttTache.CRUD      = 'C'
            ttTache.dtdeb     = pdaPrecedente
            ttTache.dtfin     = pdaSuivante
            ttTache.tpfin     = tache.tpfin
            ttTache.duree     = tache.duree           
            ttTache.ntges     = tache.ntges
            ttTache.tpges     = tache.tpges
            ttTache.pdges     = tache.pdges
            ttTache.cdreg     = vcDdreg
            ttTache.ntreg     = vcNtreg
            ttTache.pdreg     = vcPdreg
            ttTache.dcreg     = vcDcreg
            ttTache.dtreg     = today
            ttTache.mtreg     = gdeNvoLoyer
            ttTache.utreg     = "0"
            ttTache.tphon     = tache.tphon
            ttTache.cdhon     = tache.cdhon
            ttTache.lbdiv     = substitute("&1&&&2#&3#&4&5",
                                    entry(1, tache.lbdiv, "&"), vcLibelleIndice, gdeValeurRevision, gdeTauxRevision,
                                    if num-entries(tache.lbdiv, "&") > 2 then "&" + entry(3, tache.lbdiv, "&") else "")
            ttTache.lbdiv-dev = ttTache.lbdiv
            ttTache.lbdiv2    = string(giMoisTraitement)
            ttTache.lbmotif   = tache.lbmotif
            ttTache.fgidxconv = tache.fgidxconv
        .
    end.
    run setTache in ghProcTache(table ttTache by-reference).

    /* Ajout SY le 23/05/2011 : création ligne de traitement */
    {&_proparse_ prolint-nowarn(wholeindex)}
    find last revtrt no-lock no-error.
    if available revtrt then viNextEtape = revtrt.inotrtrev + 1.

    for first ttTache            // récupère les champ ttTache.noita et ttTache.notac
        where ttTache.tptac = {&TYPETACHE-revision}
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
            revtrt.lbcom = outilFormatage:fSubst(outilTraduction:getLibelle(1000857), substitute("&2&1&3&1&4", separ[1], string(tache.dtcsy, "99/99/9999"), string(tache.hecsy, "HH:MM:SS"), gdeTauxRevision)) //Révision traitée le &1 à &2 taux de révision = &3%"  
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

procedure calPrcDat private:
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
