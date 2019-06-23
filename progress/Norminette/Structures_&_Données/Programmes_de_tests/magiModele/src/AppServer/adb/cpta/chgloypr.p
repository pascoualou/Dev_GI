/*-----------------------------------------------------------------------------
File        : chgloypr.p
Purpose     : Calcul des proratas de loyers pour les Factures de sortie locataires
Author(s)   : AIF - 13/04/2000     GGA - 2018/06/14
Notes       : reprise de adb/cpta/chgloypr.p
derniere revue: 2018/07/28 - phm: 

01  20/04/2000  AlF   On remplace les rubriques 211 par des 200 pour éviter de creer les rubriques associées à la 211(ce seraient les même que pour les 200)
02  02/08/2000  LG    Modif effectuée pour les rub. TVA: ne pas  envoyer les rub. de rappel ou avoir car  la compta en tient compte => envoie de la meme rub. de aquit
03  14/09/2000  AlF   Recalcul des proratas ...
04  04/12/2002  AFA   Fche 1202/0004: prb 13 mois sur facture de sortie.
05  09/07/2004  AF    0704/0084 rub 651 652 655 685 prorate
06  20/01/2005  SY    0105/0061 Correction recherche quittance de sortie (on prenait l'avant dernière et non celle de la date de sortie)
                      correction montant rub utilisé (BRUT) + réindentation
07  10/03/2005  SY    0205/0523 Correction recherche rubrique pour la régularisation: on utilise en priorité les rubriques associées (rubqt.asrub/aslib)
                      ATTENTION: moulinette de redressement à passer - mdrubqt0.p
08  03/01/2006  SY    1205/0447: Plus de calcul de proratas sur les rub TVA car maintenant le prog de facturation le fait (c.f. fiche 0405/0409)
09  10/03/2006  SY    0306/0246: Correction recherche rub associée pour le Rappel/avoir: ce ne doit être une Rub "résultat" (rub de révision)
10  10/07/2006  SY    0706/0059 : La rubrique Administratif 650 peut être proratée
11  24/11/2006  PL    0106/0018:suppression format american ADB
12  16/05/2007  SY    0307/0174 : Calcul des proratas si RAZ de la date de sortie
                      ATTENTION: nouveau param entrée => A LIVRER AVEC ftfac.w
13  28/11/2006  SY    1107/0285 sauvegarde/restitution format num
14  19/03/2008  OF    1207/0140 Modif nbre de jours de la période dans le calcul du prorata (on prenait la période suivante au lieu de celle du quitt. à prorater)
15  03/07/2008  MB    0408/0174 rub proratées
16  27/04/2009  SY    0209/0180 Nlles rub proratées : 659 et 695
17  02/09/2009  SY    0509/0143 changement méthode de calcul rappel/avoir: proratas par terme à la place des proratas jour
18  08/12/2009  SY    0509/0143 retour tests: 1 jour de trop dans le 1er prorata jours
19  19/03/2010  SY    1108/0443 Si Hono Loc par le quit alors Anciennes rub extournables interdites => Il faut refaire la conversion !
20  22/03/2010  SY    1108/0443 Si Hono Loc par le quit alors Rub 8xx doivent se prorater/cumuler comme les anciennes Rubriques Extournables (IsRubProCum)
21  09/06/2010  SY    0610/0058 Modif IsRubProCum : PAS de proratas pour Prime Assurance (506 & 821)
22  07/07/2010  SY    0710/0034 Modif IsRubProCum : PAS de proratas pour Pack Services (834)
23  07/07/2011  SY    0511/0012 Ecart entre Date de sortie et quittancement effectif
                      Ajout controle date de sortie / date fin quittancement pour choisir la date à utiliser dans le calcul rappel/avoir en facturation de sortie
24  04/10/2012  SY    0912/0114 Pas de proratas sur Rub 705 Taxes de bureau (prrubhol.i)
25  11/01/2013  SY    0113/0028 modif IsRubProCum
26  18/01/2013  SY    0113/0028 modif IsRubProCum (prm HOLOQ)
27  10/06/2013  SY    0909/0196 Historisation Annulation Facture
28  12/01/2015  SY    Modif FIND FIRST equit pour ignorer avis ech périmés (Pb plantage PEC, equit non historisé)
29  08/10/2015  OF    Correction faute de frappe sur msg erreur
-----------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/param2locataire.i}
{preprocesseur/profil2rubQuit.i}
{preprocesseur/codeRubrique.i}

using parametre.pclie.parametrageRubriqueQuittHonoCabinet.
using parametre.pclie.parametrageRubriqueExtournable.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{application/include/error.i}

define variable ghPrgdat                   as handle    no-undo.
define variable glHonoLocQuit              as logical   no-undo.
define variable giNumeroContrat            as int64     no-undo.
define variable gdaNouvelleDateResiliation as date      no-undo.
define variable glDebug                    as logical   no-undo.
define variable giNbMoiPer                 as integer   no-undo.
define variable gcCdTerUse                 as character no-undo.
define variable gdaDtSorOld                as date      no-undo.
define variable goRubriqueQuittHonoCabinet as class     parametrageRubriqueQuittHonoCabinet no-undo.
define variable goRubriqueExtournable      as class     parametrageRubriqueExtournable      no-undo.

define temp-table ttTmpRub no-undo
    field norub as integer
    field nolib as integer
    field lbrub as character
    field vlmtq as decimal
index Ix_TmRub01 is unique primary norub nolib.

{comm/include/prrubhol.i}    // procedures isRubEcla, isRubProCum, valDefProCum8xx
{comm/include/prrubass.i}    // procedure RchRubRegul

procedure lancementChgloypr:
    /*------------------------------------------------------------------------
    Purpose : 
    Notes   : service externe
    ------------------------------------------------------------------------*/
    define input parameter poCollectionContrat as class collection no-undo.
    define input parameter pdaNouvelleDateResiliation as date      no-undo.
    define input parameter pcTypeTrt                  as character no-undo.
    define input parameter table for ttError.
    define output parameter table for ttTmpRub.

    define variable vdaFinQuittancement as date    no-undo.
    define variable viMoiMEc            as integer no-undo.
    define variable viRetourQuestion    as integer no-undo.

    define buffer ctrat for ctrat.
    define buffer tache for tache.
    define buffer aquit for aquit.
    define buffer equit for equit.

    empty temp-table ttTmpRub.
    assign
        giNumeroContrat            = poCollectionContrat:getInt64("iNumeroContrat")
        gdaNouvelleDateResiliation = pdaNouvelleDateResiliation
        glHonoLocQuit              = false
        goRubriqueQuittHonoCabinet = new parametrageRubriqueQuittHonoCabinet()
        goRubriqueExtournable      = new parametrageRubriqueExtournable()
    .

    if goRubriqueQuittHonoCabinet:isDbParameter
    then glHonoLocQuit = true.
    run application/l_prgdat.p persistent set ghPrgdat.
    run getTokenInstance in ghPrgdat(mToken:JSessionId).
    for each ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-bail}
          and ctrat.nocon = giNumeroContrat
      , last tache no-lock
        where tache.tpcon = {&TYPECONTRAT-bail}
          and tache.nocon = ctrat.nocon
          and tache.tptac = {&TYPETACHE-quittancement}:
        assign
            giNbMoiPer = integer(substring(tache.pdges, 1, 3, "character"))
            gcCdTerUse = tache.ntges                          /* Avance/echu */
        .
        case pcTypeTrt:
            when "FACSOR" then do:
                /* Ajout Sy le 07/07/2011 - fiche 0511/0012 - Ecart entre Date de sortie et quittancement effectif */
                vdaFinQuittancement = tache.dtfin.
                {&_proparse_ prolint-nowarn(use-index)}
                for last aquit no-lock
                    where aquit.noloc = giNumeroContrat
                      and aquit.fgfac = no
                    use-index ix_aquit03:
                    if tache.dtfin < aquit.dtfin then do:
                        /* Ecart entre Date de sortie et quittancement effectif. Ce locataire a été quittancé jusqu'au &1 alors que la date de sortie saisie est au &2. Voulez-vous effectuer les calculs de rappel/avoir à partir de la date de fin de quittancement trouvée : &3 ?*/
                        viRetourQuestion = outils:questionnaire(1000818, substitute("&2&1&3&1&4", separ[1], aquit.dtfin, tache.dtfin, aquit.dtfin), table ttError by-reference).
                        if viRetourQuestion < 2 then return.
                        if viRetourQuestion = 3 then vdaFinQuittancement = aquit.dtfin.
                    end.
                end.
                if not (vdaFinQuittancement = gdaNouvelleDateResiliation) then do:
                    gdaDtSorOld = vdaFinQuittancement.
                    /* recherche de la quittance de la sortie locataire */
                    for last aquit no-lock
                        where aquit.noloc = ctrat.nocon
                          and aquit.dtdpr <= gdaDtSorOld
                          and aquit.dtfpr >= gdaDtSorOld
                          and aquit.fgfac = false:
                        run calProratas(buffer aquit).
                    end.
                end.
            end.
            when "RAZDTSOR" then do:
                viMoiMEc = poCollectionContrat:getInteger("iMoisEchu").
                /* Recherche de le 1ère quittance en cours pour trouver la nouvelle date de "fin" */
                for first equit no-lock
                    where equit.NoLoc = ctrat.nocon
                      and equit.msqtt >= viMoiMEc: /* AJout SY le 12/01/2015 pour ne pas prendre les Avis d'échéance périmés (Pb plantage PEC, equit non historisé) */
                    gdaNouvelleDateResiliation = equit.dtdpr - 1.
                end.
                /* Recherche de la derniere quittance du locataire pour trouver l'ancienne date de sortie */
                {&_proparse_ prolint-nowarn(use-index)}
                for last aquit no-lock
                   where aquit.NoLoc = ctrat.nocon
                      and aquit.fgfac = false
                    use-index ix_aquit03:            /* par mois de quitt */
                    gdaDtSorOld = aquit.dtfin.
                    if gdaNouvelleDateResiliation <> ? and gdaNouvelleDateResiliation <> gdaDtSorOld
                    then run calProratas (buffer aquit).
                end.
            end.
        end case.
    end.
    delete object goRubriqueQuittHonoCabinet.
    delete object goRubriqueExtournable.
    run destroy in ghPrgdat.

