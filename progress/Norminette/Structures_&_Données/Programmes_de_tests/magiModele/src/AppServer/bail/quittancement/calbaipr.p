/*-----------------------------------------------------------------------------
File        : calbaipr.p
Purpose     : Module de calcul de la rubrique de quittancement 101 des Fournisseurs
              de loyer associées à la tache 'Bail proportionnel' (04369) du mandat de location.
Author(s)   : PL - 2012/06/05, Kantena - 2017/12/21
Notes       : reprise de adb/src/quit/calbaipr.p
derniere revue: 2018/04/26 - phm: KO
              traiter les todo

01 26/07/2012  PL    Demande FR le 29/07/2012: procédé interdit retrait annulation de 100% des charges
02 22/08/2012  SY    Ajout infos noqtt, msqtt dans Mlog
03 05/11/2013  SY    réduction nombre Mlog
04 04/09/2014  SY    0914/0007: Pb doublon TOM car la suppression préliminaire ne fonctionnait pas
05 17/12/2014  SY    1214/0150 Gros problème Eclatement encaissement effectués sur TOUS les mandats de gérance alors qu'il ne faudrait
                     QUE les mandat de sous-location si bail proportionnel dans l'immeuble
06 22/12/2014  SY    Etat pré-quitt: ne pas relancer l'Eclatement encaissement si rien en compta
07 22/12/2014  SY    Ajout info mandat location résilié pour affiner WARNING ou ERREUR
*--------------------------------------------------------------------------*/
{preprocesseur/referenceClient.i}
{preprocesseur/type2tache.i}
{preprocesseur/codeRubrique.i}
using parametre.pclie.parametrageFournisseurLoyer.
using parametre.pclie.parametrageBailProportionnel.
{oerealm/include/instanciateTokenOnModel.i}  // Doit être positionnée juste après using

{bail/include/tbtmpqtt.i}
{bail/include/tbtmprub.i}

{outils/include/lancementProgramme.i}        // fonctions lancementPgm, suppressionPgmPersistent

define variable goCollectionHandlePgm as class collection no-undo.
define variable goCollectionContrat   as class collection no-undo.
define variable goCollectionQuittance as class collection no-undo.
define variable ghProc as handle no-undo.

define temp-table ttResultat no-undo    /* {tblbpr.i}  Table ttResultat pour extraction des encaissements */
    field noMdt as integer
    field noUl  as integer
    field mtHTom as decimal extent 12
    field mtTom  as decimal extent 12
    field mtChg  as decimal extent 12
    field mtTva  as decimal extent 12
.
{bail/include/isgesflo.i}    //  fonctions: donneBailSousLoc, donneBailSousLocDeleguee, donneMandatLoc, donneMandatSousLoc, chargementListeFamilles. procédures: donneLoyerQuittance

define variable gcTypeBail            as character no-undo.
define variable giNumeroBail          as int64     no-undo.
define variable giNumeroQuittance     as integer   no-undo.
define variable gdaDebutPeriode       as date      no-undo.
define variable gdaFinPeriode         as date      no-undo.
define variable gdaDebutQuittancement as date      no-undo.
define variable gdaFinQuittancement   as date      no-undo.

procedure lancementCalbaipr:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   : service externe
    ------------------------------------------------------------------------*/
    define input parameter poCollectionContrat   as class collection no-undo.
    define input parameter poCollectionQuittance as class collection no-undo.
    define input-output parameter table for ttQtt.
    define input-output parameter table for ttRub.

    assign   
        gcTypeBail            = poCollectionContrat:getCharacter("cTypeContrat")
        giNumeroBail          = poCollectionContrat:getInt64("iNumeroContrat")
        giNumeroQuittance     = poCollectionQuittance:getInteger("iNumeroQuittance")
        gdaDebutPeriode       = poCollectionQuittance:getDate("daDebutPeriode")
        gdaFinPeriode         = poCollectionQuittance:getDate("daFinPeriode")
        gdaDebutQuittancement = poCollectionQuittance:getDate("daDebutQuittancement")
        gdaFinQuittancement   = poCollectionQuittance:getDate("daFinQuittancement")
        goCollectionContrat   = poCollectionContrat
        goCollectionQuittance = poCollectionQuittance
        goCollectionHandlePgm = new collection()
    .        

