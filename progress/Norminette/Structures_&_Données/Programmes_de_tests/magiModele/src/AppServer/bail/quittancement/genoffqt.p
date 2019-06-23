/*-----------------------------------------------------------------------------
File        : genoffqt.p
Purpose     : Generation d'une quittance d'après l'Offre de Location
              A partir des tables detlc, des tarifs de loyer Eurostudiome, de la fiche relocation AGF
Author(s)   : Kantena -  2017/12/15
Notes       : reprise de genoffqt.p
derniere revue: 2018/04/26 - phm: KO
            supprimer les messages
            traiter les todo

    - glPECgloba-IN        : PEC Global oui/non (06/2007)
    - gcCodeAct-IN         : PEC/CHGRUB (30/08/2007)
    - gcTypeBail           : Type de contrat (toujours bail)
    - giNumeroBail         : Numero de bail
    - giNumeroQuittance    : Numero de quittance (toujours = 1)
    - gcCodeTerme-IN       : Code terme ("00001" = Avance ou "00002" = Echu)
    - gcCodePeriode-IN     : Code periodicite (Mensuel,Bimestriel,Trimestriel)
    - gdaEntreeLocataire-IN: Date d'entree du locataire
    - gcCodeRetour-OU      : Code retour "00"=Ok "01"=Pas d'Offre "02"=Echec)
    - Lbdivpar-IO          : Param IN/OUT divers (30/08/2007)
    - alert-mes            :
-----------------------------------------------------------------------------*/
{preprocesseur/listeRubQuit2TVA.i}
{preprocesseur/mode2reglement.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/referenceClient.i}
{preprocesseur/param2locataire.i}
{preprocesseur/profil2rubQuit.i}
{preprocesseur/codeRubrique.i}
{preprocesseur/codeTaciteReconduction.i}

block-level on error undo, throw.
using parametre.pclie.parametrageFournisseurLoyer.
using parametre.pclie.parametrageRubriqueQuittHonoCabinet.
using parametre.pclie.parametrageRubriqueExtournable.
using parametre.pclie.parametrageRelocation.
using parametre.pclie.parametrageTarifLoyer.
using parametre.syspr.syspr.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{crud/include/intnt.i}
{crud/include/cttac.i}
{bail/include/tbtmpqtt.i}
{bail/include/tbtmprub.i}
{adb/include/ttEdition.i}
{application/include/glbsepar.i}
{tache/include/tache.i}

{outils/include/lancementProgramme.i}                // fonctions lancementPgm, suppressionPgmPersistent

define variable goCollectionHandlePgm      as class collection no-undo.
define variable goCollectionContrat        as class collection no-undo.
define variable goCollectionQuittance      as class collection no-undo.
define variable goRelocation               as class parametrageRelocation               no-undo.
define variable goRubriqueQuittHonoCabinet as class parametrageRubriqueQuittHonoCabinet no-undo.
define variable goRubriqueExtournable      as class parametrageRubriqueExtournable      no-undo.
define variable goFournisseurLoyer         as class parametrageFournisseurLoyer         no-undo.
define variable goTarifLoyer               as class parametrageTarifLoyer               no-undo.
define variable goSyspr                    as class syspr                               no-undo.
define variable ghProc                     as handle    no-undo.
define variable glPECgloba-IN              as logical   no-undo.    /* PEC Global oui/non */
define variable gcCodeAct-IN               as character no-undo.    /* PEC/CHGRUB */
define variable gcTypeBail                 as character no-undo.
define variable giNumeroBail               as int64     no-undo.
define variable giNumeroQuittance          as integer   no-undo.
define variable gcCodeTerme-IN             as character no-undo.
define variable gcCodePeriode-IN           as character no-undo.
define variable gdaEntreeLocataire-IN      as date      no-undo.
define variable gdaDebut                   as date      no-undo.
define variable giNumeroMandat             as integer   no-undo.
define variable giNumeroApp                as integer   no-undo.
define variable giRubriqueFrais            as integer   no-undo initial 600.
define variable glRubriqueQuittHonoCabinet as logical   no-undo.
define variable gdaFinApplicationMaximum   as date      no-undo.
define variable gdaFinCal                  as date      no-undo.
define variable glTaciteReconduction      as logical   no-undo initial true.
define variable ghProcOutilsTache          as handle    no-undo.
define variable ghProcTache                as handle    no-undo.
define variable ghProcRelationTache        as handle    no-undo.
define variable ghProcDate                 as handle    no-undo.

function calculTotalQuittance returns decimal private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vdeTotal as decimal no-undo.
    for each ttRub:
        vdeTotal = vdeTotal + ttRub.dMontantQuittance.
    end.
    return vdeTotal.
end function.

{comm/include/prrubhol.i}    // procedures isRubEcla, isRubProCum, valDefProCum8xx

