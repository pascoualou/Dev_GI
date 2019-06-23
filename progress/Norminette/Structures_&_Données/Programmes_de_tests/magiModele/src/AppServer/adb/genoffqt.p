/*-----------------------------------------------------------------------------
File        : genoffqt.p
Purpose     : Generation d'une quittance d'après l'Offre de Location
              A partir des tables detlc, des tarifs de loyer Eurostudiome, de la fiche relocation AGF
Author(s)   : Kantena -  2017/12/15
Notes       : reprise de genoffqt.p
derniere revue: 2018/04/26 - phm: KO
            traiter les todo
            personne n'utilise ce programme !!!!!

    - plPECgloba-IN        : PEC Global oui/non (06/2007)
    - pcCodeAct-IN         : PEC/CHGRUB (30/08/2007)
    - pcTypeBail           : Type de contrat (toujours bail)
    - piNumeroBail         : Numero de bail
    - piNumeroQuittance    : Numero de quittance (toujours = 1)
    - pcCodeTerme-IN       : Code terme ("00001" = Avance ou "00002" = Echu)
    - pcCodePeriode-IN     : Code periodicite (Mensuel,Bimestriel,Trimestriel)
    - pdaEntreeLocataire-IN: Date d'entree du locataire
    - pcCodeRetour-OU      : Code retour "00"=Ok "01"=Pas d'Offre "02"=Echec)
    - Lbdivpar-IO          : Param IN/OUT divers (30/08/2007)
    - alert-mes            :
-----------------------------------------------------------------------------*/
{preprocesseur/listeRubQuit2TVA.i}
{preprocesseur/mode2reglement.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}

block-level on error undo, throw.
using parametre.pclie.parametrageFournisseurLoyer.
using parametre.pclie.parametrageRubriqueQuittHonoCabinet.
using parametre.pclie.parametrageRelocation.
using parametre.pclie.parametrageTarifLoyer.
using parametre.syspr.syspr.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{mandat/include/mandat.i}
{adblib/include/intnt.i}
{adblib/include/cttac.i}
{bail/include/equit.i &nomtable=ttqtt}
{bail/include/tmprub.i}
{adb/include/ttEdition.i}
{application/include/glbsepar.i}
{tache/include/tache.i}

define input  parameter plPECgloba-IN         as logical   no-undo.    /* PEC Global oui/non */
define input  parameter pcCodeAct-IN          as character no-undo.    /* PEC/CHGRUB */        /* Ajout SY le 30/08/2007 */
define input  parameter pcTypeBail            as character no-undo.
define input  parameter piNumeroBail          as int64     no-undo.
define input  parameter piNumeroQuittance     as integer   no-undo.
define input  parameter pcCodeTerme-IN        as character no-undo.
define input  parameter pcCodePeriode-IN      as character no-undo.
define input  parameter pdaEntreeLocataire-IN as date      no-undo.
define input  parameter poCollection          as class collection no-undo.
define output parameter pcCodeRetour-OU       as character no-undo initial "00".
define output parameter pcMessageRetour       as character no-undo.
define input-output parameter table for TTQtt.
define input-output parameter table for TTRub.

define variable gdaDebut                   as date      no-undo.
define variable giNumeroMandat             as integer   no-undo.
define variable giNumeroApp                as integer   no-undo.
define variable giRubriqueFrais            as integer   no-undo initial 600.
define variable glRubriqueQuittHonoCabinet as logical   no-undo.
define variable gdaFinApplicationMaximum   as date      no-undo.
define variable gdaFinCal                  as date      no-undo.
define variable glTacheRenouvellement      as logical   no-undo initial true.
define variable ghProcOutilsTache          as handle    no-undo.
define variable ghProcTache                as handle    no-undo.
define variable ghProcRelationTache        as handle    no-undo.
define variable ghProcDate                 as handle    no-undo.
define variable ghProcRubqt                as handle    no-undo.
define variable goRelocation               as class parametrageRelocation        no-undo.
define variable goRubriqueQuittHonoCabinet as class parametrageRubriqueQuittHonoCabinet no-undo.
define variable goFournisseurLoyer         as class parametrageFournisseurLoyer  no-undo.
define variable goTarifLoyer               as class parametrageTarifLoyer        no-undo.
define variable goSyspr                    as class syspr                        no-undo.