message "lancementCalbaipr  " .
//gga todo ATTENTION ce pgm est a tester dans un environnement BNP (2053). pour avancer et debugger le plus gros creation d'un mandat 135 de ce type mais ne suffit pas  
    run calbaiprPrivate.
    suppressionPgmPersistent(goCollectionHandlePgm).

end procedure.

procedure calbaiprPrivate private:
    /*---------------------------------------------------------------------------
    Purpose :
    Notes   :
    ---------------------------------------------------------------------------*/
    define variable viNumeroMandat          as integer   no-undo.
    define variable vdeMontantRubrique      as decimal   no-undo.
    define variable viNumeroRubrique        as integer   no-undo.
    define variable viNumeroLibelleRubrique as integer   no-undo.
    define variable viNumeroQuittance       as integer   no-undo.
    define variable vdeMontantLoyer         as decimal   no-undo.
    define variable vdeMontantCharges       as decimal   no-undo.
    define variable vdeMontantTva           as decimal   no-undo.
    define variable vdeMontantTom           as decimal   no-undo.
    define variable vdePourcentageRevision  as decimal   no-undo.
    define variable vcCodeRubriqueLoyer     as character no-undo.
    define variable viLibelleLoyer          as integer   no-undo.
    define variable viMoisQuittance         as integer   no-undo.
    define variable viMoisModifiable        as integer   no-undo.
    define variable viMoisEchu              as integer   no-undo.
    define variable voBailProportionnel     as class parametrageBailProportionnel no-undo.

    define buffer equit for equit.
    define buffer tache for tache.

    /* Recherche si tache Bail proportionnel F.L */
    viNumeroMandat = integer(truncate(giNumeroBail / 100000, 0)). // integer(substring( string(giNumeroBail, "9999999999"), 1 , 5))
    find first tache no-lock
        where tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and tache.nocon = viNumeroMandat
          and tache.tptac = {&TYPETACHE-bailProportionnel} no-error.
    if not available tache then return.

    /* Au passage, récupération des infos de la tache */
    if tache.tpfin = "00000" then do:
        voBailProportionnel = new parametrageBailProportionnel().
        if not voBailProportionnel:isDbParameter then do:
            merror:createError({&error}, 1000854).   // Le paramètrage du Bail proportionnel au niveau du cabinet n'est pas renseigné. Vous devez d'abord le renseigner
            return.
        end.
        assign
            vdePourcentageRevision = voBailProportionnel:getPourcentageRevision()
            vcCodeRubriqueLoyer    = voBailProportionnel:getCodeRubriqueLoyer()
            viLibelleLoyer         = voBailProportionnel:getNumeroRubriqueLoyer()
        .
    end.
    else assign            /* Sinon on prend le paramétrage spécifique */
        vdePourcentageRevision = decimal(tache.mtreg)
        vcCodeRubriqueLoyer    = entry(1, tache.lbdiv, "#")
        viLibelleLoyer         = integer(entry(2, tache.lbdiv, "#")) when num-entries(tache.lbdiv, "#") >= 2
    .
    assign    
        viMoisModifiable = goCollectionContrat:getInteger("iMoisModifiable")
        viMoisEchu       = goCollectionContrat:getInteger("iMoisEchu")
        viMoisQuittance  = goCollectionContrat:getInteger("iMoisQuittancement")
    .
    /* Recherche si TOUTES les quittances chargées */
    /* Parcours des quittances en cours du locataire */