procedure lancementGenoffqtt:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   : service externe
    ------------------------------------------------------------------------*/
    define input  parameter poCollectionContrat as class collection no-undo.
    define input  parameter piNumeroQuittance     as integer   no-undo.
    define input  parameter plPECgloba-IN         as logical   no-undo.    /* PEC Global oui/non */
    define input  parameter pcCodeAct-IN          as character no-undo.    /* PEC/CHGRUB */
    define input  parameter pcCodeTerme-IN        as character no-undo.
    define input  parameter pcCodePeriode-IN      as character no-undo.
    define input  parameter pdaEntreeLocataire-IN as date      no-undo.
    define input-output parameter table for ttQtt.
    define input-output parameter table for ttRub.

    assign
        glPECgloba-IN              = plPECgloba-IN
        gcCodeAct-IN               = pcCodeAct-IN
        gcTypeBail                 = poCollectionContrat:getCharacter("cTypeContrat")
        giNumeroBail               = poCollectionContrat:getInt64("iNumeroContrat")
        giNumeroQuittance          = piNumeroQuittance
        gcCodeTerme-IN             = pcCodeTerme-IN
        gcCodePeriode-IN           = pcCodePeriode-IN
        gdaEntreeLocataire-IN      = pdaEntreeLocataire-IN
        goSyspr                    = new syspr()
        goRelocation               = new parametrageRelocation()
        goRubriqueQuittHonoCabinet = new parametrageRubriqueQuittHonoCabinet()
        goRubriqueExtournable      = new parametrageRubriqueExtournable()
        goFournisseurLoyer         = new parametrageFournisseurLoyer("00001")
        goTarifLoyer               = new parametrageTarifLoyer()
        goCollectionContrat        = poCollectionContrat
        goCollectionQuittance      = new collection()
        goCollectionHandlePgm      = new collection()
        ghProcOutilsTache          = lancementPgm("tache/outilsTache.p", goCollectionHandlePgm)
        ghProcTache                = lancementPgm("crud/tache_CRUD.p", goCollectionHandlePgm)
        ghProcRelationTache        = lancementPgm("crud/cttac_CRUD.p", goCollectionHandlePgm)
        ghProcDate                 = lancementPgm("application/l_prgdat.p", goCollectionHandlePgm)
    .

message "lancementGenoffqtt01 " glPECgloba-IN "//" gcCodeAct-IN "//" gcTypeBail "//" giNumeroBail "//" giNumeroQuittance "//" gcCodeTerme-IN "//" gcCodePeriode-IN "//"
gdaEntreeLocataire-IN "//" giNumeroMandat   .

    run genoffqttPrivate.
    delete object goSyspr no-error.
    delete object goRelocation no-error.
    delete object goRubriqueQuittHonoCabinet no-error.
    delete object goRubriqueExtournable.
    delete object goFournisseurLoyer no-error.
    delete object goTarifLoyer no-error.
    delete object goCollectionQuittance no-error.
    suppressionPgmPersistent(goCollectionHandlePgm).

end procedure.