assign
    goSyspr                    = new syspr()
    goRelocation               = new parametrageRelocation()
    goRubriqueQuittHonoCabinet = new parametrageRubriqueQuittHonoCabinet()
    goFournisseurLoyer         = new parametrageFournisseurLoyer("00001")
    goTarifLoyer               = new parametrageTarifLoyer().
.
run tache/outilsTache.p    persistent set ghProcOutilsTache.
run getTokenInstance       in ghProcOutilsTache(mToken:JSessionId).
run tache/tache.p          persistent set ghProcTache.
run getTokenInstance       in ghProcTache(mToken:JSessionId).
run adblib/cttac_crud.p    persistent set ghProcRelationTache.
run getTokenInstance       in ghProcRelationTache(mToken:JSessionId).
run application/l_prgdat.p persistent set ghProcDate.
run getTokenInstance       in ghProcDate(mToken:JSessionId).
run bail/quittancement/rubqt_crud.p persistent set ghProcRubqt.
run getTokenInstance       in ghProcRubqt(mToken:JSessionId).

run genoffqttPrivate.

delete object goSyspr no-error.
delete object goRelocation no-error.
delete object goRubriqueQuittHonoCabinet no-error.
delete object goFournisseurLoyer no-error.
delete object goTarifLoyer no-error.
run destroy in ghProcOutilsTache.
run destroy in ghProcTache.
run destroy in ghProcRelationTache.
run destroy in ghProcDate.
run destroy in ghProcRubqt.

function calculTotalQuittance returns decimal private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vdeTotal as decimal no-undo.
    for each ttRub:
        vdeTotal = vdeTotal + ttRub.VlMtq.
    end.
    return vdeTotal.
end function.

