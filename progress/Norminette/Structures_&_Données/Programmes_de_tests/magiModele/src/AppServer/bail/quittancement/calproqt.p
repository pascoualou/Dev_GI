/*-----------------------------------------------------------------------------
File        : calproqt.p
Purpose     : Module de calcul du prorata sur les rubriques fixes d'une quittance donnée
Author(s)   : Kantena - 2017/12/15
Notes       : reprise de adb/quit/calproqt.p
derniere revue: 2018/09/13 - phm: OK

01 10/12/1996  SP    Correction problème détecté en cours de test (fiche 700)
02 02/01/1997  SC    Fiche 743: On ne prorate pas les rubriques de type Administratif (Famille 4).
03 06/01/1997  SP    Affectation du code retour
04 03/04/1997  SY    Modification du test de détection de la Maj des proratas (dtdeb/dtfin -> dtdpr/dtfpr)
05 28/05/1997  SP    Correction calcul du prorata dans MajProQtt avec ttQtt.iNumerateurProrata et ttQtt.iDenominateurProrata
                     Modification du module suite à l'affectation de la date de sortie des quittances
06 21/01/1998  SC    Modification philosiphie du Module: Le prorata ne se fait que si il y a une date de sortie dans la Tâche Quittancement
                     ou que le Bail à été effectivement résilié...
07 29/09/1998  LG    Mettre à jour ttQtt.cdmaj = 1 dès que l'on effectue ou supprime un prorata.
08 11/03/1999  SY    Fiche 2416: si pas tacite reconduction, utilisation de dtfin pour prorata
09 18/03/1999  SY    Fiche 2514: Correction perte info prorata dans le cas du toggle prorata 'décoché'
10 18/06/1999  SY/LG Pb gestion prorata: il faut gérer les 2 cas:
                         1) forçage prorata si résiliation...
                         2) prorata décoché (=> nlle valeur cdpro=-1)
11 06/10/2000  JC    Manpower: On ne tient plus compte de la date de fin de bail (ctrat.dtfin) pour calculer le prorata
12 21/10/2002  SY    Fiche 0802/0059: Correction gestion gdaFinMaximum si pas de tacite rec: il faut tjrs tenir compte de la date de fin de bail
13 05/04/2004  AF    Module Prolongation apres expiration
14 25/06/2004  EK    Fiche 0604/0307: Les rubriques Administratif 651,652,655 et 685 peuvent être proratées
15 10/07/2006  SY    0706/0059: La rubrique Administratif 650 peut être proratée
16 23/04/2007  SY    0307/0174: Stockage de la date de sortie dans ttQtt.daSortie (gdaSortieLocataire)
17 03/07/2008  MB    0408/0174 rub proratées
18 27/04/2009  SY    0209/0180 Nlles rub proratées: 659 et 695
19 09/12/2009  SY    1209/0006 Il ne faut pas appliquer de prorata sur rub loyer si bail soumis à calendrier
20 29/01/2009  SY    1108/0443 ICADE - rub Hono 8xx FIXES, ne pas prorater les rub hono cab si elles sont associées à une ancienne rub Administ 04 "non proratisable"
21 09/06/2010  SY    0610/0058 Modif test rub à prorater: utilisation include PrRubHol.i (IsRubProCum) PAS de proratas Prime Assurance (506 & 821)
22 07/07/2010  SY    0710/0034 Modif IsRubProCum: PAS de proratas pour Pack Services (834)
23 03/10/2012  SY    0912/0140 Ajout contrôles sur les dates début/fin période pour éviter les div par 0
24 11/01/2013  SY    0113/0028 modif IsRubProCum
25 18/01/2013  SY    0113/0028 modif IsRubProCum (prm HOLOQ)
-----------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/referenceClient.i}
{preprocesseur/codeTaciteReconduction.i}
{preprocesseur/profil2rubQuit.i}

using parametre.pclie.parametrageRubriqueQuittHonoCabinet.

{oerealm/include/instanciateTokenOnModel.i}          // Doit être positionnée juste après using
{bail/include/tbtmpqtt.i}
{bail/include/tbtmprub.i}

define variable goCollectionHandlePgm as class     collection no-undo.
define variable ghProc                as handle    no-undo.
define variable gcTypeContrat         as character no-undo.
define variable giNumeroContrat       as int64     no-undo.
define variable giNumeroQuittance     as integer   no-undo.

{outils/include/lancementProgramme.i}                // fonctions lancementPgm, suppressionPgmPersistent
{comm/include/prrubhol.i}                            // procedures isRubEcla, isRubProCum, valDefProCum8xx

procedure lancementCalproqt:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   : service externe
    ------------------------------------------------------------------------*/
    define input parameter poCollectionContrat as class collection no-undo.
    define input-output parameter poCollectionQuittance as class collection no-undo.
    define input-output parameter table for ttQtt.
    define input-output parameter table for ttRub.
    define variable vdaFinQuittancement as date no-undo.

    assign
        gcTypeContrat         = poCollectionContrat:getCharacter("cTypeContrat")
        giNumeroContrat       = poCollectionContrat:getInt64("iNumeroContrat")
        giNumeroQuittance     = poCollectionQuittance:getInteger("iNumeroQuittance")
        vdaFinQuittancement   = poCollectionQuittance:getDate("daFinQuittancement")
        goCollectionHandlePgm = new collection()
    .
    run calproqtPrivate(input-output vdaFinQuittancement).
    poCollectionQuittance:set("daFinQuittancement", vdaFinQuittancement).
    suppressionPgmPersistent(goCollectionHandlePgm).