procedure genoffqttPrivate private:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   :
    ------------------------------------------------------------------------*/
    define variable viMoisTraitementGI  as integer   no-undo.
    define variable viMoisQuittancement as integer   no-undo.
    define variable vdaDebutPeriode     as date      no-undo.
    define variable vdaFinPeriode       as date      no-undo.
    define variable viNumeroImmeuble    as int64     no-undo.
    define variable vcCodeTerme         as character no-undo.
    define variable vlLocation          as logical   no-undo.
    
    define buffer ctrat    for ctrat.
    define buffer location for location.
    define buffer lsirv    for lsirv.
    define buffer tache    for tache.

    assign
        vcCodeTerme    = (if integer(mToken:cRefPrincipale) = {&REFCLIENT-MANPOWER} then {&TERMEQUITTANCEMENT-avance} else gcCodeTerme-IN)
        gdaDebut       = gdaEntreeLocataire-IN
        giNumeroMandat = truncate(giNumeroBail / 100000, 0)
        giNumeroApp    = truncate((giNumeroBail modulo 100000) / 100, 0) // 3 premiers caractères
    .
    // Module optionnel RELOCATIONS (ALLIANZ) : initialisation avec Fiche relocation
    if goRelocation:isActif()
    then find last location no-lock
        where location.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and location.nocon = giNumeroMandat
          and location.noapp = giNumeroApp
          and location.fgarch = no no-error.
    /* Paramètre hono loc par le quit activé */
    assign
        vlLocation                 = (available location) 
        glRubriqueQuittHonoCabinet = goRubriqueQuittHonoCabinet:isActif()
    .
    /* recherche nlle rubrique frais */
    if glRubriqueQuittHonoCabinet
    then giRubriqueFrais = goRubriqueQuittHonoCabinet:nouvelleRubriqueFrais().

    /*--> Test de l'existence de l'offre */
    if not can-find(first offlc no-lock
                    where offlc.TpCon = {&TYPECONTRAT-mandat2Gerance}
                      and offlc.NoCon = giNumeroMandat
                      and offlc.NoApp = giNumeroApp)
    then mError:createErrorGestion({&information}, 104896, substitute("&2&1&3", separ[1], giNumeroMandat, string(giNumeroApp, "999"))). //offre de location inexistante pour mandat %1 et appartement %2
    find first ctrat no-lock
        where ctrat.tpcon = gcTypeBail
          and ctrat.nocon = giNumeroBail no-error.
    /*--> Calcul de la date de fin d'application maximum */
    if available ctrat
    then do:
        glTaciteReconduction = ctrat.tpren = {&TACITERECONDUCTION-YES}.
        run dtFapMax in ghProcOutilsTache(glTaciteReconduction, ctrat.dtfin, ctrat.dtree, ctrat.dtree, output gdaFinApplicationMaximum).
        run calDatPer(
            ctrat.dtfin,
            ctrat.dtree,
            vcCodeTerme,
            output gdaFinCal,
            output vdaDebutPeriode,
            output vdaFinPeriode,
            output viMoisQuittancement,
            output viMoisTraitementGI,
            input-output gdaDebut
        ).
    end.
    else do:
        run dtFapMax in ghProcOutilsTache(glTaciteReconduction, ?, ?, ?, output gdaFinApplicationMaximum).
        run calDatPer(
            ?,
            ?,
            vcCodeTerme,
            output gdaFinCal,
            output vdaDebutPeriode,
            output vdaFinPeriode,
            output viMoisQuittancement,
            output viMoisTraitementGI,
            input-output gdaDebut
        ).
    end.
    /*--> Données issus de l'immeuble */
    empty temp-table ttIntnt.
    ghProc = lancementPgm("crud/intnt_CRUD.p", goCollectionHandlePgm).
    run getLastIntntContrat in ghProc({&TYPECONTRAT-mandat2Gerance}, giNumeroMandat, {&TYPEBIEN-immeuble}, output viNumeroImmeuble).
    /*--> Données issus de la tache révision */
    find last tache no-lock
        where tache.tpcon = gcTypeBail
          and tache.nocon = giNumeroBail
          and tache.tptac = {&TYPETACHE-revision} no-error. 
    /*--> Données issus des indices de révision */
    find first lsirv no-lock
        where lsirv.cdirv = integer(if available tache then tache.tpges else "") no-error.
    /*--> Suppression de la quittance si elle existe */
    for each ttQtt
        where ttQtt.iNumeroLocataire = giNumeroBail
          and ttQtt.iNoQuittance = giNumeroQuittance:
        delete ttQtt.
    end.
    /*--> Suppression des rubriques de la quittance */
    for each ttRub
       where ttRub.iNumeroLocataire = giNumeroBail
         and ttRub.iNoQuittance = giNumeroQuittance:
        delete ttRub.
    end.
    /*--> Création de la table quittance */
    create ttQtt.
    assign
        ttQtt.iNumeroLocataire           = giNumeroBail
        ttQtt.iNoQuittance               = giNumeroQuittance
        ttQtt.iMoisTraitementQuitt       = viMoisTraitementGI
        ttQtt.iMoisReelQuittancement     = viMoisQuittancement
        ttQtt.daDebutQuittancement       = gdaDebut
        ttQtt.daFinQuittancement         = gdaFinCal
        ttQtt.daDebutPeriode             = vdaDebutPeriode
        ttQtt.daFinPeriode               = vdaFinPeriode
        ttQtt.cPeriodiciteQuittancement  = gcCodePeriode-IN
        ttQtt.cCodeModeReglement         = {&MODEREGLEMENT-cheque}
        ttQtt.cCodeTerme                 = gcCodeTerme-IN
        ttQtt.daEntre                    = gdaEntreeLocataire-IN
        ttQtt.dMontantQuittance          = 0
        ttQtt.iNombreRubrique            = 0
        ttQtt.cCodeEditionDepotGarantie  = "00000"           /* Ne pas indiquer la caution                               */
        ttQtt.cCodeEditionSolde          = "00000"           /* Ne pas indiquer le solde ant‚rieur                       */
        ttQtt.cCodeRevisionDeLaQuittance = "00000"           /* Locataire n'ayant pas subi de revision de loyer          */
        ttQtt.CdPrv                      = "00000"           /* Locataire n'ayant pas subi d'augmentation des provisions */
        ttQtt.CdPrs                      = "00000"           /* Pas d'integration du solde prestation                    */
        ttQtt.NbEdt                      = 0                 /*                                                          */
        ttQtt.CdMaj                      = 1                 /* Modification                                             */
        ttQtt.CdOri                      = "F"               /* Future quittance                                         */
        ttQtt.iNumeroImmeuble            = viNumeroImmeuble
        .
    if available ctrat
    then assign
        ttQtt.daSortie        = ctrat.dtfin
        ttQtt.cNatureBail     = ctrat.ntcon
        ttQtt.iDureeBail      = ctrat.nbdur
        ttQtt.cUniteDureeBail = ctrat.cddur
        ttQtt.daEffetBail     = ctrat.dtdeb
    .
    if available tache
    then assign
        ttQtt.iPeriodeAnneeIndiceRevision = integer(tache.ntreg + tache.cdreg)
        ttQtt.daProchaineRevision          = tache.dtfin
        ttQtt.daTraitementRevision        = tache.dtreg
        ttQtt.cCodeTypeIndiceRevision     = tache.tpges
    .
    if available lsirv
    then assign
        ttQtt.cPeriodiciteIndiceRevision = string(lsirv.cdper, "99")
    .
    /*--> Periode entiere, pas de prorata possible */
    if gdaDebut <> vdaDebutPeriode or gdaFinCal <> vdaFinPeriode
    then assign
        ttQtt.iProrata = 1
        ttQtt.iNumerateurProrata = gdaFinCal - gdaDebut + 1 /* Numerateur     */
        ttQtt.iDenominateurProrata = vdaFinPeriode - vdaDebutPeriode + 1 /* Denominateur   */
    .
/*--CHARGEMENT DE ttRub----------------------------------------------------------------------------------------------------*/
    /* Module optionnel : Tarif de loyer */
    /* TODO - voir pourquoi lot.p, ligne 527 on test référence 1501 ??? ET PAS ICI  */
    if goTarifLoyer:isActif()
    then run tarifLoyer(viNumeroImmeuble, ttQtt.cNatureBail, ttQtt.iNumerateurProrata, ttQtt.iDenominateurProrata).
    /* Si aucun tarif: Chargement Offre */
    if not can-find(first ttRub
                    where ttRub.iNumeroLocataire = giNumeroBail
                      and ttRub.iNoQuittance = giNumeroQuittance)
    then if vlLocation
         then run ficheLocation(ttQtt.iNumerateurProrata, ttQtt.iDenominateurProrata,
                                location.rub-perio, location.mtrub-loyer, location.mtrub-charges, location.mtrub-pkg).
         else run offreLoyer(giNumeroMandat, giNumeroApp, ttQtt.iNumerateurProrata, ttQtt.iDenominateurProrata).
    /*--> Module de lancement de toutes les procedures de calcul concernant la quittance */
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
    run lancementCrerubca in ghProc(goCollectionContrat, input-output goCollectionQuittance, input-output table ttQtt by-reference, input-output table ttRub by-reference).
