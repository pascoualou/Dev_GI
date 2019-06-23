/*-----------------------------------------------------------------------------
File        : genqtren.p
Purpose     : Generation des Quittances pour le renouvellement d'un bail
Fiche       : 1108/0397 - Quittancement\QuitRubriqueCalculeeV02.doc
Author(s)   : SC/MB - 25/11/1997  ,   GGA - 2018/09/21
Notes       : reprise de adb/src/quit/genqtren.p
derniere revue: 2018/12/20 - DMI: OK              

 0001  10/12/1997    SC    Changement Statut du LOCK pour la recherche
                           de la 1Šre quittance dans EQUIT => EXCLUSIVE
                           LOCK de fa‡on … pouvoir modifier Dates Appli.
 0002  08/07/1998    SY    Fiche 1629 : Ajout Maj date d'effet dans
                           equit (renouvellement)
 0003  10/03/1999    SY    Pb baux de 1 mois :
                           Calcul date de fin d'application RUB Fixes
                           'loin dans le futur'(dans 2 ans)
 0004  11/03/1999    SY    Fiche 2416 : si pas tacite reconduction,
                           utilisation de dtfin sans prolongation
 0005  04/06/1999    JC    Ajout variable partagee FgAIndex
 0006  11/02/2000    AF    PLUS DE RAZ DE LA DATE DE SORTIE LORS DU
                           RENOUVELLEMENT
 0007  10/04/2001    SY    Fiche 0401/0220 :
                           Lors du renouvellement on perdait les rub
                           variables et les nouvelles rub fixes des
                           quittances suivantes
 0008  30/10/2001   NO    Fiche 1001/0818: Test si TmRub existe avant de
                          recréer TmRub pour renouvellement
 0009  23/11/2001    SY    Pb Renouvellement GAURIAU & Michel LAURENT
                             Ajout RAZ tables tempo SavTmQtt & SavTmrub
                           + M‚morisation rubriques R‚sultat (r‚visions)
                           + Maj rubriques modifi‚es (on ne faisait que
                             des cr‚ations mais pas de maj des montants)
                           + DELETE des rubriques supprim‚es
                           + D‚tection r‚vision
 0010 14/109/2002   SY     Dev389 : Gestion du Pr‚-Bail  (01032)
                           Nlle variable globale GlbTpCtt (TbTmpQtt.i)
 0011  09/12/2002   PBP    0902/0160 correction disparition de rub fixes
 0012  25/04/2003   EK     1202/0173 correction disparition de rub fixes
                             renouvellement fait aprŠs la fin du bail.
                             Les dates d'application peuvent ˆtre
                             ant‚rieures … la nouvelle date d‚but bail
                             Initialisation de DatFapMax  affin‚e avec
                             date fin bail , date de sortie ...
 0013  22/05/2003   SY     0503/0187 correction disparition de rub fixes
                           + Pb rub variables qui se dupliquent dans
                             le futur
 0014  05/03/2004   SY     0204/0356 : mise en commentaires du DEBUG
                           (d:\tmp\finren.txt)
 0015  31/03/2004   AF     Date de fin d'application maximum au
                           31/12/2950 pour les baux en non tacite
                           reconduction et avec le module 'prolongation
                           des baux après expiration'
 0016  14/10/2005   SY     1005/0188 : raz cdrev si pas mois de quitt de
                           révision
 0017  21/06/2006   SY     0606/0209 : correction perte des rub fixes
                           lorsque les dates de fin ne sont pas égales
                           alors que le montant n'a pas été modifié
                           (cas MARNEZ : mars/avril : dtfap = 14/04/2006
                           et >= mai 2006 : dtfap = 31/12/2008)
 0018  03/12/2007    SY    DAUCHEZ : Pb multi-libellé en renouvellement
 0019  28/12/2011    SY    1211/0193 Pb GERER
                           combinaison tacite reconduction + prolongation
                           des baux après expiration
                           + Bail expiré depuis 6 ans !!!
                           modif <vdaFinApplicationMaxi.i> + equit.dtfin + vlCreationSauveRub
 0020  15/10/2013    SY    1013/0044 Manpower - modif vdaFinApplicationMaxi.i
-----------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/profil2rubQuit.i}
{preprocesseur/codeRubrique.i}
{preprocesseur/codeTaciteReconduction.i}
{preprocesseur/codeRevisionQuittance.i}

using parametre.syspr.syspr.
using parametre.pclie.parametrageRubriqueQuittHonoCabinet.

{oerealm/include/instanciateTokenOnModel.i}  // Doit être positionnée juste après using

{bail/include/tbtmpqtt.i}
{bail/include/tbtmprub.i}
{crud/include/equit.i}
{outils/include/lancementProgramme.i}               // fonctions lancementPgm, suppressionPgmPersistent
{bail/quittancement/procedureCommuneQuittance.i}    // procédures chgMoisQuittance, chgInfoMandat, isRubMod

define variable goCollectionHandlePgm as class   collection no-undo.
define variable goCollectionContrat   as class   collection no-undo.
define variable ghProc                as handle             no-undo.
define variable glDebug               as logical initial no no-undo.

define temp-table ttSauveTtQtt no-undo like ttQtt
index Ix_ttQtt01 is unique primary iNumeroLocataire iNoQuittanceFusionnee iNoQuittance.
define temp-table ttSauveTtRub no-undo like ttRub.

define stream stFicDebug.

procedure lancementGenqtren:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   : service externe
    ------------------------------------------------------------------------*/
    define input parameter piNumeroBail    as int64 no-undo.
    define input parameter pdaFinAppliMaxi as date  no-undo.

    define variable vcFichierDebug as character no-undo.

    assign
        goCollectionContrat   = new collection()
        goCollectionHandlePgm = new collection()
        .
    if glDebug then do:
        vcFichierDebug = session:temp-directory + "genqtren-" + mtoken:cRefPrincipale + ".txt" .
        if search(vcFichierDebug) <> ?
        then output stream stFicDebug to value(vcFichierDebug) append.
        else output stream stFicDebug to value(vcFichierDebug).
        put stream stFicDebug unformatted substitute("&1 &2 Renouvellement Locataire &3 FinAppliMaxi &4", today, string(time, "HH:MM:SS"),  piNumeroBail, pdaFinAppliMaxi) skip.
    end.
    run trtGenqtren (piNumeroBail, pdaFinAppliMaxi).
    if glDebug then output stream stFicDebug close.
    delete object goCollectionContrat.
    suppressionPgmPersistent(goCollectionHandlePgm).