boucleEquit:
    for each equit no-lock
        where equit.noLoc = giNumeroBail
          and ((equit.cdter = "00001" and equit.msqtt >= viMoisEchu)
            or (equit.cdter = "00002" and equit.msqtt >= viMoisModifiable))
        by equit.msqtt by equit.nomdt:
        /* Recherche de la 1ère quittance >= Mois Quitt */
        if viNumeroQuittance = 0 and equit.noqtt > 0 and equit.msQtt >= viMoisQuittance then do:
            viNumeroQuittance = equit.noqtt.
            leave boucleEquit.
        end.
    end.
    /* Recherche mois quitt de la quittance traitée */
    find first ttQtt
        where ttQtt.iNumeroLocataire = giNumeroBail
          and ttQtt.iNoQuittance = giNumeroQuittance no-error.
    if not available ttQtt then do:
        mError:createError({&error}, 1000852, string(giNumeroQuittance)).   //problème génération quittance &1, erreur sur table quittance
        return.
    end.
    /* Calcul du loyer en fonction des encaissements */
    if ttQtt.iNoQuittance = viNumeroQuittance    /* Pour l'AE en cours */
    then run calculeLoyerEncaisse(giNumeroBail, output vdeMontantLoyer, output vdeMontantTom, output vdeMontantCharges, output vdeMontantTva).
    for each ttRub    /* Il ne doit y avoir qu'une seule rubrique générée */
        where ttRub.iNumeroLocataire = giNumeroBail
          and ttRub.iNoQuittance = giNumeroQuittance
          and ttRub.iNorubrique = integer(vcCodeRubriqueLoyer):
        delete ttRub.
    end.
    for each ttRub    /* IDem pour la TOM */
        where ttRub.iNumeroLocataire = giNumeroBail
          and ttRub.iNoQuittance = giNumeroQuittance
          and ttRub.iNorubrique = {&RUBRIQUE-taxeOrduresMenageres}:
        delete ttRub.
    end.
    for each ttRub    /* IDem pour Les charges */
        where ttRub.iNumeroLocataire = giNumeroBail
          and ttRub.iNoQuittance = giNumeroQuittance
          and ttRub.iNorubrique = {&RUBRIQUE-provisionCharges}:
        delete ttRub.
    end.
    /* Rubrique de loyer */
    if vdeMontantLoyer <> 0 then do:
        assign
            viNumeroRubrique        = integer(vcCodeRubriqueLoyer)
            viNumeroLibelleRubrique = viLibelleLoyer
            vdeMontantRubrique      = round((vdeMontantLoyer * vdePourcentageRevision) / 100, 2) /* Pas de prorata de présence*/
        .
        run trtRubEnc(vdeMontantRubrique, viNumeroRubrique, viNumeroLibelleRubrique).
        if mError:erreur() then return.

        run creDetail(viNumeroRubrique, vdeMontantLoyer).
    end.
    
    /* Rubrique de Taxe ordures ménagères */
    if vdeMontantTom <> 0 then do:
        assign
            viNumeroRubrique        = {&RUBRIQUE-taxeOrduresMenageres}
            viNumeroLibelleRubrique = {&LIBELLE-RUBRIQUE-taxeOrduresMenageres}
            vdeMontantRubrique      = vdeMontantTom /* Pas de pourcentage de recupération, Pas de prorata de présence */
        .
        run trtRubEnc(vdeMontantRubrique, viNumeroRubrique, viNumeroLibelleRubrique).
    end.
    
    /* Rubrique de Charges 91.85% */
    if vdeMontantCharges <> 0 then do:
        assign
            viNumeroRubrique        = {&RUBRIQUE-provisionCharges}
            viNumeroLibelleRubrique = {&LIBELLE-RUBRIQUE-provisionCharges}
            vdeMontantRubrique      = round((vdeMontantCharges * vdePourcentageRevision) / 100, 2) /* Pas de prorata de présence*/
        .
        run trtRubEnc(vdeMontantRubrique, viNumeroRubrique, viNumeroLibelleRubrique).
        run creDetail(viNumeroRubrique, vdeMontantCharges).
    end.