end procedure.

procedure tarifLoyer private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroImmeuble as int64     no-undo.
    define input  parameter pcNatureBail     as character no-undo.
    define input  parameter piNumeroCal      as integer   no-undo.
    define input  parameter piDenominateur   as integer   no-undo.

    define variable viNumeroLot         as integer   no-undo.
    define variable vlMobilier          as logical   no-undo.
    define variable vcLibelleTva        as character no-undo.
    define variable vcCodeTva           as character no-undo.
    define variable vdeMontant          as decimal   no-undo.
    define variable viNumeroRubriqueTva as integer   no-undo.
    define buffer sys_pg for sys_pg.
    define buffer cpuni  for cpuni.
    define buffer unite  for unite.

    empty temp-table ttEdition.
    /*--> Chargement des tarifs de l'immeuble, phm séparation des paramètres de extTfLy1.p  */
    run adb/exttfly1.p(
        true,
        false,
        piNumeroImmeuble,
        piNumeroImmeuble,
        "",
        yes,
        ttQtt.daDebutQuittancement,
        "european",      // format exportation des données "European/american"
        output table ttEdition by-reference
    ).
    for last unite no-lock
        where unite.nomdt = giNumeroMandat
          and unite.noapp = giNumeroApp
          and unite.noact = 0
      , first cpuni no-lock
        where cpuni.nomdt = unite.nomdt
          and cpuni.noapp = unite.noapp
          and cpuni.nocmp = unite.nocmp:
        viNumeroLot = cpuni.nolot.
    end.
    if viNumeroLot > 70000
    then assign
        vlMobilier  = true
        viNumeroLot = viNumeroLot - 70000
    .
    for first ttEdition
        where trim(substring(ttEdition.Refer, 15, 1, "character")) = "1"
          and integer(entry(05, ttEdition.Ligne, separ[1])) = viNumeroLot:
        /* Loyer HT */
        if num-entries(ttEdition.Ligne, separ[1]) >= 14 then do:
            vdeMontant = decimal(entry(14, ttEdition.Ligne, separ[1])).
            if vdeMontant > 0 and not vlMobilier
            then run infRubrique(if entry(06, ttEdition.Ligne, separ[1]) = "R" then 652 else {&RUBRIQUE-loyer},
                                 01, vdeMontant, piNumeroCal, piDenominateur, yes).
        end.
        /* Charge */
        if num-entries(ttEdition.Ligne, separ[1]) >= 17 then do:
            vdeMontant = decimal(entry(17, ttEdition.Ligne, separ[1])).
            if vdeMontant > 0 and not vlMobilier
            then run infRubrique({&RUBRIQUE-provisionCharges}, 01, vdeMontant, piNumeroCal, piDenominateur, yes).
        end.
        /*--> Prestation HT */
        if num-entries(ttEdition.Ligne, separ[1]) >= 18 then do:
            vdeMontant = decimal(entry(18, ttEdition.Ligne, separ[1])).
            if vdeMontant > 0 and not vlMobilier
            then run infRubrique(651, 01, vdeMontant, piNumeroCal, piDenominateur, yes).
        end.
        /*--> Mobilier HT */
        if num-entries(ttEdition.Ligne, separ[1]) >= 25 then do:
            vdeMontant = (decimal(entry(24, ttEdition.Ligne, separ[1])) + decimal(entry(25, ttEdition.Ligne, separ[1]))).
            if vdeMontant > 0 and vlMobilier
            then run infRubrique(685, 01, vdeMontant, piNumeroCal, piDenominateur, yes).
        end.
        /*--> Parking HT */
        if num-entries(ttEdition.Ligne, separ[1]) >= 27 then do:
            vdeMontant = decimal(entry(27, ttEdition.Ligne, separ[1])).
            if vdeMontant > 0 and not vlMobilier
            then run infRubrique(140, 07, vdeMontant, piNumeroCal, piDenominateur, yes).
        end.
        /*--> Frais de correspondance */
        if num-entries(ttEdition.Ligne, separ[1]) >= 33 then do:
            vdeMontant = decimal(entry(33, ttEdition.Ligne, separ[1])).
            if giRubriqueFrais <> 0 and vdeMontant > 0
            then run infRubrique(giRubriqueFrais, 01, vdeMontant, piNumeroCal, piDenominateur, no).
        end.
        /*--> Frais Dossier */
        if num-entries(ttEdition.Ligne, separ[1]) >= 34 then do:
            vdeMontant = decimal(entry(34, ttEdition.Ligne, separ[1])).
            if vdeMontant > 0 then run infRubrique(623, 01, vdeMontant, piNumeroCal, piDenominateur, no).
        end.
        if gcCodeAct-IN = "PEC" then do:
            /*--> TVA Parking si est seulement s'il y a de la TVA sur le loyer */
            run suppressionTache(gcTypeBail, giNumeroBail, {&TYPETACHE-TVABail}).
            if entry(41, ttEdition.Ligne, separ[1]) <> "00000" and not vlMobilier
            then for first sys_pg no-lock                        /*--> Si tache TVA possible sur la nature du bail */
                where sys_pg.tppar = "R_CTA"
                  and sys_pg.zone1 = pcNatureBail
                  and sys_pg.zone2 = {&TYPETACHE-TVABail}:
                /*--> Creation de la tache si manquante */
                empty temp-table ttTache.
                create ttTache.
                assign
                    ttTache.CRUD  = "C"
                    ttTache.tpcon = gcTypeBail
                    ttTache.nocon = giNumeroBail
                    ttTache.tptac = {&TYPETACHE-TVABail}
                    ttTache.notac = 1
                    ttTache.dtdeb = gdaDebut
                    ttTache.ntGes = entry(41, ttEdition.Ligne, separ[1])
                    ttTache.PdGes = "00001"
                    ttTache.Lbdiv = "749#01"           /* TVA 20 % */
                    ttTache.dtTimestamp = now
                .
                run setTache in ghProcTache(table ttTache by-reference).
                if mError:erreur() then return.
            end.
            /* TVA Loyer */
            if entry(38, ttEdition.Ligne, separ[1]) <> "00000" and entry(06, ttEdition.Ligne, separ[1]) <> "R" and not vlMobilier
            then for first sys_pg no-lock     /* Si tache TVA possible sur la nature du bail */
                 where sys_pg.tppar = "R_CTA"
                   and sys_pg.zone1 = pcNatureBail
                   and sys_pg.zone2 = {&TYPETACHE-TVABail}:
                /*--> Creation de la tache si manquante */
                empty temp-table ttTache.
                create ttTache.
                assign
                    ttTache.CRUD  = "C"
                    ttTache.tpcon = gcTypeBail
                    ttTache.nocon = giNumeroBail
                    ttTache.tptac = {&TYPETACHE-TVABail}
                    ttTache.notac = 1
                    ttTache.dtdeb = gdaDebut
                    ttTache.ntGes = entry(38, ttEdition.Ligne, separ[1])
                    ttTache.pdGes = "00001"
                    ttTache.lbdiv = "778#01"
                    ttTache.dtTimestamp = now
                .
                run setTache in ghProcTache(input-output table ttTache by-reference).
                if mError:erreur() then return.
            end.

            /*--> TVA sur service annexe */
            /* suppession d'une éventuelle Tache gcTypeBail, giNumeroBail, TYPETACHE-TVAServicesAnnexes */
            run suppressionTache(gcTypeBail, giNumeroBail, {&TYPETACHE-TVAServicesAnnexes}).
            if ((entry(38, ttEdition.Ligne, separ[1]) <> "00000" and entry(06, ttEdition.Ligne, separ[1]) = "R")
              or entry(39, ttEdition.Ligne,separ[1]) <> "00000"
              or entry(40, ttEdition.Ligne,separ[1]) <> "00000") and not vlMobilier
            then  for first sys_pg no-lock    /*--> Si tache TVA possible sur la nature du bail */
                 where sys_pg.tppar = "R_CTA"
                   and sys_pg.zone1 = pcNatureBail
                   and sys_pg.zone2 = {&TYPETACHE-TVAServicesAnnexes}:
                /* Creation de la tache si manquante */
                /* calcul de tache.lbdiv */

                /*- Services Hoteliers -*/
                vcCodeTva = if num-entries(ttEdition.Ligne, separ[1]) >= 39
                            then entry(39, ttEdition.Ligne, separ[1]) else {&codeTVA-20.00}.
                if vcCodeTva = "00000" then vcCodeTva = {&codeTVA-20.00}.
                run donneRubTvadutaux(vcCodeTva, {&TYPETACHE-TVAServicesAnnexes}, output viNumeroRubriqueTva).
                assign
                    vcLibelleTva = substitute("&1#1#04#03#&2@", viNumeroRubriqueTva, vcCodeTva)
                    /*- Service Divers */
                    vcCodeTva    = if num-entries(ttEdition.Ligne, separ[1]) >= 40
                                   then entry(40, ttEdition.Ligne, separ[1]) else {&codeTVA-20.00}
                .
                if vcCodeTva = "00000" then vcCodeTva = {&codeTVA-20.00}.
                run donneRubTvadutaux(vcCodeTva, {&TYPETACHE-TVAServicesAnnexes}, output viNumeroRubriqueTva).
                assign
                    vcLibelleTva = substitute("&1&2#1#04#05#&3@", vcLibelleTva, viNumeroRubriqueTva, vcCodeTva)
                    /*- Redevance soumise à TVA */
                    vcCodeTva    = if num-entries(ttEdition.Ligne, separ[1]) >= 38
                                   then entry(38, ttEdition.Ligne, separ[1]) else {&codeTVA-10.00}
                .
                if vcCodeTva = "00000" then vcCodeTva = {&codeTVA-10.00}.
                run donneRubTvadutaux(vcCodeTva, {&TYPETACHE-TVAServicesAnnexes}, output viNumeroRubriqueTva).
                assign
                    vcLibelleTva = substitute("&1&2#1#04#06#&3", vcLibelleTva, viNumeroRubriqueTva, vcCodeTva)
                    /* sous famille 8: Abonnement         :TVA  5.5% */
                    vcCodeTva    = {&codeTVA-5.50}
                .
                run donneRubTvadutaux(vcCodeTva, {&TYPETACHE-TVAServicesAnnexes}, output viNumeroRubriqueTva).
                vcLibelleTva = substitute("&1&2#1#04#08#&3", vcLibelleTva, viNumeroRubriqueTva, vcCodeTva).

                empty temp-table ttTache.
                create ttTache.
                assign
                    ttTache.CRUD  = "C"
                    ttTache.tpcon = gcTypeBail
                    ttTache.nocon = giNumeroBail
                    ttTache.tptac = {&TYPETACHE-TVAServicesAnnexes}
                    ttTache.notac = 1
                    ttTache.Lbdiv = vcLibelleTva
                    ttTache.dtTimestamp = now
                .
                run setTache in ghProcTache(table ttTache by-reference).
                if mError:erreur() then return.
            end.
        end.    /* PEC */
    end.
    /*--> Total quittance */
    ttQtt.dMontantQuittance = calculTotalQuittance().
