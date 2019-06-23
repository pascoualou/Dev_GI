/*-----------------------------------------------------------------------------
File        : calproqt.p
Purpose     : Module de calcul du prorata sur les rubriques fixes d'une quittance donnée
Author(s)   : Kantena - 2017/12/15
Notes       : reprise de calproqt.p
derniere revue: 2018/04/26 - phm: OK

01 10/12/1996  SP    Correction problème détecté en cours de test (fiche 700)
02 02/01/1997  SC    Fiche 743: On ne prorate pas les rubriques de type Administratif (Famille 4).
03 06/01/1997  SP    Affectation du code retour
04 03/04/1997  SY    Modification du test de détection de la Maj des proratas (dtdeb/dtfin -> dtdpr/dtfpr)
05 28/05/1997  SP    Correction calcul du prorata dans MajProQtt avec ttQtt.NbNum et ttQtt.NbDen
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
16 23/04/2007  SY    0307/0174: Stockage de la date de sortie dans ttQtt.dtsor (gdaSortieLocataire)
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

using parametre.pclie.parametrageRubriqueQuittHonoCabinet.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{bail/include/equit.i &nomtable=ttqtt}
{bail/include/tmprub.i}

define input  parameter       pcTypeContrat       as character no-undo.
define input  parameter       piNumeroCOntrat     as int64     no-undo.
define input  parameter       piNumeroQuittance   as integer   no-undo.
define input-output parameter pdaFinQuittancement as date      no-undo.
define input-output parameter table for ttQtt.
define input-output parameter table for ttRub.
define output parameter       pcCodeRetour        as character no-undo initial "00".

define variable gdaSortieLocataire as date     no-undo.
define variable gdaFinMaximum      as date     no-undo.
define variable giNumeroRubrique   as integer  no-undo.
define variable giLibelleRubrique  as integer  no-undo.
define variable goRubriqueQuittHonoCabinet as class parametrageRubriqueQuittHonoCabinet no-undo.
/* pour l'include comm/include/prrubhol.i */
&global-define proratisation-avant-fiche "650,651,652,655,657,659,685,695"
{comm/include/prrubhol.i}    // procedures isRubEcla, isRubProCum, valDefProCum8xx

goRubriqueQuittHonoCabinet = new parametrageRubriqueQuittHonoCabinet().
run calproqtPrivate.
delete object goRubriqueQuittHonoCabinet.

procedure calproqtPrivate private:
    /*----------------------------------------------------------------------------
    Purpose:
    Notes  :
    ----------------------------------------------------------------------------*/
    define variable vdaResiliation as date     no-undo.
    define variable vdaFinBail     as date     no-undo.
    define variable vlReconduction as logical  no-undo initial true.
    define buffer tache for tache.
    define buffer ctrat for ctrat.

    /* Ajout SY le 09/12/2009 : recherche si bail soumis à calendrier */
    run bailSoumisCalendrier(output giNumeroRubrique, output giLibelleRubrique).
    /* Accès à la quittance */
    find first ttQtt
        where ttQtt.NoLoc = piNumeroCOntrat
          and ttQtt.NoQtt = piNumeroQuittance no-error.
    if not available ttQtt then return.

    /* Initialisation de la date butoir Quittance. */
    /* Recherche de la date de Sortie du Locataire */
    find last tache no-lock
        where tache.TpTac = {&TYPETACHE-quittancement}
          and tache.TpCon = pcTypeContrat
          and tache.NoCon = piNumeroCOntrat no-error.
    if available tache then gdaSortieLocataire = tache.DtFin.
    /* Recherche de la date de r‚siliation du bail */
    find first ctrat no-lock
        where ctrat.TpCon = pcTypeContrat
          and ctrat.NoCon = piNumeroCOntrat no-error.
    if available ctrat then assign
        vdaFinBail     = ctrat.DtFin
        vdaResiliation = ctrat.DtRee
        vlReconduction = (ctrat.TpRen = "00001") /* Info "Tacite Reconduction ?"... */
    .
    /*--> Calcul de la date de fin d'application maximum */
    if integer(mToken:crefGerance) <> 10  //  integer(NoRefUse) <> 10      // todo  déterminer norefuse !!!
    then run dtFapMax(vlReconduction, vdaFinBail, gdaSortieLocataire, vdaResiliation, output gdaFinMaximum).
    else do:
        /*--> Prendre la plus petite des dates */
        if gdaSortieLocataire <> ? and vdaResiliation <> ?
        then gdaFinMaximum = minimum(gdaSortieLocataire, vdaResiliation).
        else do:
            if vdaResiliation <> ? then gdaFinMaximum = vdaResiliation.
            if gdaSortieLocataire <> ? then gdaFinMaximum = gdaSortieLocataire.
        end.
    end.
    /* TEMPO SC: Essai Prorata avec gdaFinMaximum... */
    if (gdaFinMaximum <> ? and ttQtt.DtDPr <> ? and ttQtt.DtFPr <> ? and ttQtt.DtDPr < ttQtt.DtFPr)  /* Modif SY le 03/10/2012 : ajout controles de protection */
        and (gdaFinMaximum >= ttQtt.DtDPr and gdaFinMaximum <= ttQtt.DtFPr)
    /* Cette quittance est concernée par la date de résiliation --> Calcul du prorata */
    then run majProQtt.
    else if (gdaFinMaximum > ttQtt.DtFpr) or gdaFinMaximum = ?
    /* Cette quittance ne doit plus tenir compte de la résiliation --> quittance complète */
    then run supProQtt.