/* pour l'include comm/include/prrubhol.i */
&global-define proratisation-avant-fiche "650,651,652,655,657,659,685,695"
{comm/include/prrubhol.i}    // procedures isRubEcla, isRubProCum, valDefProCum8xx

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
    define variable vhProcContrat       as handle    no-undo.
    define variable vhProcIntervenant   as handle    no-undo.
    define buffer location for location.
    define buffer lsirv for lsirv.

    assign
        vcCodeTerme    = (if integer(mToken:cRefPrincipale) = 10 then "00001" else pcCodeTerme-IN)    // todo  vérifier  NoRefUse emplacé par mToken:cRefPrincipale
        gdaDebut       = pdaEntreeLocataire-IN
        giNumeroMandat = truncate(piNumeroBail / 100000, 0)
        giNumeroApp    = truncate((piNumeroBail modulo 100000) / 100, 0) // 3 premiers caractères
    .
    /* Ajout Sy le 18/02/2009: AGF RELOCATIONS : initialisation avec Fiche relocation */
    if goRelocation:isActif()
    then find last location no-lock        /* Recherche fiche de relocation */
        where location.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and location.nocon = giNumeroMandat
          and location.noapp = giNumeroApp
          and location.fgarch = no no-error.       /* struct > V9.97 */
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
    then pcMessageRetour = substitute("&1|&2", giNumeroMandat, string(giNumeroApp, "999")).
    empty temp-table ttMandat.
    run adblib/ctrat_CRUD.p   persistent set vhProcContrat.
    run getTokenInstance       in vhProcContrat(mToken:JSessionId).
    run readCtrat in vhProcContrat(pcTypeBail, piNumeroBail, table ttMandat by-reference).
    run destroy   in vhProcContrat.
    find first ttMandat no-error.
    /*--> Calcul de la date de fin d'application maximum */
    if available ttMandat
    then do:
        glTacheRenouvellement = ttMandat.cCodeTypeRenouvellement = "00001".
        run dtFapMax in ghProcOutilsTache(glTacheRenouvellement, ttMandat.daDateFin, ttMandat.daResiliation, ttMandat.daResiliation, output gdaFinApplicationMaximum).
        run calDatPer(
            ttMandat.daDateFin,
            ttMandat.daResiliation,
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
        run dtFapMax in ghProcOutilsTache(glTacheRenouvellement, ?, ?, ?, output gdaFinApplicationMaximum).
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
    run adblib/intnt_CRUD.p persistent set vhProcIntervenant.
    run getTokenInstance in vhProcIntervenant(mToken:JSessionId).
    run getLastIntntContrat in vhProcIntervenant({&TYPECONTRAT-mandat2Gerance}, giNumeroMandat, {&TYPEBIEN-immeuble}, output viNumeroImmeuble).
    run destroy in vhProcIntervenant.
    /*--> Données issus de la tache révision */
    empty temp-table ttTache.
    run getTache in ghProcTache(pcTypeBail, piNumeroBail, {&TYPETACHE-revision}, table ttTache by-reference).
    find first ttTache no-error.
    /*--> Données issus des indices de révision */
    find first lsirv no-lock
        where lsirv.cdirv = integer(if available ttTache then ttTache.tpges else "") no-error.

    /*--> Suppression de la quittance si elle existe */
    for each ttQtt
        where ttQtt.NoLoc = piNumeroBail
          and ttQtt.NoQtt = piNumeroQuittance:
        delete ttQtt.
    end.
    /*--> Suppression des rubriques de la quittance */
    for each ttRub
       where ttRub.NoLoc = piNumeroBail
         and ttRub.NoQtt = piNumeroQuittance:
        delete ttRub.
    end.
    /*--> Création de la table quittance */
    create ttQtt.
    assign
        ttQtt.NoLoc = piNumeroBail
        ttQtt.NoQtt = piNumeroQuittance
        ttQtt.MsQtt = viMoisTraitementGI
        ttQtt.MsQui = viMoisQuittancement
        ttQtt.DtDeb = gdaDebut
        ttQtt.DtFin = gdaFinCal
        ttQtt.DtDpr = vdaDebutPeriode
        ttQtt.DtFpr = vdaFinPeriode
        ttQtt.PdQtt = pcCodePeriode-IN
        ttQtt.MdReg = {&MODEREGLEMENT-cheque}
        ttQtt.CdTer = pcCodeTerme-IN
        ttQtt.DtEnt = pdaEntreeLocataire-IN
        ttQtt.MtQtt = 0
        ttQtt.NbRub = 0
        ttQtt.CdDep = "00000"           /* Ne pas indiquer la caution                               */
        ttQtt.CdSol = "00000"           /* Ne pas indiquer le solde ant‚rieur                       */
        ttQtt.CdRev = "00000"           /* Locataire n'ayant pas subi de revision de loyer          */
        ttQtt.CdPrv = "00000"           /* Locataire n'ayant pas subi d'augmentation des provisions */
        ttQtt.CdPrs = "00000"           /* Pas d'integration du solde prestation                    */
        ttQtt.NbEdt = 0                 /*                                                          */
        ttQtt.CdMaj = 1                 /* Modification                                             */
        ttQtt.CdOri = "F"               /* Future quittance                                         */
        ttQtt.NoImm = viNumeroImmeuble          /*                                                          */
    .
    if available ttMandat
    then assign
        ttQtt.DtSor = ttMandat.daDateFin
        ttQtt.NtBai = ttMandat.cCodeNatureContrat
        ttQtt.DuBai = ttMandat.iDuree
        ttQtt.UtDur = ttMandat.cUniteDuree
        ttQtt.DtEff = ttMandat.daDateDebut
    .
    if available ttTache
    then assign
        ttQtt.NoIdc = integer(ttTache.ntreg + ttTache.cdreg)
        ttQtt.DtRev = ttTache.dtfin
        ttQtt.DtPrv = ttTache.dtreg
        ttQtt.TpIdc = ttTache.tpges
    .
    if available lsirv
    then assign
        ttQtt.pdIdc = string(lsirv.cdper, "99")
    .
    /*--> Periode entiere, pas de prorata possible */
    if gdaDebut <> vdaDebutPeriode or gdaFinCal <> vdaFinPeriode
    then assign
        ttQtt.cdQuo = 1
        ttQtt.nbNum = gdaFinCal - gdaDebut + 1 /* Numerateur     */
        ttQtt.nbDen = vdaFinPeriode - vdaDebutPeriode + 1 /* Denominateur   */
    .

/*--CHARGEMENT DE ttRub----------------------------------------------------------------------------------------------------*/
    /* Module optionnel : Tarif de loyer */
    /* TODO - voir pourquoi lot.p, ligne 527 on test référence 1501 ??? ET PAS ICI  */
    if goTarifLoyer:isActif()
    then run tarifLoyer(viNumeroImmeuble, ttMandat.cCodeNatureContrat, ttQtt.NbNum, ttQtt.NbDen).
    /* Si aucun tarif: Chargement Offre */
    if not can-find(first ttRub
                    where ttRub.NoLoc = piNumeroBail
                      and ttRub.NoQtt = piNumeroQuittance)
    then if vlLocation
         then run ficheLocation(ttQtt.NbNum, ttQtt.NbDen,
                                location.rub-perio, location.mtrub-loyer, location.mtrub-charges, location.mtrub-pkg).
         else run offreLoyer(giNumeroMandat, giNumeroApp, ttQtt.NbNum, ttQtt.NbDen).

    /*--> Module de lancement de toutes les procedures de calcul concernant la quittance */
    run bail/quittancement/crerubca_ext.p(
        pcTypeBail,
        piNumeroBail,
        ttQtt.NtBai,
        ttQtt.NoQtt,
        ttQtt.DtDpr,
        ttQtt.DtFpr,
        ttQtt.DtDeb,
        ttQtt.DtFin,
        integer(substring(ttQtt.PdQtt, 1, 3, "character")),
        false,    /* FgARevis = "01" todo - global var   */
        false,    /* FgAIndex = "01" todo - global var   */
        poCollection,
        input-output table ttQtt by-reference,
        input-output table ttRub by-reference,
        output pcCodeRetour-OU
    ).
    if pcCodeRetour-OU <> "00" then pcCodeRetour-OU = "02".
end procedure.

procedure tarifLoyer private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroImmeuble    as int64     no-undo.
    define input  parameter pcNatureBail        as character no-undo.
    define input  parameter piNumeroCal         as integer   no-undo.
    define input  parameter piDenominateur      as integer   no-undo.
    define input  parameter piNombreMoisPeriode as integer   no-undo.

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
        yes,
        ttQtt.DtDeb,
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
          and integer(entry(05, ttEdition.Ligne, SEPAR[1])) = viNumeroLot:
        /* Loyer HT */
        if num-entries(ttEdition.Ligne, SEPAR[1]) >= 14
        then do:
            vdeMontant = decimal(entry(14, ttEdition.Ligne, SEPAR[1])) * piNombreMoisPeriode.
            if vdeMontant > 0 and not vlMobilier then do:
                if entry(06, ttEdition.Ligne, SEPAR[1]) = "R"
                then run infRubrique(652, 01, vdeMontant, piNumeroCal, piDenominateur).
                else run infRubrique(101, 01, vdeMontant, piNumeroCal, piDenominateur).
            end.
        end.
        /* Charge */
        if num-entries(ttEdition.Ligne, SEPAR[1]) >= 17
        then do:
            vdeMontant = decimal(entry(17, ttEdition.Ligne, SEPAR[1])) * piNombreMoisPeriode.
            if vdeMontant > 0 and not vlMobilier
            then run infRubrique(200, 01, vdeMontant, piNumeroCal, piDenominateur).
        end.
        /*--> Prestation HT */
        if num-entries(ttEdition.Ligne, SEPAR[1]) >= 18
        then do:
            vdeMontant = decimal(entry(18, ttEdition.Ligne, SEPAR[1])) * piNombreMoisPeriode.
            if vdeMontant > 0 and not vlMobilier
            then run infRubrique(651, 01, vdeMontant, piNumeroCal, piDenominateur).
        end.
        /*--> Mobilier HT */
        if num-entries(ttEdition.Ligne, SEPAR[1]) >= 25
        then do:
            vdeMontant = (decimal(entry(24, ttEdition.Ligne, SEPAR[1])) + decimal(entry(25, ttEdition.Ligne, SEPAR[1]))) * piNombreMoisPeriode.
            if vdeMontant > 0 and vlMobilier
            then run infRubrique(685, 01, vdeMontant, piNumeroCal, piDenominateur).
        end.
        /*--> Parking HT */
        if num-entries(ttEdition.Ligne, SEPAR[1]) >= 27
        then do:
            vdeMontant = decimal(entry(27, ttEdition.Ligne, SEPAR[1])) * piNombreMoisPeriode.
            if vdeMontant > 0 and not vlMobilier
            then run infRubrique(140, 07, vdeMontant, piNumeroCal, piDenominateur).
        end.
        /*--> Frais de correspondance */
        if num-entries(ttEdition.Ligne, SEPAR[1]) >= 33
        then do:
            vdeMontant = decimal(entry(33, ttEdition.Ligne, SEPAR[1])).
            if giRubriqueFrais <> 0 and vdeMontant > 0
            then run infRubrique(giRubriqueFrais, 01, vdeMontant, piNumeroCal, piDenominateur).
        end.
        /*--> Frais Dossier */
        if num-entries(ttEdition.Ligne, SEPAR[1]) >= 34
        then do:
            vdeMontant = decimal(entry(34, ttEdition.Ligne, SEPAR[1])).
            if vdeMontant > 0 then run infRubrique(623, 01, vdeMontant, piNumeroCal, piDenominateur).
        end.
        if pcCodeAct-IN = "PEC" then do:
            /*--> TVA Parking si est seulement s'il y a de la TVA sur le loyer */
            run suppressionTache(pcTypeBail, piNumeroBail, {&TYPETACHE-TVABail}).
            if entry(41, ttEdition.Ligne, SEPAR[1]) <> "00000" and not vlMobilier then do:
                /*--> Si tache TVA possible sur la nature du bail */
                find first sys_pg no-lock
                     where sys_pg.tppar = "R_CTA"
                       and sys_pg.zone1 = pcNatureBail
                       and sys_pg.zone2 = {&TYPETACHE-TVABail} no-error.
                if available sys_pg then do:
                    /*--> Creation de la tache si manquante */
                    empty temp-table ttTache.
                    create ttTache.
                    assign
                        ttTache.CRUD  = "C"
                        ttTache.tpcon = pcTypeBail
                        ttTache.nocon = piNumeroBail
                        ttTache.tptac = {&TYPETACHE-TVABail}
                        ttTache.notac = 1
                        ttTache.dtdeb = gdaDebut
                        ttTache.ntGes = entry(41, ttEdition.Ligne, SEPAR[1])
                        ttTache.PdGes = "00001"
                        ttTache.Lbdiv = "749#01"           /* TVA 20 % */  /* SY 1013/0167 */
                        ttTache.dtTimestamp = now
                    .
                    run setTache in ghProcTache(table ttTache by-reference).
                    if mError:erreur() then return.
                end.
            end.
            /* TVA Loyer */
            if entry(38, ttEdition.Ligne, SEPAR[1]) <> "00000" and entry(06, ttEdition.Ligne, SEPAR[1]) <> "R" and not vlMobilier
            then for first sys_pg no-lock     /* Si tache TVA possible sur la nature du bail */
                 where sys_pg.tppar = "R_CTA"
                   and sys_pg.zone1 = pcNatureBail
                   and sys_pg.zone2 = {&TYPETACHE-TVABail}:
                /*--> Creation de la tache si manquante */
                empty temp-table ttTache.
                create ttTache.
                assign
                    ttTache.CRUD  = "C"
                    ttTache.tpcon = pcTypeBail
                    ttTache.nocon = piNumeroBail
                    ttTache.tptac = {&TYPETACHE-TVABail}
                    ttTache.notac = 1
                    ttTache.dtdeb = gdaDebut
                    ttTache.ntGes = entry(38, ttEdition.Ligne, SEPAR[1])
                    ttTache.pdGes = "00001"
                    ttTache.lbdiv = "778#01"
                    ttTache.dtTimestamp = now
                .
                run setTache in ghProcTache(input-output table ttTache by-reference).
                if mError:erreur() then return.
            end.

            /*--> TVA sur service annexe */
            /* suppession d'une éventuelle Tache pcTypeBail, piNumeroBail, TYPETACHE-TVAServicesAnnexes */
            run suppressionTache(pcTypeBail, piNumeroBail, {&TYPETACHE-TVAServicesAnnexes}).
            if ((entry(38, ttEdition.Ligne, SEPAR[1]) <> "00000" and entry(06, ttEdition.Ligne, SEPAR[1]) = "R")
              or entry(39, ttEdition.Ligne,SEPAR[1]) <> "00000"
              or entry(40, ttEdition.Ligne,SEPAR[1]) <> "00000") and not vlMobilier
            then  for first sys_pg no-lock    /*--> Si tache TVA possible sur la nature du bail */
                 where sys_pg.tppar = "R_CTA"
                   and sys_pg.zone1 = pcNatureBail
                   and sys_pg.zone2 = {&TYPETACHE-TVAServicesAnnexes}:
                /* Creation de la tache si manquante */
                /* calcul de tache.lbdiv */

                /*- Services Hoteliers -*/
                vcCodeTva = if num-entries(ttEdition.Ligne, SEPAR[1]) >= 39
                            then entry(39, ttEdition.Ligne, SEPAR[1]) else {&codeTVA-20}.
                if vcCodeTva = "00000" then vcCodeTva = {&codeTVA-20}.                   /* SY 1013/0167 */
                run donneRubTvadutaux(vcCodeTva, {&TYPETACHE-TVAServicesAnnexes}, output viNumeroRubriqueTva).
                assign
                    vcLibelleTva = substitute("&1#1#04#03#&2@", viNumeroRubriqueTva, vcCodeTva)
                    /*- Service Divers */
                    vcCodeTva = if num-entries(ttEdition.Ligne, SEPAR[1]) >= 40
                               then entry(40, ttEdition.Ligne, SEPAR[1]) else {&codeTVA-20}
                .
                if vcCodeTva = "00000" then vcCodeTva = {&codeTVA-20}.                      /* SY 1013/0167 */
                run donneRubTvadutaux(vcCodeTva, {&TYPETACHE-TVAServicesAnnexes}, output viNumeroRubriqueTva).
                assign
                    vcLibelleTva = substitute("&1&2#1#04#05#&3@", vcLibelleTva, viNumeroRubriqueTva, vcCodeTva)
                    /*- Redevance soumise à TVA */
                    vcCodeTva = if num-entries(ttEdition.Ligne, SEPAR[1]) >= 38
                                then entry(38, ttEdition.Ligne, SEPAR[1]) else {&codeTVA-10}
                .
                if vcCodeTva = "00000" then vcCodeTva = {&codeTVA-10}.             /* SY 1013/0167 TVA 10% */
                run donneRubTvadutaux(vcCodeTva, {&TYPETACHE-TVAServicesAnnexes}, output viNumeroRubriqueTva).
                assign
                    vcLibelleTva = substitute("&1&2#1#04#06#&3", vcLibelleTva, viNumeroRubriqueTva, vcCodeTva)
                    /* sous famille 8: Abonnement         :TVA  5.5% */
                    vcCodeTva    = {&codeTVA-1}
                .
                run donneRubTvadutaux(vcCodeTva, {&TYPETACHE-TVAServicesAnnexes}, output viNumeroRubriqueTva).
                vcLibelleTva = substitute("&1&2#1#04#08#&3", vcLibelleTva, viNumeroRubriqueTva, vcCodeTva).

                empty temp-table ttTache.
                create ttTache.
                assign
                    ttTache.CRUD  = "C"
                    ttTache.tpcon = pcTypeBail
                    ttTache.nocon = piNumeroBail
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
    ttQtt.mtqtt = calculTotalQuittance().
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
    define variable viNbMoiPer       as integer   no-undo.

    viNbMoiPer = if ttRub.CdFam = 4 then 1 else integer(substring(pcCodePeriode-IN, 1, 3, "character")).
    /*--> Parcours des rubriques de detlc */
boucle:
    for each detlc no-lock
       where detlc.tpCon = {&TYPECONTRAT-mandat2Gerance}
         and detlc.noCon = piNumeroMandat
         and detlc.noApp = piNumeroApp:
        /* Ajout Sy le 19/03/2010 : Si Honoraires locataires par le quittancement LF à FX */
        /*alors Anciennes rubriques EXTOURNABLES interdites */
        if glRubriqueQuittHonoCabinet
        and can-find(first pclie no-lock
                     where pclie.tppar = "RBEXT"
                       and pclie.zon01 = string(detlc.norub, "999")) then next boucle.

        if detlc.norub = 0          /* Modification SY le 19/03/2010: rub par défaut pour Loyer et charges uniquement */
        then case detlc.cdfam:
            when 1 then assign viNumeroRubrique = 101.
            when 2 then assign viNumeroRubrique = 200.
            /*WHEN 4 THEN ASSIGN viNumeroRubrique = 600.*/
            otherwise next boucle.
        end case.
        else viNumeroRubrique = detlc.norub.

        run infRubrique(viNumeroRubrique, detlc.noLib, detlc.mtRub * viNbMoiPer, piNumeroCal, piDenominateur).
    end.
    /*--> Total quittance */
    ttQtt.mtqtt = calculTotalQuittance().
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
        vdeCoefficient   = integer(substring(pcCodePeriode-IN, 1, 3, "character")) / integer(pcRubPerio)
    .
    do viCompteur = 1 to 3:
        vcRubriqueTemp = entry(viCompteur, vcLocationZone10, "@").
        case viCompteur:
            when 1 then assign
                viRubriqueTemp = 101
                viLibelleTemp  = 01
            .
            when 2 then assign
                viRubriqueTemp = 200
                viLibelleTemp  = 01
            .
            when 3 then assign
                viRubriqueTemp = 140
                viLibelleTemp  = 07
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
        then run infRubrique(viRubriqueTemp, viLibelleTemp, vdeMontantRubrique * vdeCoefficient, piNumeroCal, piDenominateur).

    end.
    ttQtt.mtqtt = calculTotalQuittance().
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

    run readRubqt in ghProcRubqt(piNumeroRubrique, piNumeroLibelle, table ttRub by-reference).
    find first ttRub
        where ttRub.noloc = 0
          and ttRub.noqtt = 0
          and ttRub.norub = piNumeroRubrique
          and ttRub.nolib = piNumeroLibelle no-error.
    if available ttRub
    then ttRub.LbRub = outilTraduction:getLibelle(ttRub.nome1).
    else do:
        create ttRub.
        assign
            ttRub.noRub = piNumeroRubrique
            ttRub.noLib = piNumeroLibelle
        .
    end.
    assign
        ttRub.mtTot = pdeMontant
        /*--> Calcul de la date de fin d'application RUB */
        /*--> Rubriques Fixes: Date fin appli 'loin dans le futur' ou dtfin */
        /*--> Rubriques Variables: Date fin appli = date fin de quittancement */
        ttRub.NoLoc = piNumeroBail
        ttRub.NoQtt = piNumeroQuittance
        ttRub.CdFam = ttRub.CdFam
        ttRub.CdDet = "0"
        ttRub.VlQte = 0
        ttRub.VlPun = 0
        ttRub.dtDap = gdaDebut
        ttRub.dtFap = if integer(ttRub.cdgen) = 1 then gdaFinApplicationMaximum else gdaFinCal
        ttQtt.nbRub = ttQtt.NbRub + 1
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

    if ttQtt.CdQuo = 1 then do:
        /**IF ttRub.CdFam = 4 AND
        /*MB ttRub.NoRub <> 650 AND ttRub.NoRub <> 651 AND ttRub.NoRub <> 652 AND ttRub.NoRub <> 655 AND ttRub.NoRub <> 685 */
        /*MB 0408/0174*/ LOOKUP(STRING(ttRub.norub), vcRubriquePro, ",") = 0
        OR ttRub.norub = giRubriqueFrais        /* Ajout SY le 19/03/2010 */
        THEN**/
        run isRubProCum(ttRub.norub, ttRub.nolib, output vlProrataRubrique, output vlCumulRubrique).
        if not vlProrataRubrique then ttRub.VlMtq = ttRub.MtTot.
        else assign
            ttRub.CdPro = 1
            ttRub.VlNum = piNumeroCal
            ttRub.VlDen = piDenominateur
            ttRub.VlMtq = ttRub.MtTot * piNumeroCal / piDenominateur
        .
    end.
    else ttRub.Vlmtq = ttRub.MtTot.
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

    /* Determination des mois de debut et fin de periode */
    assign
        viNbMoiPer             = integer(substring(pcCodePeriode-IN, 1, 3, "character"))
        viNoMoiApp             = month(pdaDebUse)
        viNoAnnDeb             = year(pdaDebUse)
        viNoAnnFin             = viNoAnnDeb
        viNoMoiRef             = integer(substring(pcCodePeriode-IN, 4))
        vlFournisseurLoyer     = goFournisseurLoyer:isGesFournisseurLoyer()
        vlBailFournisseurLoyer = can-find(first ctrat no-lock
                                 where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
                                   and ctrat.nocon = integer(truncate(piNumeroBail / 100000, 0))
                                   and (ctrat.ntcon = {&NATURECONTRAT-mandatLocation}
                                     or ctrat.ntcon = {&NATURECONTRAT-mandatLocationIndivision}))
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
            viNoMoiFpr = viNoMoiDpr + viNbMoiPer - 1
        .
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
    if not plPECgloba-IN then do:
        assign
            viNbMoiAdd = 0
            viNoMoiDpr = piMoisTraitementGI
            viMs1stQtt = if vlFournisseurLoyer and vlBailFournisseurLoyer
                         then poCollection:getInteger("GlMoiMdf")
                         else if pcCodeTerme = "00002"
                              then poCollection:getInteger("GlMoiMec")
                              else poCollection:getInteger("GlMoiMdf")
        .
        if vlFournisseurLoyer and vlBailFournisseurLoyer then viMs1stQtt = poCollection:getInteger("GlMoiMdf").
        do while  viNoMoiDpr < viMs1stQtt and viNoMoiDpr <> 0:
            assign
                viNoMoiDpr = integer(substring(string(viNoMoiDpr), 5, 2, "character")) + viNbMoiPer
                viNoMoiDpr = integer(substring(string(viNoMoiDpr), 1, 4, "character"))
                viNbMoiAdd = viNbMoiAdd + viNbMoiPer
            .
            if viNoMoiDpr > 12
            then assign
                viNoMoiDpr = viNoMoiDpr - 12
                viNoMoiDpr = viNoMoiDpr + 1
            .
            viNoMoiDpr = integer(string(viNoMoiDpr, "9999") + string(viNoMoiDpr,"99")).
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
    else if pdaFinBai <> ? and pdaFinBai >= pdaDebutperiode and pdaFinBai < pdaFinperiode and not glTacheRenouvellement
         then pdaFinCal = pdaFinBai - 1.
end procedure.

procedure suppressionTache:
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
        where bxrbp.ntbai = "03003"
          and bxrbp.cdfam = 05
          and bxrbp.cdsfa = 02
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