end procedure.

procedure offreLoyer private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroMandat as integer no-undo.
    define input  parameter piNumeroApp    as integer no-undo.
    define input  parameter piNumeroCal    as integer no-undo.
    define input  parameter piDenominateur as integer no-undo.
    define buffer detlc for detlc.

    define variable viNumeroRubrique as integer no-undo.

    /*--> Parcours des rubriques de detlc */
boucle:
    for each detlc no-lock
        where detlc.tpCon = {&TYPECONTRAT-mandat2Gerance}
          and detlc.noCon = piNumeroMandat
          and detlc.noApp = piNumeroApp:
        /* Ajout Sy le 19/03/2010 : Si Honoraires locataires par le quittancement LF à FX */
        /*alors Anciennes rubriques EXTOURNABLES interdites */
        if glRubriqueQuittHonoCabinet
        and goRubriqueExtournable:isRubriqueExtournable(detlc.norub) then next boucle.

        if detlc.norub = 0          /* Modification SY le 19/03/2010: rub par défaut pour Loyer et charges uniquement */
        then case detlc.cdfam:
            when 1 then assign viNumeroRubrique = {&RUBRIQUE-loyer}.
            when 2 then assign viNumeroRubrique = {&RUBRIQUE-provisionCharges}.
            /*WHEN 4 THEN ASSIGN viNumeroRubrique = 600.*/
            otherwise next boucle.
        end case.
        else viNumeroRubrique = detlc.norub.
        run infRubrique(viNumeroRubrique, detlc.noLib, detlc.mtRub, piNumeroCal, piDenominateur, yes).
    end.
    /*--> Total quittance */
    ttQtt.dMontantQuittance = calculTotalQuittance().