end procedure.

procedure majProQtt private:
    /*----------------------------------------------------------------------------
    Purpose: mise à jour du prorata de la quittance et de ses rubriques
    Notes  :
    ----------------------------------------------------------------------------*/
    assign
        ttQtt.DtFin = gdaFinMaximum
        ttQtt.MtQtt = 0
        ttQtt.Cdmaj = 1
        ttQtt.CdQuo = 1
        ttQtt.NbNum = gdaFinMaximum - ttQtt.DtDeb + 1
        ttQtt.NbDen = ttQtt.DtFpr - ttQtt.DtDpr + 1
        pdaFinQuittancement = gdaFinMaximum
        ttQtt.DtSor = gdaSortieLocataire          /* Ajout Sy le 23/04/2007 (utilisé par majqttp2.p) */
    .
    run majProRub.

end procedure.

procedure supProQtt private:
    /*----------------------------------------------------------------------------
    Purpose: suppression du prorata de la quittance et de ses rubriques
    Notes  :
    ----------------------------------------------------------------------------*/
    assign
        ttQtt.DtFin = ttQtt.DtFpr
        ttQtt.MtQtt = 0
        ttQtt.Cdmaj = 1
        pdaFinQuittancement = ttQtt.DtFpr
    .
    if ttQtt.DtDeb = ttQtt.DtDpr
    then assign
        ttQtt.CdQuo = 0
        ttQtt.NbNum = ttQtt.DtFpr - ttQtt.DtDpr + 1
        ttQtt.NbDen = ttQtt.NbNum
    .
    else assign
        ttQtt.CdQuo = 1
        ttQtt.NbNum = ttQtt.DtFin - ttQtt.DtDeb + 1
        ttQtt.NbDen = ttQtt.DtFpr - ttQtt.DtDpr + 1
    .
    run majProRub.

end procedure.

procedure majProRub private:
    /*----------------------------------------------------------------------------
    Purpose: mise à jour des proratas des rubriques fixes de la quittance
    Notes  :
    ----------------------------------------------------------------------------*/
    define variable vlProrataRubrique as logical  no-undo.
    define variable vlCumulRubrique   as logical  no-undo.

    /* Parcours des rubrique fixes de la quittance */
    for each ttRub
        where ttRub.NoLoc = piNumeroCOntrat
          and ttRub.NoQtt = piNumeroQuittance
          and ttRub.CdGen = "00001":
        assign
            ttRub.CdPro = if ttQtt.CdQuo = 0 then 0 else if ttRub.CdPro = -1 then -1  else 1 
            ttRub.VlNum = ttQtt.NbNum
            ttRub.VlDen = ttQtt.NbDen
        .
        run isRubProCum(ttRub.norub, ttRub.nolib, output vlProrataRubrique, output vlCumulRubrique).
        if ttRub.CdPro = 0 or not vlProrataRubrique
        then assign
            ttRub.CdPro = 0
            ttRub.VlMtq = ttRub.MtTot
        .
        /* Pas de prorata pour la rubrique loyer si calendrier d'évolution associé */
        else if (giNumeroRubrique <> 0 and ttRub.norub = giNumeroRubrique and ttRub.nolib = giLibelleRubrique)
        then assign
            ttRub.CdPro = 0
            ttRub.VlMtq = ttRub.MtTot
        .
        else if ttRub.cdpro = 1
             then ttRub.VlMtq = ttRub.MtTot * ttRub.VlNum / ttRub.VlDen.
             else ttRub.VlMtq = ttRub.MtTot.
        ttQtt.MtQtt = ttQtt.MtQtt + ttRub.VlMtq.
    end.

end procedure.

procedure bailSoumisCalendrier:
    /*----------------------------------------------------------------------------
    Purpose:
    Notes  :
    ----------------------------------------------------------------------------*/
    define output parameter piRubriqueCalendrier as integer  no-undo.
    define output parameter piLibelleCalendrier  as integer  no-undo.

    define buffer tache for tache.

    /* Recherche si mode de calcul calendrier d'evolution des loyers */
    find last tache no-lock
        where tache.tpcon = pcTypeContrat
          and tache.nocon = piNumeroCOntrat
          and tache.tptac = {&TYPETACHE-revision} no-error.
    if not available tache
    or tache.cdhon <> "00001"              /* Pas de calcul "calendrier d'evolution des loyers ====> pas de tache calendrier */
    or not can-find(first calev no-lock    /* Si aucun calendrier de saisi: aucun calcul a effectuer */
                    where calev.tpcon = pcTypeContrat
                      and calev.nocon = piNumeroCOntrat)
    then return.

    /* Recherche si calendrier utilise pour le calcul */
    find first tache no-lock
        where tache.tpcon = pcTypeContrat
          and tache.nocon = piNumeroCOntrat 
          and tache.tptac = {&TYPETACHE-calendrierEvolutionLoyer}      /* tache calendrier évolution loyer */
          and tache.notac = 0 no-error.
    if not available tache or tache.tphon = "no" then return.

    assign
        piRubriqueCalendrier = integer(tache.ntges)
        piLibelleCalendrier  = integer(tache.tpges)
    .
end procedure.
