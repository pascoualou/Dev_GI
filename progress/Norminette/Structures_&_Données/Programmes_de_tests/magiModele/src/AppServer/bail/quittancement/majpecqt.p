/*-----------------------------------------------------------------------------
File        : majpecqt.p
Purpose     :  Mise a jour des quittances d'un locataire suite a une prise en charge
               Generation des 2 … n quittances dans ttQtt et ttRub, suite a la saisie de la 1ere quittance 
Author(s)   : SP 17/04/1996  -  GGA 2018/06/11
Notes       : reprise de adb/quit/majpecqt_ext.p
derniere revue: 2018/08/14 - phm: 

01  08/04/1997  RT    Recalcul de la date de la premiŠre quittance selon le mois modifiable de quittancement.
02  28/04/1997  RT    Modification assignation DtMoiMdf
03  04/06/1997  SY    Correction erreur ASSIGN ttRub (CREATE perdu). Utilisation procédure CalInfPer de L_Prgdat.p pour les calculs de fin de période, Msqui et Msqtt
04  01/12/1997  BV    Ajout de l'extension ".p" dans l'appel à l_prgdat.p
05  05/12/1997  SC    Ajout de l'extension ".p" pour L_Ctrat.p ... 
                        Légère correction du source pour qu'il puisse servir lors du renouvellement d'un Bail:
                        Dans ce cas, le No de la quittance passé en paramètre est rarement à 1 => corriger la borne NbQttMax en fonction de ce iNumeroQuittance...
06  23/01/1998  SC    On ne prend plus la date théorique de Fin de Bail pour arrêter la génération des Avis d'échéance...
07  02/04/1998  SC    Prise en compte du Code Retour de CreRubCa.p
08  13/11/1998  LG    Fiche 2006: pb de renouvellement sur des baux de 1 mois. On générait ttRub ssi date de fin appli. >= vdaFinQuittancement or dans ce cas elle était <.
09  07/01/1999  SY    Fiche 2230: Suite à la modif ci-dessus, les rubriques variables (dépot garantie...) étaient dupliquées sur toutes les quittances
10  10/03/1999  SY    Gestion de la date de fin d'application RUB (sinon dtfap < dt deb qtt suite fiche 2006 !)
                        Remplacement de la date infinie "01/01/9999"  par une date 'loin dans le futur'(dans 2 ans)
11  11/03/1999  SY    Fiche 2416 : si pas tacite reconduction, utilisation de dtfin sans prolongation
12  15/04/1999  SY    Modifs précédentes dupliquées pour dernière quittance
13  10/10/2000  JC    ManPower: Modif calcul MsQtt: le mois de traitement est toujours le 1er de la période => calcul comme si locataire Avance
                        On ne prend plus la date theorique de fin de bail pour arreter la generation des avis d'echeance.
14  14/10/2002  SY    Dev389: Gestion du Pré-Bail (01032). ATTENTION : à livrer avec TbTmpQtt.i & programmes avec "NEW SHARED" tbtmpQtt.i
15  29/04/2003  EK    1202/0173 correction disparition de rub fixes. renouvellement fait après la fin du bail. Initialisation de DatFapMax  affinée avec date fin bail, date de sortie ...
16  22/05/2003  SY    0503/0187 correction disparition de rub fixes. le code révision doit etre à "00000" sur les quittances futures
17  05/04/2004  AF    Module prolongation apres expiration
18  28/11/2005  SY    1105/0144 : Amélioration gestion dates pour ne pas perdre les dates d'application des Rub si l'une d'elles est invalide
19  17/03/2010  SY    1209/0168 Amélioration gestion montants à ? pour ne pas les perdre si l'un d'eux est invalide
20  15/11/2012  SY    1112/0058 Ajout trace Mlog
-----------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/referenceClient.i}
{preprocesseur/param2locataire.i}
{preprocesseur/codeTaciteReconduction.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{bail/include/tbtmpqtt.i}
{bail/include/tbtmprub.i}

{outils/include/lancementProgramme.i}                // fonctions lancementPgm, suppressionPgmPersistent

define variable goCollectionHandlePgm as class collection no-undo.
define variable goCollectionQuittance as class collection no-undo.
define variable ghProc        as handle  no-undo.
define variable ghPrgdat      as handle  no-undo.
define variable ghOutilsTache as handle  no-undo.
define variable glDebug       as logical no-undo initial true.

procedure lancementMajQuittancelocataire:
    /*------------------------------------------------------------------------
        Purpose:
        Notes:    service externe
    ------------------------------------------------------------------------*/
    define input parameter poCollectionContrat as class collection no-undo.
    define input parameter piNumeroQuittance as integer no-undo.
    define input-output parameter table for ttQtt.
    define input-output parameter table for ttRub.

    assign 
        goCollectionQuittance = new collection()
        goCollectionHandlePgm = new collection()
        ghPrgdat              = lancementPgm("application/l_prgdat.p", goCollectionHandlePgm)
        ghOutilsTache         = lancementPgm("tache/outilstache.", goCollectionHandlePgm)
    .
    run majQuittancelocataire(poCollectionContrat, piNumeroQuittance).
    suppressionPgmPersistent(goCollectionHandlePgm).   
    delete object goCollectionQuittance no-error. 