end procedure.

procedure ficheLocation private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroCal       as integer   no-undo.
    define input  parameter piDenominateur    as integer   no-undo.
    define input  parameter pcRubPerio        as character no-undo.
    define input  parameter pdeMontantLoyer   as decimal   no-undo.
    define input  parameter pdeMontantCharges as decimal   no-undo.
    define input  parameter pdeMontantParking as decimal   no-undo.

    define variable vcRubriqueTemp     as character no-undo.
    define variable viCompteur         as integer   no-undo.
    define variable viRubriqueTemp     as integer   no-undo.
    define variable viLibelleTemp      as integer   no-undo.
    define variable vdeMontantRubrique as decimal   no-undo.
    define variable vdeCoefficient     as decimal   no-undo.
    define variable vcLocationZone10   as character no-undo.

    assign
        vcLocationZone10 = if num-entries(goRelocation:zon10, "@") < 3
                           then "101.01@200.01@140.01@@" else goRelocation:zon10      /* valeurs par défaut GI */
        vdeCoefficient   = integer(substring(gcCodePeriode-IN, 1, 3, "character")) / integer(pcRubPerio)
    .
    do viCompteur = 1 to 3:
        vcRubriqueTemp = entry(viCompteur, vcLocationZone10, "@").
        case viCompteur:
            when 1 then assign
                viRubriqueTemp = {&RUBRIQUE-loyer}
                viLibelleTemp  = {&LIBELLE-RUBRIQUE-loyer}
            .
            when 2 then assign
                viRubriqueTemp = {&RUBRIQUE-provisionCharges}
                viLibelleTemp  = {&LIBELLE-RUBRIQUE-provisionCharges}
            .
            when 3 then assign
                viRubriqueTemp = {&RUBRIQUE-loyerDependance}
                viLibelleTemp  = {&LIBELLE-RUBRIQUE-loyerDependanceParking}
            .
        end case.
        if num-entries(vcRubriqueTemp, ".") = 2
        then assign
            viRubriqueTemp = integer(entry(1, vcRubriqueTemp, "."))
            viLibelleTemp  = integer(entry(2, vcRubriqueTemp, "."))
        .
        /* Montant de la rubrique */
        case viCompteur:
            when 1 then vdeMontantRubrique = pdeMontantLoyer.
            when 2 then vdeMontantRubrique = pdeMontantCharges.
            when 3 then vdeMontantRubrique = pdeMontantParking.
        end case.
        if viRubriqueTemp * viLibelleTemp <> 0 and vdeMontantRubrique <> 0
        then run infRubrique(viRubriqueTemp, viLibelleTemp, vdeMontantRubrique * vdeCoefficient, piNumeroCal, piDenominateur, no).

    end.
    ttQtt.dMontantQuittance = calculTotalQuittance().
end procedure.