end procedure.

procedure trtRubEnc private:
    /*---------------------------------------------------------------------------
    Purpose : Procedure qui met à jour ou crée la rubrique
    Notes   : (TOUTES LES QUITTANCES DOIVENT ETRE CHARGEES)
    ---------------------------------------------------------------------------*/
    define input  parameter pdeMontantRubrique      as decimal no-undo.
    define input  parameter piNumeroRubrique        as integer no-undo.
    define input  parameter piNumeroLibelleRubrique as integer no-undo.

    define variable vdaDebutRubrique   as date      no-undo.
    define variable vdaFinRubrique     as date      no-undo.
    define variable vdaDebutQuittance  as date      no-undo.
    define variable vdaFinQuittance    as date      no-undo.

    define buffer rubqt   for rubqt.
    define buffer vbttRub for ttRub.

    /* Calcul dates d'application */
    assign
        vdaDebutRubrique = ttQtt.daDebutPeriode
        vdaFinRubrique   = gdaFinQuittancement
    .
    /* Positionnement sur la Rubrique  101-xx */
    find first rubqt no-lock
        where rubqt.cdrub = piNumeroRubrique
          and rubqt.cdlib = piNumeroLibelleRubrique no-error.
    if not available rubQt then do:
        mError:createError({&error}, 104126, string(piNumeroRubrique)).
        return.
    end.

    find first ttRub
        where ttRub.iNumeroLocataire = giNumeroBail
          and ttRub.iNoQuittance = giNumeroQuittance
          and ttRub.iNorubrique = piNumeroRubrique
          and ttRub.iNoLibelleRubrique = piNumeroLibelleRubrique no-error.
    if not available ttRub then do:
        create ttRub.
        assign
            vdaDebutQuittance = vdaDebutRubrique
            vdaFinQuittance   = ttQtt.daFinPeriode  /* date de fin quittance corrigée */
            ttRub.iNumeroLocataire = giNumeroBail
            ttRub.iNoQuittance = giNumeroQuittance
            ttRub.iNorubrique = piNumeroRubrique
            ttRub.iNoLibelleRubrique = piNumeroLibelleRubrique
            ttRub.cLibelleRubrique = outilTraduction:getLibelle(rubqt.nome1)
            ttRub.iFamille = rubqt.cdfam
            ttRub.iSousFamille = rubqt.cdsfa
            ttRub.cCodeGenre = rubqt.CdGen
            ttRub.cCodeSigne = rubqt.CdSig
            ttRub.cdDet = "0"
            ttRub.dQuantite = 0
            ttRub.dPrixunitaire = 0
            ttRub.dMontantTotal = pdeMontantRubrique
            ttRub.iProrata = ttQtt.iProrata   /* cdpro */
            ttRub.iNumerateurProrata = ttQtt.iNumerateurProrata   /* nbnum */
            ttRub.iDenominateurProrata = ttQtt.iDenominateurProrata   /* nbden */
            ttRub.dMontantQuittance = pdeMontantRubrique
            ttRub.daDebutApplication = vdaDebutRubrique
            ttRub.daFinApplication = vdaFinRubrique
            ttRub.iNoOrdreRubrique = 0
        .
        run majttQtt(pdeMontantRubrique, 1).    /* Modification du montant de la quittance et nb rub dans ttQtt */
    end.
    else do:
        assign
            vdaDebutQuittance = ttRub.daDebutApplication
            vdaFinQuittance   = ttRub.daFinApplication
            /* Modification rubrique Loyer */
            ttRub.dMontantTotal       = pdeMontantRubrique
            ttRub.dMontantQuittance       = pdeMontantRubrique
            ttRub.daFinApplication       = vdaFinRubrique
        .
        run majttQtt(pdeMontantRubrique - ttRub.dMontantTotal, 0).     /* Modification du montant de la quittance et nb rub dans ttQtt */
    end.

    /* Verification existence de la rubrique avec un autre libellé dans les quittances futures et forçage avec libellé piNumeroLibelleRubrique */
    for each vbttRub
        where vbttRub.iNumeroLocataire = giNumeroBail
          and vbttRub.iNoQuittance > giNumeroQuittance
          and vbttRub.iNorubrique = piNumeroRubrique
          and vbttRub.iNoLibelleRubrique <> piNumeroLibelleRubrique:
        /* Forcage dates d'application et libelle */
        assign
            vbttRub.iNoLibelleRubrique = piNumeroLibelleRubrique
            vbttRub.daDebutApplication = ttRub.daDebutApplication
            vbttRub.daFinApplication = ttRub.daFinApplication
        .
    end.
    /* Lancement du module de répercussion sur les quittances futures */
    ghProc = lancementPgm("bail/quittancement/majlocrb.p", goCollectionHandlePgm).
    run trtMajlocrb in ghProc(
        giNumeroBail,
        giNumeroQuittance,
        piNumeroRubrique,
        piNumeroLibelleRubrique,
        vdaDebutQuittance,
        vdaFinQuittance,
        "",
        input-output table ttQtt,
        input-output table ttRub
    ).