end procedure.

procedure majQuittancelocataire private:
    /*------------------------------------------------------------------------
        Purpose:
        Notes:    
    ------------------------------------------------------------------------*/
    define input parameter poCollectionContrat as class collection no-undo.
    define input parameter piNumeroQuittance   as integer no-undo.

    define variable viNumeroLocataire             as integer   no-undo.
    define variable vcTypeContrat                 as character no-undo.
    define variable viI                           as integer   no-undo. 
    define variable vcCodeFamille                 as character no-undo.
    define variable vcCodeSousFamille             as character no-undo.
    define variable vcNumeroRubrique              as character no-undo.
    define variable vcNumeroLibelle               as character no-undo.
    define variable vcLibelleRubrique             as character no-undo.
    define variable vcCodeGenre                   as character no-undo.
    define variable vcCodeSigne                   as character no-undo.
    define variable vcLsDetSav                    as character no-undo.
    define variable vcQuantite                    as character no-undo.
    define variable vcPrixUnitaire                as character no-undo.
    define variable vcMontantTotal                as character no-undo.
    define variable vcProrata                     as character no-undo.
    define variable vcNumerateurProrata           as character no-undo.
    define variable vcDenominateurProrata         as character no-undo.
    define variable vcLsMtqSav                    as character no-undo.
    define variable vcDebutApplication            as character no-undo.
    define variable vcFinApplication              as character no-undo.
    define variable vcFil                         as character no-undo.
    define variable vdadaDebutPeriode             as date      no-undo.
    define variable vdaFinPeriode                 as date      no-undo.
    define variable vdaDebutQuittancement         as date      no-undo.
    define variable vdaFinQuittancement           as date      no-undo.
    define variable vdaFinBail                    as date      no-undo.
    define variable vlTaciteReconductionBail      as logical   no-undo initial true.
    define variable vdaResBail                    as date      no-undo.
    define variable vdaFinApplicationMaxi         as date      no-undo.
    define variable vdaDtSorLoc                   as date      no-undo.
    define variable viMoisTraitementQuittancement as integer   no-undo.
    define variable viMoisQuittancement           as integer   no-undo.
    define variable viNombreQuittanceMax          as integer   no-undo.
    define variable viNombreRubriqueMax           as integer   no-undo.
    define variable viNumerateurProrata           as integer   no-undo.
    define variable viDenominateurProrata         as integer   no-undo.
    define variable viPeriodiciteQuittancement    as integer   no-undo.
    define variable vcCodeTerme                   as character no-undo.
    define variable vlCreationRubrique            as logical   no-undo.
    define variable vdaDtFapRub                   as date      no-undo.

    define buffer ctrat   for ctrat.
    define buffer tache   for tache.
    define buffer vbttQtt for ttQtt.

    assign 
        vcTypeContrat     = poCollectionContrat:getCharacter("cTypeContrat")
        viNumeroLocataire = poCollectionContrat:getInteger("iNumeroContrat")
    .
    /* Recuperation des infos des rubriques */
    for each ttRub  
        where ttRub.iNumeroLocataire = viNumeroLocataire
          and ttRub.iNoQuittance = piNumeroQuittance:
        assign  
            vcCodeFamille         = substitute("&1|&2", vcCodeFamille, ttRub.iFamille)
            vcCodeSousFamille     = substitute("&1|&2", vcCodeSousFamille, ttRub.iSousFamille)
            vcNumeroRubrique      = substitute("&1|&2", vcNumeroRubrique, ttRub.iNorubrique)
            vcNumeroLibelle       = substitute("&1|&2", vcNumeroLibelle, ttRub.iNoLibelleRubrique)
            vcLibelleRubrique     = substitute("&1|&2", vcLibelleRubrique, ttRub.cLibelleRubrique)
            vcCodeGenre           = substitute("&1|&2", vcCodeGenre, ttRub.cCodeGenre)
            vcCodeSigne           = substitute("&1|&2", vcCodeSigne, ttRub.cCodeSigne)
            vcLsDetSav            = substitute("&1|&2", vcLsDetSav, ttRub.cdDet)
            vcQuantite            = substitute("&1|&2", vcQuantite, ttRub.dQuantite)
            vcPrixUnitaire        = substitute("&1|&2", vcPrixUnitaire, ttRub.dPrixunitaire)
            vcMontantTotal        = substitute("&1|&2", vcMontantTotal, if ttRub.dMontantTotal <> ? then ttRub.dMontantTotal else 0)
            vcProrata             = substitute("&1|&2", vcProrata, ttRub.iProrata)
            vcNumerateurProrata   = substitute("&1|&2", vcNumerateurProrata, if ttRub.iNumerateurProrata <> ? then ttRub.iNumerateurProrata else 0)
            vcDenominateurProrata = substitute("&1|&2", vcDenominateurProrata, if ttRub.iDenominateurProrata <> ? then ttRub.iDenominateurProrata else 0)
            vcLsMtqSav            = substitute("&1|&2", vcLsMtqSav, if ttRub.dMontantQuittance <> ? then ttRub.dMontantQuittance else 0)
            vcDebutApplication    = substitute("&1|&2", vcDebutApplication, if ttRub.daDebutApplication <> ? then ttRub.daDebutApplication else today)
            vcFinApplication      = substitute("&1|&2", vcFinApplication, if ttRub.daFinApplication <> ? then ttRub.daFinApplication else today)
            vcFil                 = substitute("&1|&2", vcFil, ttRub.daDebutApplicationPrecedente)
            .
    end.
    //ne pas utiliser fonction trim pour retirer le premier separateur (ne fonctionne pas si zone vide, ex ||2|3 devient 2|3 alors qu'il faut obtenir |2|3) 
    assign
        vcCodeFamille         = substring(vcCodeFamille, 2) 
        vcCodeSousFamille     = substring(vcCodeSousFamille, 2) 
        vcNumeroRubrique      = substring(vcNumeroRubrique, 2) 
        vcNumeroLibelle       = substring(vcNumeroLibelle, 2) 
        vcLibelleRubrique     = substring(vcLibelleRubrique, 2) 
        vcCodeGenre           = substring(vcCodeGenre, 2) 
        vcCodeSigne           = substring(vcCodeSigne, 2) 
        vcLsDetSav            = substring(vcLsDetSav, 2) 
        vcQuantite            = substring(vcQuantite, 2) 
        vcPrixUnitaire        = substring(vcPrixUnitaire, 2) 
        vcMontantTotal        = substring(vcMontantTotal, 2) 
        vcProrata             = substring(vcProrata, 2) 
        vcNumerateurProrata   = substring(vcNumerateurProrata, 2) 
        vcDenominateurProrata = substring(vcDenominateurProrata, 2) 
        vcLsMtqSav            = substring(vcLsMtqSav, 2) 
        vcDebutApplication    = substring(vcDebutApplication, 2) 
        vcFinApplication      = substring(vcFinApplication, 2) 
        vcFil                 = substring(vcFil, 2)
        viNombreRubriqueMax   = num-entries(vcNumeroRubrique, "|") 
    .
    if glDebug then mLogger:writeLog(0, substitute("Locataire &1 Quittance de référence = &2 vcNumeroRubrique = &3", viNumeroLocataire, piNumeroQuittance, vcNumeroRubrique)).
    /* Suppression des quittances du locataire sauf la 1ere quittance / ou Qtt référence */
    for each ttQtt  
        where ttQtt.iNumeroLocataire = viNumeroLocataire
          and ttQtt.iNoQuittance > piNumeroQuittance:
        if glDebug then mLogger:writeLog(0, substitute("Locataire &1: Suppression ttQtt no &2 Mois &3", viNumeroLocataire, ttQtt.iNoQuittance, ttQtt.iMoisTraitementQuitt)).
        delete ttQtt.
    end.
    for each ttRub  
        where ttRub.iNumeroLocataire = viNumeroLocataire
          and ttRub.iNoQuittance > piNumeroQuittance:
        delete ttRub.
    end.
    /* Acces a la 1ere quittance de ttQtt */
    find first vbttQtt   
        where vbttQtt.iNumeroLocataire = viNumeroLocataire
          and vbttQtt.iNoQuittance = piNumeroQuittance no-error.
    if not available vbttQtt then do:
        if glDebug then mLogger:writeLog(0, substitute("Locataire &1 Quittance de référence = &2 non trouvée...", viNumeroLocataire, piNumeroQuittance)).
        mError:createError({&error}, 1000853, string(piNumeroQuittance)).   // problème maj quittance &1, erreur sur table quittance
        return.
    end.
    if glDebug then mLogger:writeLog(0, substitute("Locataire &1 Quittance de référence = &2 Mois Quitt: &3 vcMontantTotal = &4", viNumeroLocataire, piNumeroQuittance, vbttQtt.iMoisTraitementQuitt, vcMontantTotal)).
    /* Recuperation du terme de la periodicite et du nombre de mois de la periode */
    assign 
        viPeriodiciteQuittancement = integer(substring(vbttQtt.cPeriodiciteQuittancement, 1, 3, "character"))
        vcCodeTerme                = (if integer(mToken:cRefPrincipale) = {&REFCLIENT-MANPOWER} then {&TERMEQUITTANCEMENT-avance} else vbttQtt.cCodeTerme)     // Spécif Manpower : calcul comme si locataire Avance
    .
    /* Nombre max de quittances a generer */
    case viPeriodiciteQuittancement:
        when 1 then viNombreQuittanceMax = 13.
        when 2 then viNombreQuittanceMax = 7.
        when 3 then viNombreQuittanceMax = 5.
        when 6 then viNombreQuittanceMax = 3.
        otherwise   viNombreQuittanceMax = 2.
    end case.
    /* Calcul des dates de la prochaine quittance */
    assign
        vdadaDebutPeriode     = vbttQtt.daFinPeriode + 1
        vdaDebutQuittancement = vdadaDebutPeriode
    .
    /* Calcul date de fin de periode , Calcul mois quitt et mois traitement GI */
    run calInfPer in ghPrgdat(vdadaDebutPeriode, viPeriodiciteQuittancement, vcCodeTerme, output vdaFinPeriode, output viMoisQuittancement, output viMoisTraitementQuittancement).
    vdaFinQuittancement = vdaFinPeriode.

    /* Recuperation de la date de fin de bail et de la date de resiliation pour calcul d'une date de fin application 'loin dans le futur' */
    for first ctrat no-lock
        where ctrat.TpCon = vcTypeContrat
          and ctrat.NoCon = viNumeroLocataire:
        assign  
            vdaFinBail               = ctrat.Dtfin 
            vdaResBail               = ctrat.DtRee 
            vlTaciteReconductionBail = (ctrat.TpRen = {&TACITERECONDUCTION-YES})
        .
    end.
    /* Recherche de la date de sortie locataire */
    for last tache no-lock
        where tache.tptac = {&TYPETACHE-quittancement}
          and tache.tpcon = {&TYPECONTRAT-bail}
          and tache.nocon = viNumeroLocataire:
        vdaDtSorLoc = tache.dtfin.  /* Date de sortie du locataire */
    end.
    /*--> Calcul de la date de fin d'application maximum */
    run dtFapMax in ghOutilsTache(vlTaciteReconductionBail, vdaFinBail, vdaDtSorLoc, vdaResBail, output vdaFinApplicationMaxi).
    /* Correction du Nombre de Quitt Max a generer. (Concerne la cas ou l'on renouvelle le bail et donc que l'on ne commence pas a NoQtt=1). */ 
    viNombreQuittanceMax = (piNumeroQuittance + viNombreQuittanceMax) - 1.

    /* Creation des prochaine quittances */
    do while vdaFinQuittancement <= vdaFinApplicationMaxi and piNumeroQuittance < viNombreQuittanceMax:
        create ttQtt.
        assign  
            piNumeroQuittance = piNumeroQuittance + 1
            ttQtt.iNumeroLocataire       = viNumeroLocataire
            ttQtt.iNoQuittance       = piNumeroQuittance
            ttQtt.iMoisTraitementQuitt       = viMoisTraitementQuittancement
            ttQtt.iMoisReelQuittancement       = viMoisQuittancement
            ttQtt.daDebutQuittancement       = vdaDebutQuittancement
            ttQtt.daFinQuittancement       = vdaFinQuittancement
            ttQtt.daDebutPeriode       = vdadaDebutPeriode
            ttQtt.daFinPeriode       = vdaFinPeriode
            ttQtt.cPeriodiciteQuittancement       = vbttQtt.cPeriodiciteQuittancement
            ttQtt.cNatureBail       = vbttQtt.cNatureBail
            ttQtt.iDureeBail       = vbttQtt.iDureeBail
            ttQtt.cUniteDureeBail       = vbttQtt.cUniteDureeBail
            ttQtt.daEffetBail       = vbttQtt.daEffetBail
            ttQtt.cCodeTypeIndiceRevision       = vbttQtt.cCodeTypeIndiceRevision
            ttQtt.cPeriodiciteIndiceRevision       = vbttQtt.cPeriodiciteIndiceRevision
            ttQtt.iPeriodeAnneeIndiceRevision       = vbttQtt.iPeriodeAnneeIndiceRevision
            ttQtt.daProchaineRevision       = vbttQtt.daProchaineRevision
            ttQtt.daTraitementRevision       = vbttQtt.daTraitementRevision
            ttQtt.cCodeModeReglement       = vbttQtt.cCodeModeReglement
            ttQtt.cCodeTerme       = vbttQtt.cCodeTerme
            ttQtt.daEntre       = vbttQtt.daEntre
            ttQtt.daSortie       = vbttQtt.daSortie
            ttQtt.iNumeroImmeuble       = vbttQtt.iNumeroImmeuble
            ttQtt.dMontantQuittance       = 0
            ttQtt.iNombreRubrique       = 0
            ttQtt.iProrata       = 0
            ttQtt.iNumerateurProrata       = 0
            ttQtt.iDenominateurProrata       = 0
            ttQtt.cCodeEditionDepotGarantie       = vbttQtt.cCodeEditionDepotGarantie
            ttQtt.cCodeEditionSolde       = vbttQtt.cCodeEditionSolde
            ttQtt.cCodeRevisionDeLaQuittance       = "00000"
            ttQtt.CdPrv       = vbttQtt.CdPrv
            ttQtt.CdPrs       = vbttQtt.CdPrs
            ttQtt.NbEdt       = vbttQtt.NbEdt
            ttQtt.CdMaj       = 1
            ttQtt.CdOri       = "F"
        .
        if glDebug then mLogger:writeLog (0, substitute("Creation ttQtt: Bail &1 No &2 Mois: &3 du &4 au &5", ttQtt.iNumeroLocataire, ttQtt.iNoQuittance, ttQtt.iMoisTraitementQuitt, ttQtt.daDebutPeriode, ttQtt.daFinPeriode)).
        /* Parcours des listes d'infos des rubriques */
        do viI = 1 to viNombreRubriqueMax:
            vlCreationRubrique = no.
            if integer(entry(viI, vcCodeGenre, "|")) = 1
            then do:
                /* Rubriques Fixes : Date fin appli >= date fin quit ===> 
                ATTENTION cela marche si le bail est sur 1 AN mais plus sur 1 mois car date de fin appli. < vdaFinQuittancement. Mieux vaut tester avec date vdaFinApplicationMaxi */
                if vdaFinApplicationMaxi >= vdaFinQuittancement 
                then assign  
                    vlCreationRubrique = yes
                    vdaDtFapRub        = vdaFinApplicationMaxi
                .
            end.
            else if date(entry(viI,vcFinApplication,"|")) >= vdaFinQuittancement 
            then assign  
                vlCreationRubrique = yes
                vdaDtFapRub = date(entry(viI,vcFinApplication,"|"))
            .
            if vlCreationRubrique then do:
                /* Cette rubrique est appliquable pour cette quit Maj des elements du prorata */
                assign  
                    entry(viI, vcProrata, "|")             = "0"
                    entry(viI, vcNumerateurProrata, "|")   = "0"
                    entry(viI, vcDenominateurProrata, "|") = "0"
                    entry(viI, vcLsMtqSav, "|")            = entry(viI, vcMontantTotal, "|")
                .
                create ttRub.
                assign
                    ttRub.iNumeroLocataire = viNumeroLocataire
                    ttRub.iNoQuittance = piNumeroQuittance
                    ttRub.iFamille = integer(entry(viI, vcCodeFamille, "|"))
                    ttRub.iSousFamille = integer(entry(viI, vcCodeSousFamille, "|"))
                    ttRub.iNorubrique = integer(entry(viI, vcNumeroRubrique, "|"))
                    ttRub.iNoLibelleRubrique = integer(entry(viI, vcNumeroLibelle, "|"))
                    ttRub.cLibelleRubrique = entry(viI, vcLibelleRubrique, "|")
                    ttRub.cCodeGenre = entry(viI, vcCodeGenre, "|")
                    ttRub.cCodeSigne = entry(viI, vcCodeSigne, "|")
                    ttRub.CdDet = entry(viI, vcLsDetSav, "|")
                    ttRub.dQuantite = decimal(entry(viI, vcQuantite, "|"))
                    ttRub.dPrixunitaire = decimal(entry(viI, vcPrixUnitaire, "|"))
                    ttRub.dMontantTotal = decimal(entry(viI, vcMontantTotal, "|"))
                    ttRub.iProrata = integer(entry(viI, vcProrata, "|"))
                    ttRub.iNumerateurProrata = integer(entry(viI, vcNumerateurProrata, "|"))
                    ttRub.iDenominateurProrata = integer(entry(viI, vcDenominateurProrata, "|"))
                    ttRub.dMontantQuittance = decimal(entry(viI, vcLsMtqSav, "|"))
                    ttRub.daDebutApplication = date(entry(viI, vcDebutApplication, "|"))
                    ttRub.daFinApplication = vdaDtFapRub
                    ttRub.daDebutApplicationPrecedente = entry(viI, vcFil, "|")
                    /* Maj du montant de la quit et du nbre de rub. */
                    ttQtt.dMontantQuittance = ttQtt.dMontantQuittance + decimal(entry(viI, vcLsMtqSav, "|"))
                    ttQtt.iNombreRubrique = ttQtt.iNombreRubrique + 1
                .
                if glDebug
                then mLogger:writeLog(0, substitute("Creation ttRub: Bail &1 No &2 Rub &3.&4 Montant = &5 Dates appl: &6-&7", ttQtt.iNumeroLocataire, ttQtt.iNoQuittance, ttRub.iNorubrique, string(ttRub.iNoLibelleRubrique, "99"), ttRub.dMontantQuittance, ttRub.daDebutApplication, ttRub.daFinApplication)).
            end.
        end. /* Parcours des listes d'infos des rubriques */
        /* Calcul des dates de la prochaine quittance */
        assign
            vdadaDebutPeriode     = vdaFinPeriode + 1
            vdaDebutQuittancement = vdadaDebutPeriode
        .
        /* Calcul date de fin de periode , Calcul mois quitt et mois traitement GI */
        run calInfPer in ghPrgdat(vdadaDebutPeriode, viPeriodiciteQuittancement, vcCodeTerme, output vdaFinPeriode, output viMoisQuittancement, output viMoisTraitementQuittancement).
        vdaFinQuittancement = vdaFinPeriode.
    end.
    /* Creation eventuelle de la derniere quittance */
    if vdaDebutQuittancement < vdaFinApplicationMaxi and piNumeroQuittance < viNombreQuittanceMax then do:
        create ttQtt.
        assign
            /* Maj de la date de fin de la quittance */
            vdaFinQuittancement   = vdaFinApplicationMaxi
            viNumerateurProrata   = vdaFinQuittancement - vdadaDebutPeriode + 1
            viDenominateurProrata = vdaFinPeriode - vdadaDebutPeriode + 1
            piNumeroQuittance     = piNumeroQuittance + 1
            ttQtt.iNumeroLocataire           = viNumeroLocataire
            ttQtt.iNoQuittance           = piNumeroQuittance
            ttQtt.iMoisTraitementQuitt           = viMoisTraitementQuittancement
            ttQtt.iMoisReelQuittancement           = viMoisQuittancement
            ttQtt.daDebutQuittancement           = vdaDebutQuittancement
            ttQtt.daFinQuittancement           = vdaFinQuittancement
            ttQtt.daDebutPeriode           = vdadaDebutPeriode
            ttQtt.daFinPeriode           = vdaFinPeriode
            ttQtt.cPeriodiciteQuittancement           = vbttQtt.cPeriodiciteQuittancement
            ttQtt.cNatureBail           = vbttQtt.cNatureBail
            ttQtt.iDureeBail           = vbttQtt.iDureeBail
            ttQtt.cUniteDureeBail           = vbttQtt.cUniteDureeBail
            ttQtt.daEffetBail           = vbttQtt.daEffetBail
            ttQtt.cCodeTypeIndiceRevision           = vbttQtt.cCodeTypeIndiceRevision
            ttQtt.cPeriodiciteIndiceRevision           = vbttQtt.cPeriodiciteIndiceRevision
            ttQtt.iPeriodeAnneeIndiceRevision           = vbttQtt.iPeriodeAnneeIndiceRevision
            ttQtt.daProchaineRevision           = vbttQtt.daProchaineRevision
            ttQtt.daTraitementRevision           = vbttQtt.daTraitementRevision
            ttQtt.cCodeModeReglement           = vbttQtt.cCodeModeReglement
            ttQtt.cCodeTerme           = vbttQtt.cCodeTerme
            ttQtt.daEntre           = vbttQtt.daEntre
            ttQtt.daSortie           = vbttQtt.daSortie
            ttQtt.iNumeroImmeuble           = vbttQtt.iNumeroImmeuble
            ttQtt.dMontantQuittance           = 0
            ttQtt.iNombreRubrique           = 0
            ttQtt.iProrata           = 1
            ttQtt.iNumerateurProrata           = viNumerateurProrata
            ttQtt.iDenominateurProrata           = viDenominateurProrata
            ttQtt.cCodeEditionDepotGarantie           = vbttQtt.cCodeEditionDepotGarantie
            ttQtt.cCodeEditionSolde           = vbttQtt.cCodeEditionSolde
            ttQtt.cCodeRevisionDeLaQuittance           = vbttQtt.cCodeRevisionDeLaQuittance
            ttQtt.CdPrv           = vbttQtt.CdPrv
            ttQtt.CdPrs           = vbttQtt.CdPrs
            ttQtt.NbEdt           = vbttQtt.NbEdt
            ttQtt.Cdmaj           = 1
            ttQtt.CdOri           = "F"
        .
        /* Parcours des listes d'infos des rubriques */
        do viI = 1 to viNombreRubriqueMax:
            vlCreationRubrique = no.
            if integer(entry(viI,vcCodeGenre,"|")) = 1 
            then do:
                /* Rubriques Fixes : Date fin appli >= date fin quit ===>
                   ATTENTION cela marche si le bail est sur 1 AN mais plus sur 1 mois car date de fin appli. < vdaFinQuittancement. Mieux vaut tester avec date vdaFinApplicationMaxi */
                if vdaFinApplicationMaxi >= vdaFinQuittancement 
                then assign  
                    vlCreationRubrique = yes
                    vdaDtFapRub        = vdaFinApplicationMaxi
                .
            end.
            else if date(entry(viI,vcFinApplication,"|")) >= vdaFinQuittancement 
            then assign  
                vlCreationRubrique = yes
                vdaDtFapRub        = date(entry(viI, vcFinApplication, "|"))
            .
            if vlCreationRubrique then do:
                /* Cette rubrique est appliquable pour cette quit */
                if entry(viI,vcCodeGenre,"|") = "00001"
                then assign
                    /* Rubrique fixe  Maj des elements du prorata */
                    entry(viI, vcProrata, "|")              = "1"
                    entry(viI, vcNumerateurProrata, "|")   = string(viNumerateurProrata)
                    entry(viI, vcDenominateurProrata, "|") = string(viDenominateurProrata)
                    entry(viI, vcLsMtqSav, "|")            = string(decimal(entry(viI, vcMontantTotal, "|")) * viNumerateurProrata / viDenominateurProrata, "->,>>>,>>>,>>9.99")
                .
                create ttRub.
                assign
                    ttRub.iNumeroLocataire = viNumeroLocataire
                    ttRub.iNoQuittance = piNumeroQuittance
                    ttRub.iFamille = integer(entry(viI, vcCodeFamille, "|"))
                    ttRub.iSousFamille = integer(entry(viI, vcCodeSousFamille, "|"))
                    ttRub.iNorubrique = integer(entry(viI, vcNumeroRubrique, "|"))
                    ttRub.iNoLibelleRubrique = integer(entry(viI, vcNumeroLibelle, "|"))
                    ttRub.cLibelleRubrique = entry(viI, vcLibelleRubrique, "|")
                    ttRub.cCodeGenre = entry(viI, vcCodeGenre, "|")
                    ttRub.cCodeSigne = entry(viI, vcCodeSigne, "|")
                    ttRub.cdDet = entry(viI, vcLsDetSav, "|")
                    ttRub.dQuantite = decimal(entry(viI, vcQuantite, "|"))
                    ttRub.dPrixunitaire = decimal(entry(viI, vcPrixUnitaire, "|"))
                    ttRub.dMontantTotal = decimal(entry(viI, vcMontantTotal, "|"))
                    ttRub.iProrata = integer(entry(viI, vcProrata, "|"))
                    ttRub.iNumerateurProrata = integer(entry(viI, vcNumerateurProrata, "|"))
                    ttRub.iDenominateurProrata = integer(entry(viI, vcDenominateurProrata, "|"))
                    ttRub.dMontantQuittance = decimal(entry(viI, vcLsMtqSav, "|"))
                    ttRub.daDebutApplication = date(entry(viI, vcDebutApplication, "|"))
                    ttRub.daFinApplication = vdaDtFapRub
                    ttRub.daDebutApplicationPrecedente = entry(viI, vcFil, "|")
                    /* Maj du montant de la quit et du nbre de rub. */
                    ttQtt.dMontantQuittance = ttQtt.dMontantQuittance + decimal(entry(viI, vcLsMtqSav, "|"))
                    ttQtt.iNombreRubrique = ttQtt.iNombreRubrique + 1
                .
            end.
        end. /* Parcours des listes d'infos des rubriques */
    end. /* Creation de la derniere quittance non complete */
    /* Parcours des quittances du locataire */
    for each ttQtt  
        where ttQtt.iNumeroLocataire = viNumeroLocataire:
        /* Module de lancement de toutes les procedures de calcul concernant la quittance */
        goCollectionQuittance:set("cNatureContrat", ttQtt.cNatureBail).
        goCollectionQuittance:set("iNumeroQuittance", ttQtt.iNoQuittance).
        goCollectionQuittance:set("daDebutPeriode", ttQtt.daDebutPeriode).
        goCollectionQuittance:set("daFinPeriode", ttQtt.daFinPeriode).
        goCollectionQuittance:set("daDebutQuittancement", ttQtt.daDebutQuittancement).
        goCollectionQuittance:set("daFinQuittancement", ttQtt.daFinQuittancement).
        goCollectionQuittance:set("iCodePeriodeQuittancement", integer(substring(ttQtt.cPeriodiciteQuittancement, 1, 3, "character"))).
        goCollectionQuittance:set("lRevision", false).
        goCollectionQuittance:set("lIndexationLoyer", false).
        ghProc = lancementPgm("bail/quittancement/crerubca.p", goCollectionHandlePgm).
        run lancementCrerubca in ghProc(poCollectionContrat, input-output goCollectionQuittance, input-output table ttQtt by-reference, input-output table ttRub by-reference).
    end.

end procedure.