end procedure.

procedure calProratas private:
    /*------------------------------------------------------------------------
    Purpose : Procedure de calcul des proratas entre gdaNouvelleDateResiliation
              le prorata jour ne convient pas au client a cause de février
              => il faut découper en terme(s) complet(s) du locataire
              + proratas Avant et/ou apres si terme debut et/ou fin incomplet
    Notes   :
    ------------------------------------------------------------------------*/
    define parameter buffer aquit for aquit.

    define variable vdaResiliation      as date      no-undo.
    define variable viCodeRubrique        as integer   no-undo.
    define variable viCodeLibelle         as integer   no-undo.
    define variable viMoisPeriode         as integer   no-undo.
    define variable viAnneePeriode        as integer   no-undo.
    define variable vcLibelleAssocie      as character no-undo.
    define variable viRubriqueAssociee    as integer   no-undo.
    define variable viLibelleAssocie      as integer   no-undo.
    define variable viIndiceRubrique      as integer   no-undo.
    define variable viNombreJour          as integer   no-undo.
    define variable viNombreJourProrate   as integer   no-undo.
    define variable vdeMontantRubrique    as decimal   no-undo.
    define variable vdeTauxProrataLoyer   as decimal   no-undo.
    define variable viNombreJourProrate01 as integer   no-undo.
    define variable viNombreJour01        as integer   no-undo.
    define variable vdeTauxProrataLoyer01 as decimal   no-undo.
    define variable viNombreJourProrate02 as integer   no-undo.
    define variable viNombreJour02        as integer   no-undo.
    define variable vdeTauxProrataLoyer02 as decimal   no-undo.
    define variable vlRubriqueProratee    as logical   no-undo.
    define variable vlRubriqueCumuleee    as logical   no-undo.
    define variable vdaDebutPeriode       as date      no-undo.
    define variable vdaFinPeriode         as date      no-undo.
    define variable viNbMoisTerme         as integer   no-undo.
    define variable viNombreTermes        as integer   no-undo.
    define variable viI                   as integer   no-undo.
    define variable vlRegularisation      as logical   no-undo.

    define buffer rubqt   for rubqt.
    define buffer vbrubqt for rubqt.

    assign
        viNombreJour        = 0
        viNombreJourProrate = 0
        vdeTauxProrataLoyer = 0
        vdaResiliation   = gdaNouvelleDateResiliation
        viAnneePeriode     = truncate(aquit.msqtt / 100, 0)
        viMoisPeriode      = if gcCdTerUse <> {&TERMEQUITTANCEMENT-avance}                                                /* Avance / échu */
                             then integer(substring(string(aquit.msqtt), 5, 2, "character")) + giNbMoiPer
                             else month(gdaNouvelleDateResiliation).
    if viMoisPeriode >= 13                                                                /* Ancienne date de sortie */
    then assign
        viMoisPeriode  = viMoisPeriode - 12
        viAnneePeriode = viAnneePeriode + 1
    .
    assign
        viNombreJour        = aquit.dtfpr - aquit.dtdpr + 1                                                 /* Nb de jour du mois de sortie initiale */
        viNombreJourProrate = integer(if gdaDtSorOld > gdaNouvelleDateResiliation                                       /* Nb de jour proratés */
                              then (gdaDtSorOld - vdaResiliation) else (vdaResiliation - gdaDtSorOld))
        vdeTauxProrataLoyer = if gdaDtSorOld > gdaNouvelleDateResiliation                                               /* Taux du prorata appliqué sur le loyer */
                              then -(viNombreJourProrate / viNombreJour)
                              else  (viNombreJourProrate / viNombreJour)
        viNbMoisTerme       = integer(substring(aquit.pdqtt, 1, 3, "character"))
        vdaDebutPeriode     = aquit.dtdpr
        vdaFinPeriode       = aquit.dtfpr
        viNombreJour01      = aquit.dtfpr - aquit.dtdpr + 1               /* - 1 - proratas sur histo */
    .
    if glDebug
    then mLogger:writeLog (0, substitute("chgloypr: calcul proratas jours &1 &2 &3 &4 gdaDtSorOld = &5  -> gdaNouvelleDateResiliation = &6 Nbjoupro = &7 Nbjoutot = &8 vdeTauxProrataLoyer = &9",
                              aquit.noloc, aquit.msqtt, aquit.dtdeb, aquit.dtfin, gdaDtSorOld, gdaNouvelleDateResiliation, viNombreJourProrate, viNombreJour,vdeTauxProrataLoyer)).
    /* Nb de jour proratés dans la quittance de sortie */
    if gdaDtSorOld >= aquit.dtdpr and gdaDtSorOld <= aquit.dtfpr
    then assign
        /* nouvelle date de sortie dans la meme quittance ? */
        viNombreJourProrate01 = if gdaNouvelleDateResiliation >= aquit.dtdpr and gdaNouvelleDateResiliation <= aquit.dtfpr
                                then if gdaDtSorOld > gdaNouvelleDateResiliation then (gdaDtSorOld - gdaNouvelleDateResiliation)  else (gdaNouvelleDateResiliation - gdaDtSorOld)
                                else if gdaDtSorOld > gdaNouvelleDateResiliation then (gdaDtSorOld - aquit.dtdpr + 1) else (aquit.dtfpr - gdaDtSorOld)
        /* Taux du prorata appliqué sur le loyer */
        vdeTauxProrataLoyer01 = if gdaDtSorOld > gdaNouvelleDateResiliation
                                then - viNombreJourProrate01 / viNombreJour01
                                else   viNombreJourProrate01 / viNombreJour01
    .
    if glDebug
    then mLogger:writeLog (0, substitute("chgloypr.p : &1 ancienne date de sortie = &2 Nouvelle date de sortie = &3 Quittance de sortie &4 &5 période = &6 proratas Qtt sortie : &7  = &8 / &9",
                              giNumeroContrat, gdaDtSorOld, gdaNouvelleDateResiliation, aquit.noqtt, aquit.msqtt, string(aquit.dtdpr) + " " + string(aquit.dtfpr), viNombreJour01, viNombreJourProrate01, viNombreJour01)).

    /* - 2 - Recherche du nombre de termes complets + proratas no 2 éventuels */
    /* Cas no 1 : date de sortie supprimée ou repoussée */
    if gdaDtSorOld < gdaNouvelleDateResiliation
    then do while vdaFinPeriode < gdaNouvelleDateResiliation :
        vdaDebutPeriode = vdaFinPeriode + 1.
        /* Récupération de la date de fin de période */
        run cl2DatFin in ghPrgdat(vdaDebutPeriode ,viNbMoisTerme , "00002", output vdaFinPeriode).
        vdaFinPeriode = vdaFinPeriode - 1.
        if glDebug
        then mLogger:writeLog (0, substitute("chgloypr.p : &1 ancienne date de sortie = &2 Nouvelle date de sortie = &3 Quittance de sortie &4 &5 période = &6 &7 Boucle terme complets : &8 - &9",
                                  giNumeroContrat, gdaDtSorOld, gdaNouvelleDateResiliation, aquit.noqtt, aquit.msqtt, aquit.dtdpr, aquit.dtfpr, vdaDebutPeriode, vdaFinPeriode)).
        if gdaNouvelleDateResiliation < vdaFinPeriode then do:
            assign
                /* Proratas no 02 */
                viNombreJour02        = vdaFinPeriode - vdaDebutPeriode + 1
                viNombreJourProrate02 = gdaNouvelleDateResiliation - vdaDebutPeriode + 1
                /* Taux du prorata appliqué sur le loyer */
                vdeTauxProrataLoyer02 = viNombreJourProrate02 / viNombreJour02
            .
            leave.
        end.
        else assign         /* Periode suivante */
            vdaDebutPeriode = vdaFinPeriode + 1
            viNombreTermes = viNombreTermes + 1
        .
    end.    /* Cas no 1: date de sortie supprimée */
    /* cas no 2: date de sortie reculée */
    /* Modif SY le 25/02/2010 : seulement si nlle date de sortie < début de la quittance de sortie  */
    else if gdaDtSorOld > gdaNouvelleDateResiliation
    and gdaNouvelleDateResiliation < aquit.dtdpr then do:
        do viI = 1 to 99:
            /* Récupération de la date de début de période */
            vdaDebutPeriode = add-interval(vdaDebutPeriode, - viNbMoisTerme, "month").  //   run souMoiDat in ghPrgdat(vdaDebutPeriode, viNbMoisTerme , "00002", output vdaDebutPeriode).
            run cl2DatFin in ghPrgdat(vdaDebutPeriode, viNbMoisTerme , "00002", output vdaFinPeriode).
            vdaFinPeriode = vdaFinPeriode - 1.
            if glDebug
            then mLogger:writeLog (0, substitute("chgloypr.p : &1 ancienne date de sortie = &2 Nouvelle date de sortie = &3 Quittance de sortie &4 &5 période = &6 &7 Boucle terme complets : &8 - &9",
                                      giNumeroContrat, gdaDtSorOld, gdaNouvelleDateResiliation, aquit.noqtt, aquit.msqtt, aquit.dtdpr, aquit.dtfpr, vdaDebutPeriode, vdaFinPeriode)).
            if gdaNouvelleDateResiliation >= vdaDebutPeriode then do:
                assign
                    /* Proratas no 02 */
                    viNombreJour02        = vdaFinPeriode - vdaDebutPeriode + 1
                    viNombreJourProrate02 = vdaFinPeriode - gdaNouvelleDateResiliation
                    /* Taux du prorata appliqué sur le loyer */
                    vdeTauxProrataLoyer02 = - (viNombreJourProrate02 / viNombreJour02) 
                .
                leave.
            end.
            else assign                      /* Période précédente */
                vdaFinPeriode  = vdaDebutPeriode - 1
                viNombreTermes = viNombreTermes + 1
            .
        end.
        viNombreTermes = - viNombreTermes.
    end.    /* Cas no 2 : date de sortie reculée */
    if glDebug then do:
        mLogger:writeLog(0, substitute("chgloypr.p : &1 ancienne date de sortie = &2 Nouvelle date de sortie = &3 Quittance de sortie &4 &5 période = &6 &7",
                             giNumeroContrat, gdaDtSorOld, gdaNouvelleDateResiliation, aquit.noqtt, aquit.msqtt, aquit.dtdpr, aquit.dtfpr)).
        mLogger:writeLog(0, substitute("proratas Qtt sortie : viNombreJour01 = &1 / &2 => &3 Nb termes complets = &4 proratas Qtt nlle sortie : viNombreJour02 = &5 / &6 => &7",
                             viNombreJourProrate01, viNombreJour01, vdeTauxProrataLoyer01, viNombreTermes, viNombreJourProrate02, viNombreJour02, vdeTauxProrataLoyer02)).
    end.
    /* calcul du prorata sur le loyer */
        