end procedure.

procedure majttQtt private:
    /*---------------------------------------------------------------------------
    Purpose : Procedure qui met à jour le montant quittance pour la rubrique dans ttQtt
    Notes   :
    ---------------------------------------------------------------------------*/
    define input parameter pdeMontantRubrique as decimal no-undo.
    define input parameter piNumeroRubrique   as integer no-undo.

    for first ttQtt
        where ttQtt.iNumeroLocataire = giNumeroBail
          and ttQtt.iNoQuittance = giNumeroQuittance:
        assign
            ttQtt.dMontantQuittance = ttQtt.dMontantQuittance + pdeMontantRubrique
            ttQtt.iNombreRubrique = ttQtt.iNombreRubrique + piNumeroRubrique
            ttQtt.CdMaj = 1
        .
    end.

end procedure.

procedure calculeLoyerEncaisse private:
    /*---------------------------------------------------------------------------
    Purpose : Lancement de la procédure de calcul du loyer FL pour le mandat type bail proportionnel = fonction des encaissements des sous-locataires
    Notes   :
    ---------------------------------------------------------------------------*/
    define input  parameter piNumeroBailLoyer as integer no-undo.
    define output parameter pdeMontantLoyer   as decimal no-undo.
    define output parameter pdeMontantTOM     as decimal no-undo.
    define output parameter pdeMontantCharges as decimal no-undo.
    define output parameter pdeMontantTVA     as decimal no-undo.

    define variable vcListeRubriquesLoyer   as character no-undo.
    define variable vcListeRubriquesCharges as character no-undo.
    define variable vcListeRubriquesTOM     as character no-undo.
    define variable vcListeRubriquesTVA     as character no-undo.
    define variable viMandatLocation        as integer   no-undo.
    define variable viULMandatLocation      as integer   no-undo.
    define variable viBailSousLocation      as int64     no-undo.
    define variable viMandatSousLocation    as integer   no-undo.
    define variable viULSousLocation        as integer   no-undo.
    define variable viBoucle                as integer   no-undo.
    define variable vlTrtMasse              as logical   no-undo.
    define variable viMandatATraiter        as integer   no-undo.
    define variable viULATraiter            as integer   no-undo.
    define variable vlExtractionFL          as logical   no-undo.

    define buffer unite      for unite.
    define buffer cpuni      for cpuni.
    define buffer ctrat      for ctrat.
    define buffer vbCtratLoc for ctrat.
    define buffer intnt      for intnt.
    define buffer vbIntntLoc for intnt.
    define buffer tache      for tache.

    /* Récupération du mandat de location */
    assign
        viMandatLocation   = truncate(piNumeroBailLoyer / 100000, 0)              // integer(substring(string(piNumeroBailLoyer,"9999999999"),1,5))
        viULMandatLocation = truncate((piNumeroBailLoyer modulo 100000) / 100, 0) // integer(substring(string(piNumeroBailLoyer,"9999999999"),6,3))
    .
    for first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and ctrat.nocon = viMandatLocation
          and ctrat.dtree <> ?:
         mLogger:writeLog(9, substitute("WARNING CalculeLoyerEncaisse - mandat de location n° &1 résilié au &2", viMandatLocation, ctrat.dtree)).
    end.
    /* Balayage de toutes les unités actives du mandat de location ... */
    find first unite no-lock
        where unite.nomdt = viMandatLocation
          and unite.noapp = viULMandatLocation
          and unite.noact = 0 no-error.
    if not available unite then return.
    /* ... puis le lot de l'unite (NB: dans ce modèle : 1 bail = 1 UL = 1 lot ... */
    find first cpuni no-lock
        where cpuni.nomdt = unite.nomdt
          and cpuni.noapp = unite.noapp
          and cpuni.nocmp = unite.nocmp no-error.
    if not available cpuni then return.
    /* ... Recherche d'une composition d'un mandat de sous/location contenant ce lot */
    viBailSousLocation = donneBailSousLoc(cpuni.noimm, cpuni.nolot).
    if viBailSousLocation = 0 then return.
    /* A ce niveau on a le bail du mandat de sous-location correspondant à ce lot */
    /* Il faut obtenir les encaissements du locataire */
    assign
        /* Récupération des identifiants */
        viMandatSousLocation = truncate(viBailSousLocation / 100000, 0)              // integer(substring(string(viBailSousLocation,"9999999999"),1,5))
        viULSousLocation     = truncate((viBailSousLocation modulo 100000) / 100, 0) // integer(substring(string(viBailSousLocation,"9999999999"),6,3))
        /* Appel de la boite noire d'extraction des encaissements */
        viMandatATraiter     = 0  /* Par defaut, on traite tous les mandats */
        /* Traitement en masse ou quittance unique */
        /* Normalement, quand on arrive ici depuis le quittancement, l'éclatement a déjà été lancé
           et l'extraction aussi sinon cela plante, donc on ne peut pas lancer un pont compta depuis un pont gestion depuis les transferts */
        vlExtractionFL = lookup(goCollectionQuittance:getCharacter("PREQUITTANCEMENT_FL"), "OUI,ECLAT_FAIT") > 0
        vlTrtMasse     = goCollectionQuittance:getCharacter("QUITTANCEMENT_FL")    = "OUI"
    .
    if not vlTrtMasse then do:
        empty temp-table ttResultat.
        viMandatATraiter = viMandatSousLocation.
    end.
    viULATraiter = viULSousLocation.

    /* Si pas d'enregistrement dans la table, il faut lancer l'éclatement ET l'extraction */
    find first ttResultat no-error.
    if not available ttResultat then do:
        /* Ne pas lancer le pont si quittancement FL car plante */
        /* Ajout SY le 22/12/2014: ne pas lancer l'éclatement des encaissement si déjà fait mais aucune écritures comptables */
        if not vlTrtMasse
        and goCollectionQuittance:getCharacter("PREQUITTANCEMENT_FL") <> "ECLAT_FAIT" then do:
            /* SY 1214/0150 : Optimisation */
            for each ctrat no-lock
                where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and ctrat.fgfloy = no
                  and ctrat.dtree = ?
                  and ctrat.ntcon = {&NATURECONTRAT-mandatSousLocation}
              , first intnt no-lock
                where intnt.tpcon = ctrat.tpcon
                  and intnt.nocon = ctrat.nocon
                  and intnt.tpidt = {&TYPEBIEN-immeuble}
              , each vbIntntLoc no-lock
                where vbIntntLoc.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and vbIntntLoc.tpidt = intnt.tpidt
                  and vbIntntLoc.noidt = intnt.noidt
              , first vbCtratLoc no-lock
                where vbCtratLoc.tpcon = vbIntntLoc.tpcon
                  and vbCtratLoc.nocon = vbIntntLoc.nocon
                  and (vbCtratLoc.ntcon = {&NATURECONTRAT-mandatLocation}
                    or vbCtratLoc.ntcon = {&NATURECONTRAT-mandatLocationIndivision})
              , last tache no-lock
                where tache.tpcon = vbCtratLoc.tpcon
                  and tache.nocon = vbCtratLoc.nocon
                  and tache.tptac = {&TYPETACHE-bailProportionnel}
                break by ctrat.nocon by vbCtratLoc.nocon:
                if first-of(ctrat.nocon) then do:
                    viMandatATraiter = ctrat.nocon.
                    /* 1 - Lancement de l'éclatement des encaissements */
                    mLogger:writeLog(9, substitute(
                        "Lancement de l'éclatement des encaissements:&1gdaDebutQuittancement = &2&1gdaFinQuittancement = &3&1viMandatATraiter = &4&1",
                        chr(10),
                        string(gdaDebutQuittancement, "99/99/9999"),
                        string(gdaFinQuittancement, "99/99/9999"),
                        viMandatATraiter)
                    ).
                    goCollectionQuittance:set("cCodeTraitement", "ECLAT").    /* Code Traitement: ECLAT-EXTRACT-VALID */
                    goCollectionQuittance:set("daDebutQuittance", gdaDebutQuittancement).
                    goCollectionQuittance:set("daFinQuittance",   gdaFinQuittancement).
                    goCollectionQuittance:set("iMandatATraiter",  viMandatATraiter).
                    goCollectionQuittance:set("iNumeroUnite",     0).
                    goCollectionQuittance:set("cListeHonoraireTOM", "").
                    goCollectionQuittance:set("cListeTOM",          "").
                    goCollectionQuittance:set("cListeCharges",      "").
                    goCollectionQuittance:set("cListeTVA",          "").
                    goCollectionQuittance:set("iCodeSoc", integer(mToken:cRefGerance)).
                    ghProc = lancementPgm("compta/extrbbpr.p", goCollectionHandlePgm). 
                    run lancementExtrbbpr in ghProc(goCollectionQuittance).
                    if mError:erreur() then return.
                end.
            end.
            if vlExtractionFL then goCollectionQuittance:set("PREQUITTANCEMENT_FL", "ECLAT_FAIT").  /* Ajout SY le 22/12/2014 */
        end.
    end.

    find first ttResultat
        where ttResultat.nomdt = viMandatSousLocation no-error.
    if not available ttResultat then do:
        /* Ne pas lancer le pont si quittancement FL car plante */
        if goCollectionQuittance:getCharacter("QUITTANCEMENT_FL") <> "OUI" then do:
            /* Si on est sur le prequitt, on lance pour toutes les UL du mandat, sinon juste sur l'UL qui nous concerne */
            assign
                viULATraiter = (if vlTrtMasse then 0 else viULSousLocation)
                /* Chargement de la liste des rubriques à prendre en compte pour le calcul */
                ghProc       = lancementPgm("crud/rubqt_CRUD.p", goCollectionHandlePgm)
            . 
            run getRubriqueEncaissement in ghProc(output vcListeRubriquesLoyer,
                                                  output vcListeRubriquesCharges,
                                                  output vcListeRubriquesTOM,
                                                  output vcListeRubriquesTVA).
            goCollectionQuittance:set("cCodeTraitement",  "EXTRACT").    /* Code Traitement: ECLAT-EXTRACT-VALID */
            goCollectionQuittance:set("daDebutQuittance", gdaDebutQuittancement).
            goCollectionQuittance:set("daFinQuittance",   gdaFinQuittancement).
            goCollectionQuittance:set("iMandatATraiter",  viMandatATraiter).
            goCollectionQuittance:set("iNumeroUnite",     viULATraiter).
            goCollectionQuittance:set("cListeHonoraireTOM", vcListeRubriquesLoyer).
            goCollectionQuittance:set("cListeTOM",          vcListeRubriquesTOM).
            goCollectionQuittance:set("cListeCharges",      vcListeRubriquesCharges).
            goCollectionQuittance:set("cListeTVA",          vcListeRubriquesTVA).
            goCollectionQuittance:set("iCodeSoc", integer(mToken:cRefGerance)).
            ghProc = lancementPgm("compta/extrbbpr.p", goCollectionHandlePgm). 
            run lancementExtrbbpr in ghProc(goCollectionQuittance).
            if mError:erreur() then return.
        end.
    end.

    /* Positionnement sur le bon enregistrement */
    find first ttResultat
        where ttResultat.nomdt = viMandatSousLocation
          and ttResultat.noul = viULSousLocation no-error.
    if not available ttResultat then do:
        mLogger:writeLog(9, substitute(
            "** WARNING ** Recherche/Cumul des encaissements: aucun enregistrement correspondant dans ttResultat&1 viMandatSousLocation = &2&1 viULSousLocation = &3",
            chr(10),
            viMandatSousLocation,
            viULSousLocation)).
        return.
    end.
    /* Cumul sur les 12 mois */
    do viBoucle = 1 to 12:
        assign
            pdeMontantLoyer   = pdeMontantLoyer   + ttResultat.mthtom[viBoucle]
            pdeMontantTOM     = pdeMontantTOM     + ttResultat.mttom[viBoucle]
            pdeMontantCharges = pdeMontantCharges + ttResultat.mtchg[viBoucle]
            pdeMontantTVA     = pdeMontantTVA     + ttResultat.mttva[viBoucle]
        .
    end.
    mLogger:writeLog(9, substitute(
        "Cumul des encaissements:&1 viMandatSousLocation = &2 viULSousLocation = &3&1 pdeMontantLoyer = &4&1 pdeMontantTOM = &5&1 pdeMontantCharges = &6&1pdeMontantTVA = &7",
        chr(10),
        viMandatSousLocation,
        viULSousLocation,
        pdeMontantLoyer,
        pdeMontantTOM,
        pdeMontantCharges,
        pdeMontantTVA
    )).