end procedure.

procedure calproqtPrivate private:
    /*----------------------------------------------------------------------------
    Purpose:
    Notes  :
    ----------------------------------------------------------------------------*/
    define input-output parameter pdaFinQuittancement as date no-undo.

    define variable vdaResiliation     as date    no-undo.
    define variable vdaFinBail         as date    no-undo.
    define variable vlReconduction     as logical no-undo initial true.
    define variable viNumeroRubrique   as integer no-undo.
    define variable viLibelleRubrique  as integer no-undo.
    define variable vdaFinMaximum      as date    no-undo.
    define variable vdaSortieLocataire as date    no-undo.

    define buffer tache for tache.
    define buffer ctrat for ctrat.

    /* Ajout SY le 09/12/2009 : recherche si bail soumis à calendrier */
    run bailSoumisCalendrier(output viNumeroRubrique, output viLibelleRubrique).
    /* Accès à la quittance */
    find first ttQtt
        where ttQtt.iNumeroLocataire = giNumeroContrat
          and ttQtt.iNoQuittance = giNumeroQuittance no-error.
    if not available ttQtt then return.

    /* Initialisation de la date butoir Quittance. */
    /* Recherche de la date de Sortie du Locataire */
    for last tache no-lock
       where tache.TpTac = {&TYPETACHE-quittancement}
         and tache.TpCon = gcTypeContrat
         and tache.NoCon = giNumeroContrat:
        vdaSortieLocataire = tache.DtFin.
    end.
    /* Recherche de la date de r‚siliation du bail */
    for first ctrat no-lock
        where ctrat.TpCon = gcTypeContrat
          and ctrat.NoCon = giNumeroContrat:
        assign
            vdaFinBail     = ctrat.DtFin
            vdaResiliation = ctrat.DtRee
            vlReconduction = (ctrat.TpRen = {&TACITERECONDUCTION-YES}) /* Info "Tacite Reconduction ?"... */
        .
    end.
 
    /*--> Calcul de la date de fin d'application maximum */
    if integer(mToken:cRefPrincipale) = {&REFCLIENT-MANPOWER}
    then do:
        ghProc = lancementPgm("tache/outilsTache.p", goCollectionHandlePgm). 
        run dtFapMax in ghProc(vlReconduction, vdaFinBail, vdaSortieLocataire, vdaResiliation, output vdaFinMaximum).
    end.
    else do:
        /*--> Prendre la plus petite des dates */
        if vdaSortieLocataire <> ? and vdaResiliation <> ?
        then vdaFinMaximum = minimum(vdaSortieLocataire, vdaResiliation).
        else do:
            if vdaResiliation <> ? then vdaFinMaximum = vdaResiliation.
            if vdaSortieLocataire <> ? then vdaFinMaximum = vdaSortieLocataire.
        end.
    end.

    /* TEMPO SC: Essai Prorata avec vdaFinMaximum... */
    if vdaFinMaximum <> ? and ttQtt.daDebutPeriode <> ? and ttQtt.daFinPeriode <> ? and ttQtt.daDebutPeriode < ttQtt.daFinPeriode and vdaFinMaximum >= ttQtt.daDebutPeriode and vdaFinMaximum <= ttQtt.daFinPeriode
    /* Cette quittance est concernée par la date de résiliation --> Calcul du prorata */
    then run majProQtt (viNumeroRubrique, viLibelleRubrique, vdaFinMaximum, vdaSortieLocataire, output pdaFinQuittancement).    
    else if (vdaFinMaximum > ttQtt.daFinPeriode) or vdaFinMaximum = ?
    /* Cette quittance ne doit plus tenir compte de la résiliation --> quittance complète */
    then run supProQtt (viNumeroRubrique, viLibelleRubrique, output pdaFinQuittancement).
    