boucleRubrique:
    do viIndiceRubrique = 1 to aquit.nbrub:
        viCodeRubrique = integer(entry(1, aquit.tbrub[viIndiceRubrique], "|")) no-error.
        if error-status:error then next boucleRubrique.

        /* AlF: ON REMPLACE LES RUBRIQUES 211 PAR LES RUBRIQUES 200 CAR LES RUBRIQUES ASSOCIEES A LA 211 N'ONT PAS ETE CREES ET SONT LES MEME QUE POUR LES RUBRIQUES 200 */
        if viCodeRubrique = {&RUBRIQUE-provisionDiverse} then viCodeRubrique = {&RUBRIQUE-provisionCharges}.
        assign
            viCodeLibelle      = integer(entry(2, aquit.tbrub[viIndiceRubrique] , "|"))
            /* Forcer le code libellé 1 si on a 0 dans la base  */
            viCodeLibelle      = if viCodeLibelle = 0 then 1 else viCodeLibelle
            /* SY le 20/01/2005: prorater le montant BRUT et non pas le montant déjà proraté !!! */
            /* modif SY le 01/09/2009: additionner les proratas par terme */
            vdeMontantRubrique = round(decimal(entry(5, aquit.tbrub[viIndiceRubrique], "|")) * (vdeTauxProrataLoyer01 + viNombreTermes + vdeTauxProrataLoyer02), 2)
            /* Recherche de la rubrique associée pour imputer le prorata*/
            /* ATTENTION: si une nouvelle rubrique doit etre proratée, il faut qu'elle ait une rubrique 
               Rappel/Avoir ou Positif/négatif associée pour imputer la régul (asrub/aslib) */
            viRubriqueAssociee = 0
            viLibelleAssocie   = 0
            vcLibelleAssocie   = ""
        .
        for first rubqt no-lock
            where rubqt.cdrub = viCodeRubrique
              and rubqt.cdlib = viCodeLibelle:
            /* Ajout Sy le 22/03/2010 - TVA hono cabinet recalculée */
            if rubqt.cdfam = {&FamilleRubqt-TVAHonoraire} then next.
            run isRubProCum (rubqt.cdrub, rubqt.cdlib, output vlRubriqueProratee , output vlRubriqueCumuleee).
            mLogger:writeLog(0, substitute("CalProratas (IsRubProCum)- Loc &1 Noqtt = &2 Mois = &3 Rub: &4.&5 Proratas => &6 Cumul => &7",
                                aquit.noloc, aquit.noqtt, aquit.msqtt, string(rubqt.cdrub, "999"), string(rubqt.cdlib, "99"), vlRubriqueProratee, vlRubriqueCumuleee)).
            if not vlRubriqueProratee then next.

            /* Ajout SY le 22/03/2010  : Remplacer les anciennes rub extournables (c.f. PclHOLOQ - RemplaceDansQuittancement) */
            /* AVANT recherche rubrique associée */            
            if glHonoLocQuit 
            and goRubriqueExtournable:isRubriqueExtournable(viCodeRubrique)
            and goRubriqueQuittHonoCabinet:existeLienAncRubExtournable(viCodeRubrique, viCodeLibelle)
            then for first vbrubqt no-lock
                where vbrubqt.cdrub = goRubriqueQuittHonoCabinet:getRubriqueLocataire()
                  and vbrubqt.cdlib = goRubriqueQuittHonoCabinet:getLibelleLocataire():
                assign
                    viCodeRubrique = vbrubqt.cdrub
                    viCodeLibelle  = vbrubqt.cdlib
                .
            end.    /* glHonoLocQuit */

            /* Modif SY le 10/06/2013: mise en procedure de la recherche de la rubrique (variable) de régularisation */
            run rchRubRegul(viCodeRubrique, viCodeLibelle, vdeMontantRubrique, output vlRegularisation, output viRubriqueAssociee, output viLibelleAssocie).
            if not vlRegularisation then do:
                mError:createError({&warning}, 1000841, substitute("&2&1&3&1&4", separ[1], viCodeRubrique, viCodeLibelle, vdeMontantRubrique)).
                return.
            end.
            for first vbrubqt no-lock
                where vbrubqt.cdrub = viRubriqueAssociee
                  and vbrubqt.cdlib = viLibelleAssocie:
                vcLibelleAssocie = outilTraduction:getLibelle(vbrubqt.nome1).
                /* SY le 21/05/2007 : cas particulier rub MEH 111 calculée */
                if viRubriqueAssociee = 107
                then case viCodeRubrique:
                    when 111 then vcLibelleAssocie = (if vdeMontantRubrique < 0 then outilTraduction:getLibelle(703152)       //avoir majoration loyer
                                                                                else outilTraduction:getLibelle(703134)).     //rappel majoration loyer 
                    when 102 then vcLibelleAssocie = outilTraduction:getLibelle(1000843).    //Annulation remise loyer
                    when 108 then vcLibelleAssocie = outilTraduction:getLibelle(1000842).    //Annulation franchise loyer
                end case.
            end.
            /** Fin modif SY  le 10/06/2013 */
            if vdeMontantRubrique <> 0 then do:
                if glDebug
                then mLogger:writeLog(0, substitute("&1 - &2 => &3 - &4 &5 &6",
                                                    rubqt.cdrub, rubqt.cdlib, viRubriqueAssociee, viLibelleAssocie, vdeMontantRubrique, vcLibelleAssocie)).
                find first ttTmpRub
                    where ttTmpRub.norub = viRubriqueAssociee
                      and ttTmpRub.nolib = viLibelleAssocie no-error.
                if not available ttTmpRub then do:
                    create ttTmpRub.
                    assign
                        ttTmpRub.norub = viRubriqueAssociee
                        ttTmpRub.nolib = viLibelleAssocie
                        ttTmpRub.lbrub = vcLibelleAssocie
                        ttTmpRub.vlmtq = vdeMontantRubrique
                    .
                end.
                else ttTmpRub.vlmtq = ttTmpRub.vlmtq + vdeMontantRubrique.
            end.
        end.
    end.
    for each ttTmpRub
      , first rubqt no-lock
        where rubqt.cdrub = ttTmpRub.norub
          and rubqt.cdlib = ttTmpRub.nolib:
        /* Ajout Sy le 22/03/2010 - controle article facturation rub hono 8xx */
        if rubqt.cdfam = 8
        and not goRubriqueQuittHonoCabinet:auMoinsUnLibelleArticle(ttTmpRub.norub + 1000, ttTmpRub.nolib)
        then mError:createError({&warning}, 1000844, substitute("&2&1&3&1&4", separ[1], ttTmpRub.norub, ttTmpRub.nolib, ttTmpRub.vlmtq)).
        //Paramétrage Quittancement LF r FX incomplet (chgloypr.p). Impossible de régulariser totalement le quittancement locataire car la rubrique &1.&2 pour un montant de &3 n'a pas d'article de facturation associé (Quittancement honoraires cabinet LF r FX) Veuillez contacter la G.I.
    end.
    if glDebug then mLogger:writeLog(0, "Fin CalProratas").

end procedure.