procedure infRubrique private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroRubrique    as integer  no-undo.
    define input parameter piNumeroLibelle     as integer  no-undo.
    define input parameter pdeMontant          as decimal  no-undo.
    define input parameter piNumeroCal         as integer  no-undo.
    define input parameter piDenominateur      as integer  no-undo.
    define input parameter plCoeff             as logical  no-undo.

    define buffer rubqt for rubqt.

    create ttRub.
    assign
        ttRub.iNumeroLocataire             = giNumeroBail
        ttRub.iNoQuittance                 = giNumeroQuittance    
        ttRub.iNorubrique                  = piNumeroRubrique
        ttRub.iNoLibelleRubrique           = piNumeroLibelle
        ttRub.CdDet                        = "0"
        ttRub.dQuantite                    = 0
        ttRub.dPrixunitaire                = 0     
        ttRub.daDebutApplication           = gdaDebut
        ttRub.daDebutApplicationPrecedente = ""          
        ttQtt.iNombreRubrique    = ttQtt.iNombreRubrique + 1 
    .
    for first rubqt no-lock
        where rubqt.cdrub = piNumeroRubrique
          and rubqt.cdlib = piNumeroLibelle: 
        assign
            ttRub.cLibelleRubrique = outilTraduction:getLibelle(rubqt.nome1)
            ttRub.iFamille         = rubqt.cdfam
            ttRub.iSousFamille     = rubqt.cdsfa
            ttRub.cCodeGenre       = rubqt.cdgen
            ttRub.cCodeSigne       = rubqt.cdsig
        .
    end.
    /*--> Les rubriques de type "Administratif" ont un montant global pour toute la periode => ne pas la multiplier */
    if plCoeff and ttRub.iFamille <> {&FamilleRubqt-Administratif}
    then pdeMontant = pdeMontant * integer(substring(gcCodePeriode-IN, 1, 3, "character")).
    assign
        ttRub.dMontantTotal = pdeMontant
        /*--> Calcul de la date de fin d'application RUB */
        /*--> Rubriques Fixes: Date fin appli 'loin dans le futur' ou dtfin */
        /*--> Rubriques Variables: Date fin appli = date fin de quittancement */
        ttRub.daFinApplication = if integer(ttRub.cCodeGenre) = 1 then gdaFinApplicationMaximum else gdaFinCal
    .
    run prorataRubrique(buffer ttRub, piNumeroCal, piDenominateur).

end procedure.

procedure prorataRubrique private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttRub for ttRub.
    define input  parameter piNumeroCal    as integer no-undo.
    define input  parameter piDenominateur as integer no-undo.

    define variable vlProrataRubrique as logical no-undo.
    define variable vlCumulRubrique   as logical no-undo.

    if ttQtt.iProrata = 1 then do:
        run isRubProCum(ttRub.iNorubrique, ttRub.iNoLibelleRubrique, output vlProrataRubrique, output vlCumulRubrique).
        if not vlProrataRubrique
        then ttRub.dMontantQuittance = ttRub.dMontantTotal.
        else assign
            ttRub.iProrata = 1
            ttRub.iNumerateurProrata = piNumeroCal
            ttRub.iDenominateurProrata = piDenominateur
            ttRub.dMontantQuittance = ttRub.dMontantTotal * piNumeroCal / piDenominateur
        .
    end.
    else ttRub.dMontantQuittance = ttRub.dMontantTotal.
end procedure.