end procedure.

procedure creDetail private:
    /*---------------------------------------------------------------------------
    Purpose :
    Notes   :
    ---------------------------------------------------------------------------*/
    define input parameter piRubrique as integer no-undo.
    define input parameter pdeMontant as decimal no-undo.

    define variable viBoucle          as integer no-undo.
    define variable viRubriqueTrouvee as integer no-undo.

    mLogger:writeLog(9, substitute(
        "Credetail - Création du détail des encaissements:&1 giNumeroBail = &2&1 giNumeroQuittance = &3&1 piRubrique = &4&1 pdeMontant = &5",
        giNumeroBail,
        giNumeroQuittance,
        piRubrique,
        pdeMontant
        )).
    find first ttQtt
        where ttQtt.iNumeroLocataire = giNumeroBail
          and ttQtt.iNoQuittance = giNumeroQuittance no-error.
    if not available ttQtt then return.

    /* Recherche de la position de la rubrique si elle existe */
boucle:
    do viBoucle = 1 to 20:
        if (ttQtt.tbrubenc[viBoucle] = 0 or ttQtt.tbrubenc[viBoucle] = ?) and viRubriqueTrouvee = 0 then do:
            viRubriqueTrouvee = viBoucle.
            leave boucle.
        end.
        if ttQtt.tbrubenc[viBoucle] = piRubrique then do:
            viRubriqueTrouvee = viBoucle.
            leave boucle.
        end.
    end.
    if viRubriqueTrouvee > 0 then assign
        ttQtt.tbrubenc[viRubriqueTrouvee] = piRubrique
        ttQtt.tbmntenc[viRubriqueTrouvee] = pdeMontant
    .
end procedure.