end procedure.

procedure trtGenqtren private:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   :
    ------------------------------------------------------------------------*/
    define input parameter piNumeroBail    as int64 no-undo.
    define input parameter pdaFinAppliMaxi as date  no-undo.

    define variable viNumeroMandat         as int64   no-undo.
    define variable viMoisModifiable       as integer no-undo.
    define variable viMoisEchu             as integer no-undo.
    define variable viMoisQuittancement    as integer no-undo.
    define variable vdaEffetBail           as date    no-undo.
    define variable vdaFinBail             as date    no-undo.
    define variable vdaResilBail           as date    no-undo.
    define variable vlTacheRenouvellement  as logical init true no-undo.
    define variable vlBailFournisseurLoyer as logical no-undo.
    define variable vdaSortieLocataire     as date    no-undo.
    define variable vdaFinApplicationMaxi  as date    no-undo.
    define variable viNumeroQuittance      as integer no-undo.
    define variable vdaNouvelleRub         as date    no-undo.
    define variable viNumerateurProrata    as integer no-undo.
    define variable viDenominateurProrata  as integer no-undo.
    define variable viMoisQuitDernRev      as integer no-undo.
    define variable vlCreationSauveRub     as logical no-undo.
    define variable vlSupRub               as logical no-undo.
    define variable vlNouvQtt              as logical no-undo.
    define variable viNombreRubrique       as integer no-undo.
    define variable vdMontantQuittance     as decimal no-undo.
    define variable vlModifDate            as logical no-undo.
    define variable vlModifDtDap           as logical no-undo.
    define variable vlModifDtFap           as logical no-undo.
    define variable vdaDapRub              as date    no-undo.

    define buffer ctrat   for ctrat.
    define buffer vbctrat for ctrat.
    define buffer tache   for tache.
    define buffer equit   for equit.
    define buffer bxrbp   for bxrbp.
    define buffer vbttQtt for ttQtt.
    define buffer vbttRub for ttRub.

    define buffer vbttSauveTtRub for ttSauveTtRub.

    empty temp-table ttEquit.
    empty temp-table ttSauveTtQtt.
    empty temp-table ttSauveTtRub.
    empty temp-table ttQtt.
    empty temp-table ttRub.

    goCollectionContrat:set("iNumeroRole",    piNumeroBail).
    goCollectionContrat:set("cTypeContrat",   {&TYPECONTRAT-bail}).
    goCollectionContrat:set("iNumeroContrat", piNumeroBail).
    viNumeroMandat = truncate(piNumeroBail / 100000, 0).
    goCollectionContrat:set("iNumeroMandat", viNumeroMandat).
    run chgMoisQuittance (viNumeroMandat, input-output goCollectionContrat).
    assign
        viMoisQuittancement    = goCollectionContrat:getInteger("iMoisQuittancement")
        viMoisModifiable       = goCollectionContrat:getInteger("iMoisModifiable")
        viMoisEchu             = goCollectionContrat:getInteger("iMoisEchu")
        vlBailFournisseurLoyer = goCollectionContrat:getLogical("lBailFournisseurLoyer")
    .
    if glDebug
    then put stream stFicDebug unformatted substitute("GenQtRen.p GlMoiQtt: &1 GlMoiMdf: &2 GlMoiMec: &3 piNumeroBail: &4 FinAppliMaxi: &5", viMoisQuittancement, viMoisModifiable, viMoisEchu, piNumeroBail, pdaFinAppliMaxi) skip.
    find first ctrat no-lock
         where ctrat.tpcon = {&TYPECONTRAT-bail}
           and ctrat.nocon = piNumeroBail no-error.
    if not available ctrat then do:
        mError:createErrorGestion({&error}, 105211, string(piNumeroBail)). //bail %1 introuvable
        return.
        
    end.
    assign
        vdaEffetBail          = ctrat.dtdeb
        vdaFinBail            = ctrat.dtfin
        vdaResilBail          = ctrat.dtree
        vlTacheRenouvellement = (ctrat.tpren = {&TACITERECONDUCTION-YES})
    .
    for last tache no-lock
       where tache.tptac = {&TYPETACHE-quittancement}
         and tache.tpcon = {&TYPECONTRAT-bail}
         and tache.nocon = piNumeroBail:
        vdaSortieLocataire = tache.dtfin.  /* Date de sortie du locataire */
    end.
    ghProc = lancementPgm("tache/outilsTache.p", goCollectionHandlePgm).
    run dtFapMax in ghProc(vlTacheRenouvellement, vdaFinBail, vdaSortieLocataire, vdaResilBail, output vdaFinApplicationMaxi).
    if glDebug
    then put stream stFicDebug unformatted substitute("FinApplicationMaxi: &1 ResilBail: &2 SortieLocataire: &3 FinBail: &4", vdaFinApplicationMaxi, vdaResilBail, vdaSortieLocataire, vdaFinBail) skip.
    /* Recherche de la Premiere Quittance En cours. */
    find first equit no-lock
         where equit.noloc =  piNumeroBail
           and equit.msqtt >= (if vlBailFournisseurLoyer then viMoisModifiable else viMoisEchu) no-error.    /* Ajout SY le 09/01/2015 : ne pas prendre les vieilles quittances non historisées */
    if not available equit then do:
        mError:createError({&error}, 105208).   //la premiere quittance en cours n'est pas disponible
        return.
        
    end.
    create ttEquit.
    assign
        ttEquit.noloc         = equit.noloc
        ttEquit.noqtt         = equit.noqtt
        ttEquit.CRUD          = "U"
        ttEquit.rRowid        = rowid(equit)
        ttEquit.dtTimestamp   = datetime(equit.dtmsy, equit.hemsy)
        ttEquit.dteff         = vdaEffetBail
        ttEquit.DtSor         = ?
        ttEquit.DtFin         = (if vdaFinApplicationMaxi > equit.dtdpr and vdaFinApplicationMaxi < equit.dtfpr then vdaFinApplicationMaxi else equit.dtfpr)
        viNumerateurProrata   = (equit.dtfin - equit.dtdeb + 1)
        viDenominateurProrata = (equit.dtfpr - equit.dtdpr + 1)
        ttEquit.CdQuo         = (if viNumerateurProrata < viDenominateurProrata then 1 else 0)
        ttEquit.NbNum         = viNumerateurProrata
        ttEquit.NbDen         = viDenominateurProrata
        viNumeroQuittance     = equit.noqtt
        vdaNouvelleRub        = equit.dtfpr + 1
    .
    ghProc = lancementPgm("crud/equit_CRUD.p", goCollectionHandlePgm).
    run setEquit in ghProc(table ttEquit by-reference).
    if mError:erreur() then return.
    for last tache no-lock
       where tache.tptac = {&TYPETACHE-revision}
         and tache.tpcon = {&TYPECONTRAT-bail}
         and tache.nocon = piNumeroBail:
        if integer(tache.lbdiv2) <> 0 then viMoisQuitDernRev = integer(tache.lbdiv2).     /*  mois de quitt de la dernière revision */
    end.
    ghProc = lancementPgm("bail/quittancement/quittanceEncours.p", goCollectionHandlePgm).
    run getListeQuittance in ghProc(goCollectionContrat, input-output table ttQtt by-reference, input-output table ttRub by-reference).
    if mError:erreur() then return.

    /* Ajout SY le 21/06/2006 : correction dates d'application rub fixes si même montant brut */
    for each ttRub
       where ttRub.iNumeroLocataire = piNumeroBail
         and ttRub.cCodeGenre = {&GenreRubqt-Fixe}
    break by ttRub.iNumeroLocataire by ttRub.iNorubrique by ttRub.iNoLibelleRubrique by ttRub.iNoQuittance:
        if first-of(ttRub.iNorubrique) then do:
            assign
                vlModifDate  = yes
                vlModifDtDap = yes
                vlModifDtFap = yes
                vdaDapRub    = ttRub.daDebutApplication
            .
            for each vbttRub
               where vbttRub.iNumeroLocataire = ttRub.iNumeroLocataire
                 and vbttRub.iNoQuittance > ttRub.iNoQuittance
                 and vbttRub.iNorubrique = ttRub.iNorubrique
                 and vbttRub.iNoLibelleRubrique = ttRub.iNoLibelleRubrique:
                if vbttRub.dMontantTotal <> ttRub.dMontantTotal then do:
                    vlModifDate = no.
                    leave.
                end.
                if vbttRub.daDebutApplication <> ttRub.daDebutApplication then vlModifDtDap = no.
                if vbttRub.daFinApplication   <> ttRub.daFinApplication   then vlModifDtFap = no.
            end.
        end.
        if last-of(ttRub.iNorubrique) and vlModifDate then do:
            if not vlModifDtDap
            then for each vbttRub
                   where vbttRub.iNumeroLocataire = ttRub.iNumeroLocataire
                     and vbttRub.iNorubrique = ttRub.iNorubrique
                     and vbttRub.iNoLibelleRubrique = ttRub.iNoLibelleRubrique:
                    vbttRub.daDebutApplication = vdaDapRub.
            end.
            if not vlModifDtFap
            then for each vbttRub
                   where vbttRub.iNumeroLocataire = ttRub.iNumeroLocataire
                     and vbttRub.iNorubrique = ttRub.iNorubrique
                     and vbttRub.iNoLibelleRubrique = ttRub.iNoLibelleRubrique:
                    vbttRub.daFinApplication = vdaFinApplicationMaxi.
            end.
        end.
    end.
    /* Sauvegarde des rubriques variables des quittances futures
       Sauvegarde des Nlles rubriques Fixes des quittances futures
       Suppression de toutes les quittances sauf la 1ere */
    for each ttQtt
       where ttQtt.iNumeroLocataire =  piNumeroBail
         and ttQtt.iNoQuittance     >= viNumeroQuittance:
        create ttSauveTtQtt.
        buffer-copy ttQtt to ttSauveTtQtt.
        /* Correction pb revision qui ne change pas la date de debut d'application des rub fixes revisees */
        if ttQtt.cCodeRevisionDeLaQuittance = {&CDREVQTT-revisionAutomatique} and ttQtt.iMoisTraitementQuitt <= viMoisQuittancement
        then for each ttRub
               where ttRub.iNumeroLocataire =  ttQtt.iNumeroLocataire
                 and ttRub.iNoQuittance     =  ttQtt.iNoQuittance
                 and ttRub.iNorubrique      <> {&RUBRIQUE-MajorationLoyerMEH}
                 and ttRub.iNorubrique      <> {&RUBRIQUE-RappelouAvoirMajorationLoyerMEH}:
                for first bxrbp no-lock
                     where bxrbp.ntbai = ttQtt.cNatureBail
                       and bxrbp.norub = ttRub.iNorubrique
                       and bxrbp.nolib = ttRub.iNoLibelleRubrique :
                    if bxrbp.cdfam < 2 and bxrbp.prg02 = "00001" then do:
                        /* Traitement de revision de la rubrique a ete fait => maj dtdap sur quittance et suiv. + maj dtfap sur precedente */
                        for each vbttRub
                           where vbttRub.iNumeroLocataire = piNumeroBail
                             and vbttRub.iNoQuittance >= ttQtt.iNoQuittance
                             and vbttRub.iNorubrique = ttRub.iNorubrique
                             and vbttRub.iNoLibelleRubrique = ttRub.iNoLibelleRubrique:
                            if vbttRub.daDebutApplication < ttQtt.daDebutPeriode then vbttRub.daDebutApplication = ttQtt.daDebutPeriode.
                        end.
                        for each ttSauveTtRub
                           where ttSauvettRub.iNumeroLocataire = piNumeroBail
                             and ttSauvettRub.iNoQuittance < ttQtt.iNoQuittance
                             and ttSauvettRub.iNorubrique = ttRub.iNorubrique
                             and ttSauvettRub.iNoLibelleRubrique = ttRub.iNoLibelleRubrique:
                            if ttSauvettRub.daFinApplication >= ttQtt.daDebutPeriode then ttSauvettRub.daFinApplication = ttQtt.daDebutPeriode - 1.
                        end.
                    end.
                end.                    
        end.
        /* Ajout SY le 14/10/2005 : RAZ code révision erronné */
        if ttQtt.cCodeRevisionDeLaQuittance = {&CDREVQTT-revisionAutomatique} and viMoisQuitDernRev <> 0 and viMoisQuitDernRev <> ttQtt.iMoisTraitementQuitt
        then assign
                 ttQtt.cCodeRevisionDeLaQuittance        = {&CDREVQTT-aucunerevision}   /* Locataire n'ayant pas subi de r‚vision de loyer */
                 ttSauvettQtt.cCodeRevisionDeLaQuittance = {&CDREVQTT-aucunerevision}   /* Locataire n'ayant pas subi de r‚vision de loyer */
        .
        for each ttRub
           where ttRub.iNumeroLocataire = piNumeroBail
             and ttRub.iNoQuittance     = ttQtt.iNoQuittance:   /* SY - corrig‚ le 22/11/2001 */
            assign
                vlCreationSauveRub = no
                vlSupRub           = no
            .
            if ttRub.cCodeGenre = {&GenreRubqt-Fixe} then do:
                /* Rubrique Fixe : Memoriser si nouvelle rubrique
                                   ou si rubrique modifiee = date de fin d'application ne correspond pas a l'ancienne date de fin de bail (PBP 09/12/2002) */
                if ttRub.daDebutApplication >= vdaNouvelleRub
                or (pdaFinAppliMaxi <> ? and ttRub.daFinApplication > ttQtt.daDebutPeriode and ttRub.daFinApplication < ttQtt.daFinPeriode and ttRub.daFinApplication <> pdaFinAppliMaxi)
                then vlCreationSauveRub = yes.
                if (pdaFinAppliMaxi <> ? and ttRub.daFinApplication < ttQtt.daFinPeriode and ttRub.daFinApplication <> pdaFinAppliMaxi)
                then vlSupRub = yes.
            end.
            /* Memoriser les rubriques Variables et Resultat (revision) */
            if ttRub.cCodeGenre = {&GenreRubqt-Variable} or ttRub.cCodeGenre = {&GenreRubqt-Resultat}
            then vlCreationSauveRub = yes.
            if glDebug and ttRub.cCodeGenre = {&GenreRubqt-Fixe}
            then put stream stFicDebug unformatted
                        "GENQTREN Rub FIXE" skip
                        substitute("ttQtt.iMoisTraitementQuitt           : &1 Periode: &2-&3", ttQtt.iMoisTraitementQuitt, ttQtt.daDebutPeriode, ttQtt.daFinPeriode) skip
                        substitute("ttRub.iNorubrique           : &1", ttRub.iNorubrique) skip
                        substitute("ttRub.daDebutApplication           : &1 NouvelleRub &2", ttRub.daDebutApplication, vdaNouvelleRub) skip
                        substitute("ttRub.daFinApplication           : &1", ttRub.daFinApplication) skip
                        substitute("pdaFinAppliMaxi       : &1", pdaFinAppliMaxi) skip
                        substitute("vdaFinApplicationMaxi : &1", vdaFinApplicationMaxi) skip
                        substitute("vlCreationSauveRub    : &1", vlCreationSauveRub) skip
                        substitute("vlSupRub              : &1", vlSupRub) skip.
            if vlCreationSauveRub then do:
                create ttSauveTtRub.
                buffer-copy ttRub to ttSauveTtRub.
                if ttRub.cCodeGenre = {&GenreRubqt-Fixe} and not vlSupRub // Forcer la Date d'Application des Rubriques Fix de cette Quittance = Date Fin appli Max sauf si rub supprimee 
                then ttSauvettRub.daFinApplication = vdaFinApplicationMaxi.
            end.
            if ttQtt.iNoQuittance > viNumeroQuittance then delete ttRub.
        end.
        if ttQtt.iNoQuittance > viNumeroQuittance then delete ttQtt.
    end.
    /* Forcer Code maj des quittances */
    for each ttQtt
       where ttQtt.iNumeroLocataire = piNumeroBail:
        assign
            ttQtt.daSortie = ?
            ttQtt.CdMaj    = 1
        .
    end.
    /* Mise à jour des dates d'application 1ere quittance */
    for each ttRub
       where ttRub.iNumeroLocataire = piNumeroBail
         and ttRub.iNoQuittance     = viNumeroQuittance
         and ttRub.cCodeGenre       = {&GenreRubqt-Fixe}:
        ttRub.daFinApplication      = vdaFinApplicationMaxi.
    end.
    /* Module de generation des Avis d'echeance suiv. */
    ghProc = lancementPgm("bail/quittancement/majpecqt.p", goCollectionHandlePgm).
    run lancementMajQuittancelocataire in ghProc(goCollectionContrat,
                                                 viNumeroQuittance,
                                                 input-output table ttQtt by-reference,
                                                 input-output table ttRub by-reference).
    if mError:erreur() then return.
    
    if glDebug then do:
        for each ttRub where ttRub.iNumeroLocataire = piNumeroBail:
            put stream stFicDebug unformatted substitute("genqtren apres MajPecQt ttRub: &1 &2 &3 - &4 &5", ttRub.iNoQuittance, ttRub.iNorubrique, ttRub.daDebutApplication, ttRub.daFinApplication, ttRub.dMontantTotal) skip.
        end.
        for each ttSauveTtRub:
            put stream stFicDebug unformatted "ttSauveTtRub: " ttSauvettRub.iNumeroLocataire " " ttSauvettRub.iNoQuittance " " ttSauvettRub.iNorubrique " " ttSauvettRub.daDebutApplication " - " ttSauvettRub.daFinApplication " " ttSauvettRub.dMontantTotal skip.
            put stream stFicDebug unformatted substitute("ttSauveTtRub: &1 &2 &3 &4 - &5 &6", ttSauvettRub.iNumeroLocataire, ttSauvettRub.iNoQuittance, ttSauvettRub.iNorubrique, ttSauvettRub.daDebutApplication, ttSauvettRub.daFinApplication, ttSauvettRub.dMontantTotal) skip.
        end.
        for each ttSauveTtQtt:
            put stream stFicDebug unformatted "ttSauveTtQtt: " ttSauvettQtt.iNumeroLocataire " " ttSauvettQtt.iNoQuittance " " ttSauvettQtt.iMoisTraitementQuitt skip.
            put stream stFicDebug unformatted substitute("ttSauveTtQtt: &1 &2 &3", ttSauvettQtt.iNumeroLocataire, ttSauvettQtt.iNoQuittance, ttSauvettQtt.iMoisTraitementQuitt) skip.
        end.
    end.
    for each ttQtt
       where ttQtt.iNumeroLocataire = piNumeroBail
         and ttQtt.iNoQuittance >= viNumeroQuittance:
         /* Pour chaque quittance future on recupere les modifications de rubriques
            PBP 09/12/2002 pour une nouvelle quittance (ttQtt sans ttSauveTtQtt) on recupere les modif de rubriques de la derniere quittance existante
            SY 22/05/2003 : POUR RUB FIXE UNIQUEMENT (cas non tacite, rub fixe saisie dans qtt future puis recul date expiration) */
        vlNouvQtt = no.
        find first ttSauveTtQtt
             where ttSauvettQtt.iNumeroLocataire = ttQtt.iNumeroLocataire
               and ttSauvettQtt.iMoisTraitementQuitt = ttQtt.iMoisTraitementQuitt no-error.
        if not available ttSauveTtQtt then do:
            vlNouvQtt = yes.
            find last ttSauveTtQtt where ttSauvettQtt.iNumeroLocataire = ttQtt.iNumeroLocataire use-index Ix_ttQtt01 no-error.
            if not available ttSauveTtQtt then next.
        end.
        if not vlNouvQtt then do:
            /*--> Maj entete de la quittance */
            buffer-copy ttSauveTtQtt to ttQtt.
            if ttQtt.daDebutPeriode <= vdaEffetBail and vdaEffetBail <= ttQtt.daFinPeriode
            then ttQtt.daEffetBail = vdaEffetBail.
            for each ttSauveTtRub
               where ttSauvettRub.iNumeroLocataire = piNumeroBail
                 and ttSauvettRub.iNoQuittance = ttSauvettQtt.iNoQuittance:
                /*--> Ajout ou Modif des rubriques modifiees */
                find first ttRub
                     where ttRub.iNumeroLocataire = piNumeroBail
                       and ttRub.iNoQuittance = ttQtt.iNoQuittance
                       and ttRub.iNorubrique = ttSauvettRub.iNorubrique
                       and ttRub.iNoLibelleRubrique = ttSauvettRub.iNoLibelleRubrique no-error.
                if not available ttRub then do:
                    create ttRub.
                    buffer-copy ttSauveTtRub except iNoQuittance to ttRub
                    assign
                        ttRub.iNoQuittance = ttQtt.iNoQuittance.
                end.
                else do:
                    buffer-copy ttSauveTtRub except iNoQuittance to ttRub
                    assign
                        ttRub.iNoQuittance = ttQtt.iNoQuittance
                    .
                    /*--> Gestion rub fixe supprimée */
                    /*    Supprimer la rub generee par majpecqt dans les quittances non concernees */
                    if ttRub.cCodeGenre = {&GenreRubqt-Fixe} and ttRub.daFinApplication < vdaFinApplicationMaxi
                    then for each vbttQtt
                           where vbttQtt.iNumeroLocataire = piNumeroBail
                             and vbttQtt.iNoQuittance > ttQtt.iNoQuittance
                             and vbttQtt.daDebutPeriode > ttRub.daFinApplication
                           , each vbttRub
                            where vbttRub.iNumeroLocataire = piNumeroBail
                              and vbttRub.iNoQuittance = vbttQtt.iNoQuittance
                              and vbttRub.iNorubrique = ttRub.iNorubrique
                              and vbttRub.iNoLibelleRubrique = ttRub.iNoLibelleRubrique:
                            delete vbttRub.
                    end.
                end.
            end.
        end.
        else do:
            /*--> Recuperation des rub fixes uniquement */
            for each ttSauveTtRub
               where ttSauvettRub.iNumeroLocataire = piNumeroBail
                 and ttSauvettRub.iNoQuittance = ttSauvettQtt.iNoQuittance
                 and ttSauvettRub.cCodeGenre = {&GenreRubqt-Fixe}:
                /*--> Ajout ou Modif des rubriques modifiees */
                find first ttRub
                     where ttRub.iNumeroLocataire = piNumeroBail
                       and ttRub.iNoQuittance = ttQtt.iNoQuittance
                       and ttRub.iNorubrique = ttSauvettRub.iNorubrique
                       and ttRub.iNoLibelleRubrique = ttSauvettRub.iNoLibelleRubrique no-error.        /* Modif SY le 03/12/2007 : gestion multi-libellé */
                if not available ttRub then do:
                    create ttRub.
                    buffer-copy ttSauveTtRub except iNoQuittance to ttRub
                    assign
                        ttRub.iNoQuittance = ttQtt.iNoQuittance
                    .
                end.
                else do:
                    buffer-copy ttSauveTtRub except iNoQuittance to ttRub
                    assign
                        ttRub.iNoQuittance = ttQtt.iNoQuittance
                    .
                end.
            end.
        end.
        /*--> Mise a jour de la quittance : nbrub / mtqtt */
        assign
            viNombreRubrique   = 0
            vdMontantQuittance = 0.
        for each vbttRub
           where vbttRub.iNumeroLocataire = piNumeroBail
             and vbttRub.iNoQuittance = ttQtt.iNoQuittance:
            assign
                viNombreRubrique   = viNombreRubrique   + 1
                vdMontantQuittance = vdMontantQuittance + vbttRub.dMontantQuittance
            .
        end.
        assign
            ttQtt.iNombreRubrique   = viNombreRubrique
            ttQtt.dMontantQuittance = vdMontantQuittance
        .
    end.
    if glDebug then do:
        put stream stFicDebug unformatted substitute("Locataire &1 ttQtt/ttRub :", piNumeroBail) skip.
        for each ttQtt:
            export stream stFicDebug ttQtt except ttQtt.rRowid  .
            for each ttRub
               where ttRub.iNumeroLocataire = ttQtt.iNumeroLocataire
                 and ttRub.iNoQuittance     = ttQtt.iNoQuittance:
                export stream stFicDebug ttRub except ttRub.rRowid .
            end.
        end.
    end.
    /* Stockage des infos de ttQtt et ttRub dans Equit */
    ghProc = lancementPgm("bail/quittancement/crelocqt.p", goCollectionHandlePgm).
    run lancementCrelocqt in ghProc(piNumeroBail, input-output table ttQtt by-reference, input-output table ttRub by-reference).
    if mError:erreur() then return.

    if glDebug
    then put stream stFicDebug unformatted substitute("*** FIN *** Renouvellement Locataire &1", piNumeroBail) skip.
end procedure.