procedure calDatPer private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure qui calcul les dates de la periode et de la quittance
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pdaFinBai           as date      no-undo.
    define input  parameter pdaResbai           as date      no-undo.
    define input  parameter pcCodeTerme         as character no-undo.
    define output parameter pdaFinCal           as date      no-undo.
    define output parameter pdaDebutperiode     as date      no-undo.
    define output parameter pdaFinperiode       as date      no-undo.
    define output parameter piMoisQuittancement as integer   no-undo.
    define output parameter piMoisTraitementGI  as integer   no-undo.
    define input-output parameter pdaDebUse     as date      no-undo.

    define variable viNoMoiRef             as integer no-undo.
    define variable viNoAnnDeb             as integer no-undo.
    define variable viNoAnnFin             as integer no-undo.
    define variable viNoMoiApp             as integer no-undo.
    define variable viNoMoiDpr             as integer no-undo.
    define variable viNoMoiFpr             as integer no-undo.
    define variable viNbMoiAdd             as integer no-undo.
    define variable viMs1stQtt             as integer no-undo.
    define variable viNbMoiPer             as integer no-undo.
    define variable vlFournisseurLoyer     as logical no-undo.
    define variable vlBailFournisseurLoyer as logical no-undo.
    define variable viMsQttTmp             as integer no-undo.
    define variable viNoAnnQtt             as integer no-undo.

    /* Determination des mois de debut et fin de periode */
    assign
        viNbMoiPer             = integer(substring(gcCodePeriode-IN, 1, 3, "character"))
        viNoMoiApp             = month(pdaDebUse)
        viNoAnnDeb             = year(pdaDebUse)
        viNoAnnFin             = viNoAnnDeb
        viNoMoiRef             = integer(substring(gcCodePeriode-IN, 4))
        vlFournisseurLoyer     = goFournisseurLoyer:isGesFournisseurLoyer()
        vlBailFournisseurLoyer = goCollectionContrat:getLogical("lBailFournisseurLoyer")
    .
    if viNoMoiRef <= viNoMoiApp
    then do:        
        /* Le mois de reference est <= au mois d'appli. */
        assign
            viNoMoiDpr = viNoMoiRef
            viNoMoiFpr = viNoMoiDpr + viNbMoiPer
        .
        do while viNoMoiApp >= viNoMoiFpr:
            assign
                viNoMoiDpr = viNoMoiDpr + viNbMoiPer
                viNoMoiFpr = viNoMoiFpr + viNbMoiPer
            .
        end.
        viNoMoiFpr = viNoMoiFpr - 1.
        if viNoMoiFpr > 12
        then assign
            viNoMoiFpr = viNoMoiFpr - 12
            viNoAnnFin = viNoAnnFin + 1
        .
    end.
    else do: /* Le mois de reference est > au mois d'appli. */
        viNoMoiDpr = viNoMoiRef.
        do while viNoMoiDpr > viNoMoiApp:
            viNoMoiDpr = viNoMoiDpr - viNbMoiPer.
        end.
        if viNoMoiDpr < 1
        then assign
            viNoMoiDpr = viNoMoiDpr + 12
            viNoAnnDeb = viNoAnnDeb - 1
        .
        viNoMoiFpr = viNoMoiDpr + viNbMoiPer - 1.
        if viNoMoiFpr > 12 then do:
            viNoMoiFpr = viNoMoiFpr - 12.
            if viNoAnnFin = viNoAnnDeb then viNoAnnFin = viNoAnnFin + 1.
        end.
    end.
    /*--> Date du premier jour de la periode */
    assign
        pdaDebutperiode = date(viNoMoiDpr, 01, viNoAnnDeb)
        pdaFinperiode   = date(viNoMoiFpr, 28, viNoAnnFin) + 4
        pdaFinperiode   = pdaFinperiode - day(pdaFinperiode)
    .
    /*--> Calcul mois quittancement et mois traitement GI */
    run calInfPer in ghProcDate(pdaDebutperiode, viNbMoiPer, pcCodeTerme, output pdaFinperiode, output piMoisQuittancement, output piMoisTraitementGI).
    /*--> HORS PEC GLOBAL : Boucle de recherche de la 1ere periode "Quittansable" (=> avec MsQtt >= GlMoiMdf) */
    if not glPECgloba-IN then do:
        assign
            viNbMoiAdd = 0
            viMsQttTmp = piMoisTraitementGI
            viMs1stQtt = if vlFournisseurLoyer and vlBailFournisseurLoyer
                         then goCollectionContrat:getInteger("iMoisModifiable")
                         else if pcCodeTerme ={&TERMEQUITTANCEMENT-echu}
                              then goCollectionContrat:getInteger("iMoisEchu")
                              else goCollectionContrat:getInteger("iMoisModifiable")
        .
        if vlFournisseurLoyer and vlBailFournisseurLoyer then viMs1stQtt = goCollectionContrat:getInteger("iMoisModifiable").
        do while viMsQttTmp < viMs1stQtt and viNoMoiDpr <> 0:
            assign
                viNoMoiDpr = integer(substring(string(viMsQttTmp), 5, 2, "character")) + viNbMoiPer
                viNoAnnQtt = integer(substring(string(viMsQttTmp), 1, 4, "character"))
                viNbMoiAdd = viNbMoiAdd + viNbMoiPer
            .
            if viNoMoiDpr > 12
            then assign
                viNoMoiDpr = viNoMoiDpr - 12
                viNoAnnQtt = viNoAnnQtt + 1
            .
            viMsQttTmp = integer(string(viNoAnnQtt, "9999") + string(viNoMoiDpr,"99")).
        end.
        if viNbMoiAdd > 0 then do:
            /*--> Calculer la Nouvelle date debut periode */
            pdaDebutperiode = add-interval(pdaDebutperiode, viNbMoiAdd, "months").
            /*--> Calcul date de fin de periode - Calcul mois quitt et mois traitement GI */
            run calInfPer in ghProcDate(pdaDebutperiode, viNbMoiPer, pcCodeTerme, output pdaFinperiode, output piMoisQuittancement, output piMoisTraitementGI).
            /*--> Date d'application des rubriques */
            pdaDebUse = pdaDebutperiode.
        end.
    end.
    pdaFinCal = pdaFinperiode.
    if pdaResbai <> ? and pdaResbai >= pdaDebutperiode and pdaResbai < pdaFinperiode          /* Modif SY le 24/01/2013 - protection regeneration par prmobqtt.p */
    then pdaFinCal = pdaResbai - 1.
    else if pdaFinBai <> ? and pdaFinBai >= pdaDebutperiode and pdaFinBai < pdaFinperiode and not glTaciteReconduction
         then pdaFinCal = pdaFinBai - 1.
end procedure.

procedure suppressionTache private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as integer   no-undo.
    define input parameter pcTypeTache     as character no-undo.

    empty temp-table ttTache.
    run getTache in ghProcTache(pcTypeContrat, piNumeroContrat, pcTypeTache, table ttTache by-reference).
    for each ttTache: ttTache.CRUD = "D". end.
    run setTache in ghProcTache(table ttTache by-reference).

    run readCttac in ghProcRelationTache(pcTypeContrat, piNumeroContrat, pcTypeTache, output table ttCttac by-reference).
    for first ttCttac:
        ttCttac.CRUD = "D".
        run setCttac in ghProcRelationTache(table ttCttac by-reference).
    end.
    mError:resetErrors().  // ne pas oublier de supprimer les erreurs non voulues.
end procedure.

procedure donneRubTvadutaux private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcCodeTva     as character no-undo.
    define input  parameter pcTypeTache   as character no-undo.
    define output parameter piRubriqueTva as integer   no-undo.

    define variable vcTauxTva as character no-undo.
    define buffer bxrbp  for bxrbp.
    define buffer rubqt  for rubqt.

    /* Taux de tva */
    goSyspr:reload("CDTVA", pcCodeTva).
    if goSyspr:isDbParameter then vcTauxTva = string(goSyspr:zone1 * 100).

    /* Recherche de la rubrique tva associée au taux */
boucle:
    for each bxrbp no-lock
        where bxrbp.ntbai = {&NATURECONTRAT-usageCommercial1953}
          and bxrbp.cdfam = {&FamilleRubqt-Taxe}
          and bxrbp.cdsfa = {&SousFamilleRubqt-ImpotsTaxesFiscaux}
          and bxrbp.prg05 = pcTypeTache
          and bxrbp.nolib = 0
      , first rubqt no-lock
        where rubqt.cdfam = bxrbp.cdfam
          and rubqt.cdrub = bxrbp.norub
          and rubqt.cdlib = 0
          and rubqt.prg04 = vcTauxTva:
        piRubriqueTva = rubqt.cdrub.
        leave boucle.
    end.

end procedure.