end procedure.

procedure majProQtt private:
    /*----------------------------------------------------------------------------
    Purpose: mise à jour du prorata de la quittance et de ses rubriques
    Notes  :
    ----------------------------------------------------------------------------*/
    define input  parameter piNumeroRubrique    as integer no-undo.
    define input  parameter piLibelleRubrique   as integer no-undo.
    define input  parameter pdaFinMaximum       as date    no-undo.
    define input  parameter pdaSortieLocataire  as date    no-undo.
    define output parameter pdaFinQuittancement as date    no-undo.

    assign
        ttQtt.daFinQuittancement   = pdaFinMaximum
        ttQtt.dMontantQuittance    = 0
        ttQtt.cdmaj                = 1
        ttQtt.iProrata             = 1
        ttQtt.iNumerateurProrata   = pdaFinMaximum - ttQtt.daDebutQuittancement + 1
        ttQtt.iDenominateurProrata = ttQtt.daFinPeriode - ttQtt.daDebutPeriode + 1
        pdaFinQuittancement        = pdaFinMaximum
        ttQtt.daSortie             = pdaSortieLocataire          /* Ajout Sy le 23/04/2007 (utilisé par majqttp2.p) */
        .
    run majProRub (piNumeroRubrique, piLibelleRubrique).

end procedure.

procedure supProQtt private:
    /*----------------------------------------------------------------------------
    Purpose: suppression du prorata de la quittance et de ses rubriques
    Notes  :
    ----------------------------------------------------------------------------*/
    define input parameter piNumeroRubrique as integer no-undo.
    define input parameter piLibelleRubrique as integer no-undo.
    define output parameter pdaFinQuittancement as date no-undo.

    assign
        ttQtt.daFinQuittancement = ttQtt.daFinPeriode
        ttQtt.dMontantQuittance  = 0
        ttQtt.Cdmaj              = 1
        pdaFinQuittancement      = ttQtt.daFinPeriode
        .
    if ttQtt.daDebutQuittancement = ttQtt.daDebutPeriode
        then assign
            ttQtt.iProrata             = 0
            ttQtt.iNumerateurProrata   = ttQtt.daFinPeriode - ttQtt.daDebutPeriode + 1
            ttQtt.iDenominateurProrata = ttQtt.iNumerateurProrata
            .
    else assign
            ttQtt.iProrata             = 1
            ttQtt.iNumerateurProrata   = ttQtt.daFinQuittancement - ttQtt.daDebutQuittancement + 1
            ttQtt.iDenominateurProrata = ttQtt.daFinPeriode - ttQtt.daDebutPeriode + 1
            .
    run majProRub (piNumeroRubrique, piLibelleRubrique).

end procedure.

procedure majProRub private:
    /*----------------------------------------------------------------------------
    Purpose: mise à jour des proratas des rubriques fixes de la quittance
    Notes  :
    ----------------------------------------------------------------------------*/
    define input parameter piNumeroRubrique  as integer no-undo.
    define input parameter piLibelleRubrique as integer no-undo.

    define variable vlProrataRubrique as logical  no-undo.
    define variable vlCumulRubrique   as logical  no-undo.

    /* Parcours des rubrique fixes de la quittance */
    for each ttRub
        where ttRub.iNumeroLocataire = giNumeroContrat
          and ttRub.iNoQuittance = giNumeroQuittance
          and ttRub.cCodeGenre = {&GenreRubqt-Fixe}:
        assign
            ttRub.iProrata = if ttQtt.iProrata = 0 then 0 else if ttRub.iProrata = -1 then -1  else 1 
            ttRub.iNumerateurProrata = ttQtt.iNumerateurProrata
            ttRub.iDenominateurProrata = ttQtt.iDenominateurProrata
        .
        run isRubProCum(ttRub.iNorubrique, ttRub.iNoLibelleRubrique, output vlProrataRubrique, output vlCumulRubrique).
        if ttRub.iProrata = 0 or not vlProrataRubrique
        then assign
            ttRub.iProrata = 0
            ttRub.dMontantQuittance = ttRub.dMontantTotal
        .
        /* Pas de prorata pour la rubrique loyer si calendrier d'évolution associé */
        else if (piNumeroRubrique <> 0 and ttRub.iNorubrique = piNumeroRubrique and ttRub.iNoLibelleRubrique = piLibelleRubrique)
        then assign
            ttRub.iProrata = 0
            ttRub.dMontantQuittance = ttRub.dMontantTotal
        .
        else if ttRub.iProrata = 1
             then ttRub.dMontantQuittance = ttRub.dMontantTotal * ttRub.iNumerateurProrata / ttRub.iDenominateurProrata.
             else ttRub.dMontantQuittance = ttRub.dMontantTotal.
        ttQtt.dMontantQuittance = ttQtt.dMontantQuittance + ttRub.dMontantQuittance.
    end.

end procedure.

procedure bailSoumisCalendrier private:
    /*----------------------------------------------------------------------------
    Purpose:
    Notes  :
    ----------------------------------------------------------------------------*/
    define output parameter piRubriqueCalendrier as integer  no-undo.
    define output parameter piLibelleCalendrier  as integer  no-undo.

    define buffer tache for tache.

    /* Recherche si mode de calcul calendrier d'evolution des loyers */
    find last tache no-lock
        where tache.tpcon = gcTypeContrat
          and tache.nocon = giNumeroContrat
          and tache.tptac = {&TYPETACHE-revision} no-error.
    if not available tache
    or tache.cdhon <> "00001"              /* Pas de calcul "calendrier d'evolution des loyers ====> pas de tache calendrier */
    or not can-find(first calev no-lock    /* Si aucun calendrier de saisi: aucun calcul a effectuer */
                    where calev.tpcon = gcTypeContrat
                      and calev.nocon = giNumeroContrat)
    then return.

    /* Recherche si calendrier utilise pour le calcul */
    find first tache no-lock
        where tache.tpcon = gcTypeContrat
          and tache.nocon = giNumeroContrat 
          and tache.tptac = {&TYPETACHE-calendrierEvolutionLoyer}      /* tache calendrier évolution loyer */
          and tache.notac = 0 no-error.
    if not available tache or tache.tphon = "no" then return.

    assign
        piRubriqueCalendrier = integer(tache.ntges)
        piLibelleCalendrier  = integer(tache.tpges)
    .
end procedure.
