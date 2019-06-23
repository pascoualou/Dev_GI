/*------------------------------------------------------------------------
File        : outilMandat.p
Purpose     : recherche liste des taches ou objets d'un contrat
Author(s)   : gga 2017/08/03
Notes       : a partir de adb/cont/gestac00.p, adb/lib/l_cttac_ext.p
derniere revue: 2018/04/18 - phm: KO
------------------------------------------------------------------------*/
{preprocesseur/codePeriode.i}
{preprocesseur/type2adresse.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/referenceClient.i}

using parametre.pclie.parametrageAgenceService.
using parametre.pclie.parametrageDefautMandat.
using parametre.pclie.parametrageFournisseurLoyer.
using parametre.pclie.parametrageGestionCVAE.
using parametre.pclie.parametrageGestionCommerciaux.
using parametre.pclie.parametrageHonoraireLocataire.
using parametre.pclie.parametrageImmobilierEntreprise.
using parametre.pclie.parametragePayePegase.
using parametre.pclie.parametrageRubriquesCalculees.
using parametre.pclie.parametrageReleveGerance.
using parametre.pclie.parametrageSuiviImpayeLocataire.
using parametre.pclie.parametrageBudgetLocatif.
using parametre.pclie.parametrageEditionCRG.
using parametre.syspg.parametrageNatureContrat.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{mandat/include/listeTache.i}
{mandat/include/listeObjet.i}
{application/include/glbsepar.i}
{adblib/include/cdpaycab.i}        // fonction getPaysCabinet
{adblib/include/cttac.i}

define variable gcListeTypeTache    as character no-undo.
define variable gcListeTacheCabinet as character no-undo.
define variable gcListeTacheActive  as character no-undo.
define variable gcListeTacheAutoMan as character no-undo.

function isCopropriete returns logical private(piNumeroMandat as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    return can-find(first aprof no-lock
                    where aprof.profil-cd = 91
                      and aprof.mandatdeb <= piNumeroMandat
                      and aprof.mandatfin >= piNumeroMandat).
end function.

function GerMdtLoc returns logical (pcNatureMandat as character):
    /*------------------------------------------------------------------------------
    Purpose: Savoir si on doit prévenir la compta en cas de modif/creation mandat.
             en fonction de la nature du mandat (03075 ou autre) et du modele de gestion des fournisseurs loyer
    Notes  : service externe
------------------------------------------------------------------------------*/
    define variable voFournisseurLoyer as class parametrageFournisseurLoyer no-undo.
    define variable voNatureContrat    as class parametrageNatureContrat    no-undo.
    define variable vlTypeFL as logical   no-undo.
    define variable vcModele as character no-undo.

    /* Tous les contrats de nature non 03075 et 03093 et 03085 doivent être pris en compte */
    if pcNatureMandat <> {&NATURECONTRAT-mandatLocation}
    and pcNatureMandat <> {&NATURECONTRAT-mandatLocationIndivision}
    and pcNatureMandat <> {&NATURECONTRAT-mandatLocationDelegue}
    then return true.

    /* nature FL */
    assign
        voNatureContrat = new parametrageNatureContrat(pcNatureMandat)
        vlTypeFL        = voNatureContrat:typeFL()
    .
    delete object voNatureContrat.
    if not vlTypeFL then return true.

    /* modele */
    assign
        voFournisseurLoyer = new parametrageFournisseurLoyer()
        vcModele           = voFournisseurLoyer:getCodeModele()
    .
    delete object voFournisseurLoyer.
    if vcModele = "00003" or vcModele = "00004" then return true.

    return false.

end function.

function listeToutesPeriodes returns character private(piNumeroMandat as integer, piNumeroExercice as integer):
    /*------------------------------------------------------------------------------
    Purpose: mise en forme des infos pour la comptabilité
    Notes  : "N" : toutes les périodes autres que traitées
    ------------------------------------------------------------------------------*/
    define variable vcListePeriode as character  no-undo.
    define buffer perio for perio.

    for each perio no-lock
        where perio.tpctt = {&TYPECONTRAT-mandat2Syndic}
          and perio.nomdt = piNumeroMandat
          and perio.noexo = piNumeroExercice
          and perio.noper > 0
          and (perio.cdtrt = "00001" or perio.cdtrt = "00002")
        by perio.noper:
        vcListePeriode = substitute("&1&2@&3@&4@&5|", vcListePeriode, string(perio.noper), string(perio.dtdeb), string(perio.dtfin), string(perio.cdtrt)).
    end.
    return trim(vcListePeriode, "|").
end function.

function listePeriodesNonTraitees returns character private(pcListePeriode as character, piNumeroMandat as integer, piNumeroExercice as integer):
    /*------------------------------------------------------------------------------
    Purpose: mise en forme des infos pour la comptabilité
    Notes  : Option "T" : toutes les périodes
    ------------------------------------------------------------------------------*/
    define buffer perio for perio.

    for each perio no-lock
        where perio.tpctt = {&TYPECONTRAT-mandat2Syndic}
          and perio.nomdt = piNumeroMandat
          and perio.noexo = piNumeroExercice
          and perio.noper > 0
          and perio.cdtrt <>"00000"       // pas les périodes "antérieures"
        by perio.noper:
        pcListePeriode = substitute("&1&2@&3@&4@&5|", pcListePeriode, string(perio.noper), string(perio.dtdeb), string(perio.dtfin), string(perio.cdtrt)).
    end.
    return pcListePeriode.
end function.

function lancementPgm return handle private(pcProgramme as character, pcProcedure as character, table-handle phTable ):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhProc as handle no-undo.

    run value(pcProgramme) persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run value(pcProcedure) in vhProc(table-handle phTable by-reference).
    run destroy in vhProc.

end function.

function lancementPgmCreationTache return handle private(pcProgramme as character, piNumeroMandat as integer, pcTypeMandat as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhProc as handle no-undo.

    run value(pcProgramme) persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run creationAutoTache in vhProc(piNumeroMandat, pcTypeMandat).
    run destroy in vhProc.

end function.

procedure chargePeriodesMandat:
    /*------------------------------------------------------------------------------
     Purpose: Chargement des périodes d'un mandat de gérance ou syndic
     Notes:  service externe (Appel depuis tacheCrg.p par ex.)
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroMandat          as integer   no-undo.
    define input  parameter pdaResponsableComptable as date      no-undo.
    define input  parameter pcCodeOption            as character no-undo.
    define output parameter pcCodeRetour            as character no-undo.
    define output parameter pcListePeriodeRetour    as character no-undo.

    define variable viNombreMoisPeriode     as integer  no-undo.
    define variable viPremierMoisPeriode    as integer  no-undo.
    define variable viNombreMoisCalcul      as integer  no-undo.
    define variable viAnneeDateComptable    as integer  no-undo.
    define variable viMoisDateComptable     as integer  no-undo.
    define variable viMoisEnCours           as integer  no-undo.
    define variable viPeriodeDebut          as integer  no-undo.
    define variable viPeriodeFin            as integer  no-undo.
    define variable viMoisDebut             as integer  no-undo.
    define variable viAnneeDebut            as integer  no-undo.
    define variable viJourFinPeriode        as integer  no-undo.
    define variable viMoisFin               as integer  no-undo.
    define variable viMoisSuivant           as integer  no-undo.
    define variable viAnneeFin              as integer  no-undo.
    define variable vdaMoisComptable        as date     no-undo.
    define variable viNumeroExerciceN       as integer  no-undo.
    define variable viNumeroExerciceNmoins1 as integer  no-undo.
    define variable viNumeroExerciceNmoins2 as integer  no-undo.
    define variable viNumeroExerciceNmoins3 as integer  no-undo.  /**Ajout OF le 22/04/2002**/
    define variable viCodeRetourProcedure   as integer  no-undo.
    define variable vdaDateDebut            as date     no-undo.
    define variable vdaDateFin              as date     no-undo.
    define variable vlCrgPartielsPourTrimestrielDecale as logical   no-undo.

    define variable voEditionCRG as class parametrageEditionCRG no-undo.

    define buffer pclie for pclie.
    define buffer tache for tache.
    define buffer sys_pg for sys_pg.

    assign
        viAnneeDateComptable = year(pdaResponsableComptable)
        viMoisDateComptable  = month(pdaResponsableComptable)
    .
    /* Tester le Numéro de Mandat. Le traitement est différent suivant qu'il s'agit de Gérance ou de Copropriété. */
    if not isCopropriete(piNumeroMandat) then do:
        /* Paramètre client pour traitement partiel CRG Trim Decalé */
        assign
            voEditionCRG                        = new parametrageEditionCRG()
            vlCrgPartielsPourTrimestrielDecale  = voEditionCRG:isTrimesDecalePartielFinAnnee()
        .
        delete object voEditionCRG.
        /* Rechercher la Périodicité du Mandat dans la Tache 'Compte Rendu de Gestion'. */
        find last tache no-lock
            where tache.tptac = {&TYPETACHE-compteRenduGestion}
              and tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and tache.nocon = piNumeroMandat no-error.
        /* Pas de Compte-Rendu de Gestion pour ce Mandat. */
        if not available tache then do:
            pcCodeRetour = "001".
            return.
        end.
        /* Récupération dans sys_pg de la Périodicité. */
        find first sys_pg no-lock
            where sys_pg.tppar = "O_PRD"
              and sys_pg.cdpar = tache.pdges no-error.
        if not available sys_pg then do:
            pcCodeRetour = "002".
            return.
        end.
        /* Récupération des infos sur la Périodicité. */
        assign
            viNombreMoisPeriode  = integer(sys_pg.zone6)
            viPremierMoisPeriode = integer(sys_pg.zone7)
        .
        /* Récupération Nb de Mois et 1er Mois Période. */
        if viNombreMoisPeriode = 0 or viPremierMoisPeriode = 0 then do:
            pcCodeRetour = "003".
            return.
        end.
        /* Initialiser les Variables de Bornes pour commencer à rechercher à quelle période correspond le Mois Comptable passé en paramètre. */
        assign
            viNombreMoisCalcul = viNombreMoisPeriode - 1
            viMoisEnCours      = viAnneeDateComptable * 12 + viMoisDateComptable
            viPeriodeDebut     = (viAnneeDateComptable - 1) * 12 + viPremierMoisPeriode
            viPeriodeFin       = viPeriodeDebut + viNombreMoisCalcul
        .
        do while viMoisEnCours < viPeriodeDebut or viMoisEnCours > viPeriodeFin:
            assign
                viPeriodeDebut = viPeriodeDebut + viNombreMoisPeriode
                viPeriodeFin   = viPeriodeDebut + viNombreMoisCalcul
            .
        end.
        /* Conversion Nb mois -> Date */
        assign
            viMoisDebut  = viPeriodeDebut modulo 12
            viAnneeDebut = truncate(viPeriodeDebut / 12, 0)
            viMoisFin    = viPeriodeFin modulo 12
            viAnneeFin   = truncate(viPeriodeFin / 12, 0)
        .
        if viMoisDebut = 0
        then assign
            viMoisDebut  = 12
            viAnneeDebut = viAnneeDebut - 1
        .
        if viMoisFin = 0
        then assign
            viMoisFin     = 12
            viAnneeFin    = viAnneeFin - 1
            viMoisSuivant = 01
        .
        else viMoisSuivant = viMoisFin + 1.
        /* Détermination du Jour de Fin de la période. */
        assign
            viJourFinPeriode = day(date(viMoisSuivant, 01, viAnneeFin) - 1)
            vdaDateDebut     = date( viMoisDebut, 01, viAnneeDebut)
            vdaDateFin       = date(viMoisFin, viJourFinPeriode, viAnneeFin)
        .
        /** Ajout SY le 20/01/2006 : CRG SPE MARNEZ */
        /* <Trimestriels décalés partiels en fin d'année> */
       if (tache.pdges = {&PERIODICITEGESTION-trimestrielFevAvril}
        or tache.pdges = {&PERIODICITEGESTION-trimestrielMarsMai})
       and (viMoisDateComptable = 11 or viMoisDateComptable = 12 or viMoisDateComptable = 01)
       and vlCrgPartielsPourTrimestrielDecale
       then do:
            if viMoisDateComptable = 11 and tache.pdges = {&PERIODICITEGESTION-trimestrielFevAvril}
            then assign
                vdaDateDebut = date(11, 01, viAnneeDateComptable)
                vdaDateFin   = date(12, 31, viAnneeDateComptable)
            .
            else if viMoisDateComptable = 12
            then if tache.pdges = {&PERIODICITEGESTION-trimestrielFevAvril}
                 then assign
                     vdaDateDebut = date(11, 01, viAnneeDateComptable)
                     vdaDateFin   = date(12, 31, viAnneeDateComptable)
                 .
                 else assign
                     vdaDateDebut = date(12, 01, viAnneeDateComptable)
                     vdaDateFin   = date(12, 31, viAnneeDateComptable)
                 .
            else if tache.pdges = {&PERIODICITEGESTION-trimestrielFevAvril}
                 then assign
                     vdaDateDebut = date(01, 01, viAnneeDateComptable)
                     vdaDateFin   = date(01, 31, viAnneeDateComptable)
                 .
                 else assign
                     vdaDateDebut = date(01, 01, viAnneeDateComptable)
                     vdaDateFin   = date(03, 01, viAnneeDateComptable) - 1      /* fin février */
                 .
        end.
        assign
            viMoisDebut          = month(vdaDateDebut)
            viAnneeDebut         = year(vdaDateDebut)
            viMoisFin            = month(vdaDateFin)
            viAnneeFin           = year(vdaDateFin)
            viJourFinPeriode     = day(vdaDateFin)
            pcListePeriodeRetour = substitute("01&1&2@&3&4&5", string(viMoisDebut, "99"), string(viAnneeDebut, "9999"), string(viJourFinPeriode, "99"), string(viMoisFin, "99"), string(viAnneeFin, "9999"))
            pcCodeRetour         = "000"
        .
    end.
    else do:    /* Traitement MANDAT DE COPROPRIETE */
        /* Retravail mois comptable: SSAAMM => JJ/MM/SSAA */
        assign
            pcListePeriodeRetour = ""
            vdaMoisComptable     = date(viMoisDateComptable, 1, viAnneeDateComptable)
        .
        /* Recherche exercice correspondant mois cptable */
        run rechercheExercices(piNumeroMandat, vdaMoisComptable, output viNumeroExerciceN, output viNumeroExerciceNmoins1, output viNumeroExerciceNmoins2, output viNumeroExerciceNmoins3, output viCodeRetourProcedure).
        if viCodeRetourProcedure <> 0 then do:
            /* Traitement des périodes */
            case pcCodeOption:
                /* Toutes les périodes (exo N-2, N-1, N */
                when "T" then do:
                    /* Mise en forme des infos pour la compta N-3 (Ajout OF le 22/04/2002) */
                    if viNumeroExerciceNmoins3 <> 0
                    then pcListePeriodeRetour = listePeriodesNonTraitees(pcListePeriodeRetour, piNumeroMandat, viNumeroExerciceNmoins3).
                    /* Mise en forme des infos pour la compta N-2 */
                    if viNumeroExerciceNmoins2 <> 0
                    then pcListePeriodeRetour = listePeriodesNonTraitees(pcListePeriodeRetour, piNumeroMandat, viNumeroExerciceNmoins2).
                    /* Mise en forme des infos pour la compta N-1 */
                    if viNumeroExerciceNmoins1 <> 0
                    then pcListePeriodeRetour = listePeriodesNonTraitees(pcListePeriodeRetour, piNumeroMandat, viNumeroExerciceNmoins1).
                    /* Mise en forme des infos pour la compta N */
                    pcListePeriodeRetour = listePeriodesNonTraitees(pcListePeriodeRetour, piNumeroMandat, viNumeroExerciceN).
                    pcListePeriodeRetour = trim(pcListePeriodeRetour, "|").
                end.
                /* Toutes les périodes non traitées (exo N). Mise en forme des infos pour la compta */
                when "N" then pcListePeriodeRetour = listeToutesPeriodes(piNumeroMandat, viNumeroExerciceN).
            end case.
            pcCodeRetour = "000".
        end.
        else pcCodeRetour = "004".
    end.

end procedure.

procedure getListeTache:
    /*------------------------------------------------------------------------------
    Purpose: liste des taches du contrat
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttListeTache.

    define buffer ctrat for ctrat.

    empty temp-table ttListeTache.
    find first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat
    then mError:createError({&error}, 100057).
    else do:
        run chargeParametreActivationTache.
        run chargeTacheParNatureContrat(piNumeroContrat, pcTypeContrat, ctrat.ntcon).
        run chargeInformationTachePec(piNumeroContrat, pcTypeContrat).
        run chargeInformationTachePecSpecifique(piNumeroContrat, pcTypeContrat, ctrat.ntcon).
        run triInformationTacheObl(ctrat.ntcon).
    end.

end procedure.

procedure chargeTacheParNatureContrat private:
    /*------------------------------------------------------------------------------
    Purpose: chargement des taches pour la nature du contrat
    Notes  : pour creation table tache, extrait de adb/cont/gestac00.p (LoaTabTac + GesPECTac)
             pour determiner si creation cttac automatique, extrait de adb/lib/l_cttac_ext.p (GenTacLie)
             pour determiner si creation tache automatique, extrait de adb/lib/l_tache_ext.p (GenTacAuto)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter pcNatureContrat as character no-undo.

    define variable viNoPosTac             as integer   no-undo.
    define variable vcNatureContratMaitre  as character no-undo.
    define variable vcDepartement          as character no-undo.
    define variable vcLstCodPos            as character no-undo.
    define variable vcTacheMandatADB       as character no-undo.  // Liste des taches du mandat associées à la compta ADB
    define variable vcTacheBailADB         as character no-undo.  // Liste des taches du Bail associées à la compta ADB
    define variable vcTachePrebailInterdit as character no-undo.  // Liste des taches du Pré-Bail interdites
    define variable vcReferenceAllianz     as character no-undo.  // liste des références gérance Allianz
    define variable vcReferenceMGP         as character no-undo.  // liste des références spécifique MGP
    define variable vcCdPaysCabinet        as character no-undo.
    define variable vlGestionTache         as logical   no-undo.
    define variable voFournisseurLoyer     as class parametrageFournisseurLoyer     no-undo.
    define variable voHonoraireLocataire   as class parametrageHonoraireLocataire   no-undo.
    define variable voPayePegase           as class parametragePayePegase           no-undo.
    define variable voGestionCVAE          as class parametrageGestionCVAE          no-undo.
    define variable voRubriquesCalculees   as class parametrageRubriquesCalculees   no-undo.
    define variable voImmobilierEntreprise as class parametrageImmobilierEntreprise no-undo.
    define variable voGestionCommerciaux   as class parametrageGestionCommerciaux   no-undo.
    define variable voSuiviImpayeLocataire as class parametrageSuiviImpayeLocataire no-undo.
    define variable voReleveGerance        as class parametrageReleveGerance        no-undo.
    define variable voBudgetLocatif        as class parametrageBudgetLocatif        no-undo.

    define buffer sys_pg   for sys_pg.
    define buffer vbsys_pg for sys_pg.
    define buffer ctrat    for ctrat.
    define buffer intnt    for intnt.
    define buffer ladrs    for ladrs.
    define buffer adres    for adres.

    if pcTypeContrat = {&TYPECONTRAT-bail} or pcTypeContrat = {&TYPECONTRAT-preBail}
    then for first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and ctrat.nocon = int64(truncate(piNumeroContrat / 100000, 0)):       // integer(substring(string(piNumeroContrat, "9999999999"), 1, 5, 'character')):
        vcNatureContratMaitre = ctrat.ntcon.
    end.
    assign
        voFournisseurLoyer      = new parametrageFournisseurLoyer()
        voHonoraireLocataire    = new parametrageHonoraireLocataire()
        voPayePegase            = new parametragePayePegase()
        voGestionCVAE           = new parametrageGestionCVAE()
        voRubriquesCalculees    = new parametrageRubriquesCalculees()
        voGestionCommerciaux    = new parametrageGestionCommerciaux()
        voImmobilierEntreprise  = new parametrageImmobilierEntreprise()
        voSuiviImpayeLocataire  = new parametrageSuiviImpayeLocataire()
        voReleveGerance         = new parametrageReleveGerance()
        voBudgetLocatif         = new parametrageBudgetLocatif()
        vcTacheMandatADB        = substitute("&1,&2,&3,&4,&5,&6", {&TYPETACHE-acomptesProprietaires},{&TYPETACHE-acomptesMandat},{&TYPETACHE-comptabilite},{&TYPETACHE-comptabiliteMandant},{&TYPETACHE-positionComptableMandat},{&TYPETACHE-interrogationCompteMandant})
        vcTacheBailADB          = substitute("&1,&2,&3",          {&TYPETACHE-depotGarantieBail},{&TYPETACHE-comptabilite},{&TYPETACHE-positionComptableBail})
        vcTachePrebailInterdit  = substitute("&1,&2,&3,&4",       {&TYPETACHE-comptabilite},{&TYPETACHE-bailleur},{&TYPETACHE-positionComptableBail},{&TYPETACHE-suiviAdministratif})
        vcReferenceAllianz      = "{&REFCLIENT-ALLIANZ},{&REFCLIENT-ALLIANZRECETTE},{&REFCLIENT-GIDEV},{&REFCLIENT-GICLI}"
        vcReferenceMGP          = "{&REFCLIENT-MGP},{&REFCLIENT-GIDEV},{&REFCLIENT-GICLI}"
        vcLstCodPos             = "75,77,78,91,92,93,94,95"
    .
boucle:
    for each sys_pg no-lock
        where sys_pg.tppar = 'R_CTA'
          and sys_pg.zone1 = pcNatureContrat
          and sys_pg.maxim <> 0:  /* NP 14/05/2014: Ajout pour gérer la tâche 04376 Frais d'entrée INVISIBLE pour évolution Carturis */
        vlGestionTache = yes.
        if mtoken:cRefPrincipale = "00010"     // spécifique MANPOWER: filtrage des taches inutilisées
        and (sys_pg.zone2 = {&TYPETACHE-garantieLoyer}
          or sys_pg.zone2 = {&TYPETACHE-chargesLocatives}
          or sys_pg.zone2 = {&TYPETACHE-CRL}
          or sys_pg.zone2 = {&TYPETACHE-attestationsLocatives}
          or sys_pg.zone2 = {&TYPETACHE-TVAServicesAnnexes}
          or sys_pg.zone2 = {&TYPETACHE-beneficiaire}
          or sys_pg.zone2 = {&TYPETACHE-bailleur}
          or sys_pg.zone2 = {&TYPETACHE-04112}
          or sys_pg.zone2 = {&TYPETACHE-04113}
          or sys_pg.zone2 = {&TYPETACHE-04114}
          or sys_pg.zone2 = {&TYPETACHE-usufruitNuePropriete5}
          or sys_pg.zone2 = {&TYPETACHE-usufruitNuePropriete6}
          or sys_pg.zone2 = {&TYPETACHE-modeReglement}
          or sys_pg.zone2 = {&TYPETACHE-occupantsDesLots}
          or sys_pg.zone2 = {&TYPETACHE-04119}
          or sys_pg.zone2 = {&TYPETACHE-garantieLoyer%Deductible}
          or sys_pg.zone2 = {&TYPETACHE-garantieLocataire}
          or sys_pg.zone2 = {&TYPETACHE-loyerContractuel}
          or sys_pg.zone2 = {&TYPETACHE-allocationLogement}
          or sys_pg.zone2 = {&TYPETACHE-eclatementEncaissement}
          or sys_pg.zone2 = {&TYPETACHE-honorairesLocataires}
          or sys_pg.zone2 = {&TYPETACHE-assuranceLocative}) then vlGestionTache = no.

        // Si tâche Bailleur: verifier que le mandat maitre est un mandat "sous-location" (03076, 03086)
        if sys_pg.zone2 = {&TYPETACHE-bailleur}
        and ((vcNatureContratMaitre <> {&NATURECONTRAT-mandatSousLocation} and vcNatureContratMaitre <> {&NATURECONTRAT-mandatSousLocationDelegue})
           or voFournisseurLoyer:getCodeModele() <> "00002") then vlGestionTache = no.  /* Ajout SY le 05/03/2012: Tache Bailleur pour LCL uniquement */

        // Tva sur services annexes: interdit aux Fournisseurs de loyer => interdit si le mandat maitre est un mandat location
        if sys_pg.zone2 = {&TYPETACHE-TVAServicesAnnexes}
        and (vcNatureContratMaitre = {&NATURECONTRAT-mandatLocation}
          or vcNatureContratMaitre = {&NATURECONTRAT-mandatLocationIndivision}
          or vcNatureContratMaitre = {&NATURECONTRAT-mandatLocationDelegue}) then vlGestionTache = no.

        // Contrôler que c'est bien une Tâche 'Gestion'. vbsys_pg utilisé plus bas.
        find first vbsys_pg no-lock
            where vbsys_pg.tppar = 'O_TAE'
              and vbsys_pg.cdpar = sys_pg.zone2 no-error.
        if not available vbsys_pg then vlGestionTache = no.

        // Ignorer la tache Honoraire Locataire si pas parametrée pour le cabinet
        if (pcTypeContrat = {&TYPECONTRAT-bail} or pcTypeContrat = {&TYPECONTRAT-preBail})
        and sys_pg.zone2 = {&TYPETACHE-honorairesLocataires}
        and not voHonoraireLocataire:isActif() then vlGestionTache = no.

        if pcTypeContrat = {&TYPECONTRAT-preBail}    // Taches à ignorer si Pré-Bail
        and (sys_pg.zone2 = {&TYPETACHE-allocationLogement} or sys_pg.zone2 = {&TYPETACHE-renouvellement})
        then vlGestionTache = no.

        // Taches à ignorer si Bail
        /* NP 14/05/2014 : Ajout pour gérer la tâche 04376 Frais d'entrée Prébail INVISIBLE pour évolution Carturis */
        if pcTypeContrat = {&TYPECONTRAT-bail} and sys_pg.zone2 = {&TYPETACHE-fraisEntree} then vlGestionTache = no.

        /* NP 0715/0201 Spécifique ALLIANZ - Gestionnaire de l'actif */
        if lookup(mtoken:cRefPrincipale, vcReferenceAllianz) = 0
        and sys_pg.zone2 = {&TYPETACHE-gestionnaireActif} then vlGestionTache = no.

/*gga pour l'instant on renseigne ces infos dans la table
        // Ignorer la tache en cours si c'est une fille d'une autre tache qui n'a pas été prise en charge
        if sys_pg.zone7 > ""
        and not can-find (first cttac no-lock
                          where cttac.tpcon = pcTypeContrat
                            and cttac.nocon = piNumeroContrat
                            and cttac.tptac = sys_pg.zone7) then vlGestionTache = no.

        // Ignorer la tache en cours si au moins une de ses taches exclusives a été prise en charge
        if sys_pg.zone6 > ""
        then do viCpTacExc = 1 to num-entries(sys_pg.zone6, '@'):
            if can-find(first cttac no-lock
                        where cttac.tpcon = pcTypeContrat
                          and cttac.nocon = piNumeroContrat
                          and cttac.tptac = entry(viCpTacExc, sys_pg.zone6, '@')) then vlGestionTache = no.
        end.
gga*/

        /*--> Tache à afficher ou non en fonction de l'ouverture d'un module optionnel ou spécifique client... */
        case sys_pg.zone2:
            when {&TYPETACHE-franchise}                 then if not voImmobilierEntreprise:isActif() then vlGestionTache = no.
            when {&TYPETACHE-regulChargesLocatives}     then if not voImmobilierEntreprise:isActif() then vlGestionTache = no.
            when {&TYPETACHE-gestionCommerciaux}        then if not voGestionCommerciaux:isActif() then vlGestionTache = no.
            when {&TYPETACHE-quittancementRubCalculees} then if not voRubriquesCalculees:isActif() then vlGestionTache = no.
            when {&TYPETACHE-suiviImpayesLocataires}    then if not voSuiviImpayeLocataire:isActif() then vlGestionTache = no.
            when {&TYPETACHE-paiePegase}                then if not voPayePegase:isActif() then vlGestionTache = no.
            when {&TYPETACHE-CVAE}                      then if not voGestionCVAE:isActif() then vlGestionTache = no.
        end case.

        /* Ajout SY le 21/10/2005: Ignorer la tache si elle n'est pas paramétrée pour le Cabinet (DEFMA) */
        viNoPosTac = lookup(sys_pg.zone2, gcListeTypeTache).
        if viNoPosTac > 0     /* Flag Tache gérée par le Cabinet */
        and entry(viNoPosTac, gcListeTacheCabinet) = "NO" then vlGestionTache = no.

        /*--> NP 1010/0218 Ignorer la tâche TVA-EDI si module TVA-EDI non ouvert **/
        if sys_pg.zone2 = {&TYPETACHE-tvaEdi}
        and not can-find(first iparm no-lock
                         where iparm.soc-cd  = integer(mtoken:cRefPrincipale)
                           and iparm.etab-cd = 0
                           and iparm.tppar   = "TVAEDI"
                           and iparm.cdpar   = "ACTIV"
                           and iparm.zone2   = "O") then vlGestionTache = no.

        /*--> NP 1212/0230 Ignorer la tâche DIF si Dif non ouvert sur le mandat **/
        if sys_pg.zone2 = {&TYPETACHE-DIF}
        and ((pcNatureContrat <> {&NATURECONTRAT-salarieCopropriete} and pcNatureContrat <> {&NATURECONTRAT-salarieGerance})
          or not can-find(first etabl no-lock
                          where etabl.tpcon = (if pcNatureContrat = {&NATURECONTRAT-salarieGerance}
                                               then {&TYPECONTRAT-mandat2Syndic} else {&TYPECONTRAT-mandat2Gerance})
                            and etabl.nocon = integer(truncate(piNumeroContrat / 100, 0))   // integer(substring(string(piNumeroContrat, "999999"), 1, 4, 'character'))
                            and etabl.dif-fgini))
        then vlGestionTache = no.

        if sys_pg.zone2 = {&TYPETACHE-04119} and lookup(mtoken:cRefPrincipale, vcReferenceMGP) = 0 then vlGestionTache = no.   /* SY 0716/0151 specif MGP */

        if vlGestionTache = no
        and not(sys_pg.maxim = 1 and sys_pg.maxim = sys_pg.minim)          //dans le traitement de la PEC, les taches obligatoires sont geres sans filtrage (GesPECTac)
        then next boucle.

        create ttListeTache.
        assign
            ttListeTache.cTypeContrat        = pcTypeContrat
            ttListeTache.iNumeroContrat      = piNumeroContrat
            ttListeTache.cTypeTache          = string(sys_pg.zone2)
            ttListeTache.lObligatoire        = (sys_pg.maxim = 1 and sys_pg.maxim = sys_pg.minim)
            ttListeTache.cLibelleTache       = trim(outilTraduction:getLibelle(vbsys_pg.nome1))
            ttListeTache.lTacheContrat       = (index('CL', entry(1, vbsys_pg.zone9, '@')) > 0)
            ttListeTache.cTypeTacheMere      = sys_pg.zone7                     // Ignorer la tache en cours si c'est une fille d'une autre tache qui n'a pas été prise en charge
            ttListeTache.cTypeTacheExclusive = sys_pg.zone6                     // Ignorer la tache en cours si au moins une de ses taches exclusives a été prise en charge
            ttListeTache.cInfoCodification   = vbsys_pg.zone9
            viNoPosTac                       = lookup(sys_pg.zone2, gcListeTypeTache)
        .
        if viNoPosTac > 0 then assign
            ttListeTache.lParamDefautGestionCabinet    = entry(viNoPosTac, gcListeTacheCabinet) = "yes"
            ttListeTache.lParamDefautActivation        = entry(viNoPosTac, gcListeTacheactive) = "yes"
            ttListeTache.lParamDefautCreationAutoTache = entry(viNoPosTac, gcListeTacheAutoMan) = "a"
        .
        if sys_pg.zone2 = {&TYPETACHE-04119}                                     //SY 0716/0151 Spécificités MGP obligatoire pour ref 03137
        and lookup(mtoken:cRefPrincipale, vcReferenceMGP) > 0
        and sys_pg.maxim = 1
        then ttListeTache.lObligatoire = yes.

        if can-find(first cttac no-lock
                    where cttac.tpcon = pcTypeContrat
                      and cttac.nocon = piNumeroContrat
                      and cttac.tptac = sys_pg.zone2) then ttListeTache.lCttacExiste = yes.
        if can-find(first tache no-lock
                    where tache.tpcon = pcTypeContrat
                      and tache.nocon = piNumeroContrat
                      and tache.tptac = sys_pg.zone2) then ttListeTache.lTacheExiste = yes.

        //determiner si creation automatique tache
        if num-entries(vbsys_pg.zone9, "@") >= 3
        and entry(1, vbsys_pg.zone9, '@') = 'G'
        and entry(3, vbsys_pg.zone9, "@") = 'A' then ttListeTache.lCodificationCreationAutoTache = yes.

        //determiner si creation automatique cttac
        if num-entries(vbsys_pg.zone9, "@") >= 3
        and (lookup(entry(1, vbsys_pg.zone9, '@'), 'C,L') > 0 or entry(3, vbsys_pg.zone9, "@") begins "A")
        then do:
            if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance} then do:
                /* Taxe sur bureau */
                if sys_pg.zone2 = {&TYPETACHE-taxeSurBureau}
                then for first intnt no-lock
                    where intnt.tpidt = {&TYPEBIEN-immeuble}
                      and intnt.tpcon = pcTypeContrat
                      and intnt.nocon = piNumeroContrat
                  , first ladrs no-lock
                    where ladrs.tpidt = intnt.tpidt
                      and ladrs.noidt = intnt.noidt
                      and ladrs.tpadr = {&TYPEADRESSE-Principale}
                  , first adres no-lock
                    where adres.noadr = ladrs.noadr:
                    vcCdPaysCabinet = getPaysCabinet().
                    if adres.cdpay <> vcCdPaysCabinet then next boucle.

                    assign vcDepartement = substring(string(integer(adres.cdpos)), 1, 2, "character") no-error. /* NP 1209/0025 */
                    if error-status:error or lookup(vcDepartement, vcLstCodPos) = 0 then next boucle.
                end.

                if sys_pg.zone2 = {&TYPETACHE-budgetLocatif} then do:
                    if not voBudgetLocatif:isBudgetLocatifActif()
                    or (pcNatureContrat <> {&NATURECONTRAT-mandatAvecIndivision} and pcNatureContrat <> {&NATURECONTRAT-mandatSansIndivision}) then next boucle.
                end.
                /* Filtrer les tache liées à la compta pour:           */
                /* - les mandats location (03075) et les baux associés */
                /* - les Pré-baux                                      */
                if (pcNatureContrat = {&NATURECONTRAT-mandatLocation}
                 or pcNatureContrat = {&NATURECONTRAT-mandatLocationIndivision}
                 or pcNatureContrat = {&NATURECONTRAT-mandatLocationDelegue})
                and lookup (sys_pg.zone2, vcTacheMandatADB, ",") > 0
                and integer(voFournisseurLoyer:getCodeModele()) < 3 then next boucle.
            end.

            if pcTypeContrat = {&TYPECONTRAT-bail}
            and (vcNatureContratMaitre = {&NATURECONTRAT-mandatLocation}
              or vcNatureContratMaitre = {&NATURECONTRAT-mandatLocationIndivision}
              or vcNatureContratMaitre = {&NATURECONTRAT-mandatLocationDelegue})
            and lookup (sys_pg.zone2, vcTacheBailADB, ",") > 0
            and integer(voFournisseurLoyer:getCodeModele()) < 3 then next boucle.

            /* Ajout SY le 15/10/2013: Filtrage Taches qui ne concernent pas Manpower */
            if integer(mtoken:cRefPrincipale) = 10 then do:
                if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance}
                and (lookup(sys_pg.zone2, vcTacheMandatADB, ",") > 0                 // pas compta,
                  or sys_pg.zone2 = {&TYPETACHE-usufruitNuePropriete6}               // pas usufruit,
                  or sys_pg.zone2 = {&TYPETACHE-mutation}) then next boucle.         // pas Mutation

                if pcTypeContrat = {&TYPECONTRAT-bail}
                and lookup (sys_pg.zone2, vcTacheBailADB, ",") > 0 then next boucle. // pas compta
            end.

            /* La tache "Bailleur" est réservée aux baux rattachés à un mandat sous-location pour le modele "Lots isoles" (CREDIT LYONNAIS) */
            if sys_pg.zone2 = {&TYPETACHE-bailleur}
            and (integer(voFournisseurLoyer:getCodeModele()) <> 2
              or (vcNatureContratMaitre <> {&NATURECONTRAT-mandatSousLocation} and vcNatureContratMaitre <> {&NATURECONTRAT-mandatSousLocationDelegue})
              or pcTypeContrat <> {&TYPECONTRAT-bail}) then next boucle.

            /* Pré-Baux : Filtrer les taches interdites */
            if pcTypeContrat = {&TYPECONTRAT-preBail}
            and lookup(sys_pg.zone2, vcTachePrebailInterdit, ",") > 0 then next boucle.

            /* Appels de fonds relevés ssi param à "OUI" */
            if pcTypeContrat = {&TYPECONTRAT-mandat2Syndic} and sys_pg.Zone2 = {&TYPETACHE-appelFondConsommation}
            and not voReleveGerance:isReleveAppelFondActif() then next boucle.

            ttListeTache.lCodificationCreationAutoCttac = yes.
        end.
    end.
    delete object voFournisseurLoyer.
    delete object voHonoraireLocataire.
    delete object voPayePegase.
    delete object voGestionCVAE.
    delete object voRubriquesCalculees.
    delete object voGestionCommerciaux.
    delete object voImmobilierEntreprise.
    delete object voSuiviImpayeLocataire.
    delete object voReleveGerance.
    delete object voBudgetLocatif.

end procedure.

procedure chargeParametreActivationTache private:
    /*------------------------------------------------------------------------------
    Purpose: charger les paramètres d'activation des taches paramétrées par défaut (DEFMA)
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voDefautMandat as class parametrageDefautMandat no-undo.

    assign
        gcListeTypeTache    = ""
        gcListeTacheCabinet = ""
        gcListeTacheActive  = ""
        gcListeTacheAutoMan = ""
        voDefautMandat      = new parametrageDefautMandat()
    .
    if voDefautMandat:isDbParameter then do:
        run decodPclie(voDefautMandat:zon02).
        run decodPclie(voDefautMandat:zon03).
        run decodPclie(voDefautMandat:zon04).
        run decodPclie(voDefautMandat:zon05).
        run decodPclie(voDefautMandat:zon06).
        run decodPclie(voDefautMandat:zon07).
        run decodPclie(voDefautMandat:zon08).
        run decodPclie(voDefautMandat:zon09).
        run decodPclie(voDefautMandat:zon10).
        run decodPclie(voDefautMandat:lbdiv).
        run decodPclie(voDefautMandat:lbdiv2).
        run decodPclie(voDefautMandat:lbdiv3).
    end.
    assign
        gcListeTypeTache    = trim(gcListeTypeTache, ",")
        gcListeTacheCabinet = trim(gcListeTacheCabinet, ",")
        gcListeTacheActive  = trim(gcListeTacheActive, ",")
        gcListeTacheAutoMan = trim(gcListeTacheAutoMan, ",")
    .

end procedure.

procedure decodPclie private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de décodage des flags d'activation des taches paramétrées dans DEFMA
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input parameter pcZoneParametre as character no-undo.

    define variable vcTypeTache      as character no-undo.
    define variable vlTacheCabinet   as logical   no-undo.
    define variable vlTacheActive    as logical   no-undo.
    define variable vcCodeTache      as character no-undo initial "M".
    define variable vcParametreTache as character no-undo.
    define variable vcLibelleTache   as character no-undo.

    if pcZoneParametre > "" then do:
        assign
            vcParametreTache = entry(1, pcZoneParametre, separ[3])
            vcLibelleTache   = if num-entries(pcZoneParametre, separ[3]) >= 2
                               then entry(2, pcZoneParametre, separ[3])
                               else substitute("YES&1&2&1M", separ[2], entry(2, vcParametreTache, separ[1]))
            vcTypeTache      = entry(1, vcParametreTache, separ[1])
            vlTacheCabinet   = (entry(1, vcLibelleTache, separ[2]) = "yes")
            vlTacheActive    = (entry(2, vcLibelleTache, separ[2]) = "yes")
            vcCodeTache      = entry(3, vcLibelleTache, separ[2])
        .
        if vcTypeTache > "" then assign
            gcListeTypeTache    = substitute("&1,&2", gcListeTypeTache, vcTypeTache)
            gcListeTacheCabinet = substitute("&1,&2", gcListeTacheCabinet, if vlTacheCabinet then "YES" else "NO")
            gcListeTacheActive  = substitute("&1,&2", gcListeTacheActive, if vlTacheActive then "YES" else "NO")
            gcListeTacheAutoMan = substitute("&1,&2", gcListeTacheAutoMan, vcCodeTache)
       .
    end.

end procedure.

procedure chargeInformationTachePec private:
    /*------------------------------------------------------------------------------
    Purpose: ajout des informations de la pec
    Notes  : extrait de adb/cont/gestac00.p
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.

    define variable viCalculRangPec as integer no-undo.
    define variable viNoPosTac      as integer no-undo.

    /*--> Lancement en 1er lieu de la tache 'Gestionnaire du Mandat' */
    for first ttListeTache
        where ttListeTache.cTypeContrat   = pcTypeContrat
          and ttListeTache.iNumeroContrat = piNumeroContrat
          and ttListeTache.cTypeTache     = {&TYPETACHE-services}:
        assign
            viCalculRangPec       = viCalculRangPec + 1
            ttListeTache.lPec     = yes
            ttListeTache.iRangPec = viCalculRangPec
        .
    end.

    if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance}
    then do viNoPosTac = 1 to num-entries(gcListeTypeTache):
        if entry(viNoPosTac, gcListeTacheActive) = "YES"
        then for first ttListeTache
            where ttListeTache.cTypeContrat   = pcTypeContrat
              and ttListeTache.iNumeroContrat = piNumeroContrat
              and ttListeTache.cTypeTache     = entry(viNoPosTac, gcListeTypeTache):
            assign
                viCalculRangPec       = viCalculRangPec + 1
                ttListeTache.lPec     = yes
                ttListeTache.iRangPec = viCalculRangPec
            .
        end.
    end.

end procedure.

procedure chargeInformationTachePecSpecifique private:
    /*------------------------------------------------------------------------------
    Purpose: ajout des informations de la pec specifique
    Notes  : extrait de adb/cont/gestac00.p
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter pcNatureContrat as character no-undo.

    define variable viCalculRangPecSpecifique as integer no-undo.
    define variable voGestionCommerciaux as class parametrageGestionCommerciaux no-undo.

    if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance} then do:
        if (pcNatureContrat = {&NATURECONTRAT-mandatAvecIndivision}
        or pcNatureContrat = {&NATURECONTRAT-mandatSansIndivision})
        and (can-find(first garan no-lock
                      where garan.tpctt = "01007"
                        and garan.nobar > 0
                        and (garan.txcot <> 0 or garan.txres <> 0))
          or can-find(first garan no-lock
                      where garan.tpctt = "01087"
                        and garan.nobar = 0)
          or can-find(first garan no-lock
                      where garan.tpctt >= "01020"
                        and garan.tpctt <= "01029"
                        and garan.noctt = 1
                        and garan.nobar = 0))
        then for first ttListeTache
            where ttListeTache.cTypeContrat   = pcTypeContrat
              and ttListeTache.iNumeroContrat = piNumeroContrat
              and ttListeTache.cTypeTache     = {&TYPETACHE-AssurancesLoyer}:
            assign
                viCalculRangPecSpecifique       = viCalculRangPecSpecifique + 1
                ttListeTache.lPecSpecifique     = yes
                ttListeTache.iRangPecSpecifique = viCalculRangPecSpecifique
            .
        end.

        for first ttListeTache
            where ttListeTache.cTypeContrat   = pcTypeContrat
              and ttListeTache.iNumeroContrat = piNumeroContrat
              and ttListeTache.cTypeTache     = {&TYPETACHE-UniteLocation}:
            assign
                viCalculRangPecSpecifique       = viCalculRangPecSpecifique + 1
                ttListeTache.lPecSpecifique     = yes
                ttListeTache.iRangPecSpecifique = viCalculRangPecSpecifique
            .
        end.
        voGestionCommerciaux = new parametrageGestionCommerciaux().
        if voGestionCommerciaux:isActif()
        then for first ttListeTache
            where ttListeTache.cTypeContrat   = pcTypeContrat
              and ttListeTache.iNumeroContrat = piNumeroContrat
              and ttListeTache.cTypeTache     = {&TYPETACHE-gestionCommerciaux}:
            assign
                viCalculRangPecSpecifique       = viCalculRangPecSpecifique + 1
                ttListeTache.lPecSpecifique     = yes
                ttListeTache.iRangPecSpecifique = viCalculRangPecSpecifique
            .
        end.
    end.
    //gga toto a completer pour autre type de contrat a partir de gestac00.p gesPECSpe, et gesPECSpe-1 ...

end procedure.

procedure triInformationTacheObl private:
    /*------------------------------------------------------------------------------
    Purpose: ajout des informations de la pec
    Notes  : extrait de adb/cont/gestac00.p
    ------------------------------------------------------------------------------*/
    define input parameter pcNatureContrat   as character no-undo.

    define variable viCalculRangObl as integer no-undo.
    define buffer sys_pg for sys_pg.

    //on refait une lecture pour classer les taches obligatoires dans l'ordre (by sys_pg.cdpar)
    for each sys_pg no-lock
        where sys_pg.tppar = 'R_CTA'
          and sys_pg.zone1 = pcNatureContrat
          and sys_pg.maxim <> 0
      , first ttListeTache
        where ttListeTache.cTypeTache   = string(sys_pg.zone2)
          and ttListeTache.lObligatoire = yes
        by sys_pg.cdpar:
        assign
            viCalculRangObl       = viCalculRangObl + 1
            ttListeTache.iRangObl = viCalculRangObl
        .
    end.

end procedure.

procedure getListeObjet:
    /*------------------------------------------------------------------------------
    Purpose: liste des objets du mandat
    Notes  : service externe (appel depuis beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.   //contrat
    define input parameter pcTypeContrat   as character no-undo.   //type contrat
    define output parameter table for ttListeObjet.

    define variable vlEtapDispo as logical no-undo.
    define variable viI         as integer no-undo.
    define variable viSeq       as integer no-undo.

    define buffer ctrat  for ctrat.
    define buffer sys_pg for sys_pg.

    empty temp-table ttListeObjet.
    find first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.

    for each sys_pg no-lock
        where sys_pg.tppar = "R_COP"
          and sys_pg.zone1 = ctrat.ntcon
        by sys_pg.cdpar:
        /* PL : 18/03/2003: on teste si cet item est dispo toutes ref ou ref spécifique */
        if sys_pg.zone6 > "" then do:
            vlEtapDispo = false.
            do viI = 1 to num-entries(sys_pg.zone6):
                if entry(viI, sys_pg.zone6) = mtoken:cRefPrincipale then vlEtapDispo = true.
            end.
        end.
        else vlEtapDispo = true.
        if vlEtapDispo then do:
            create ttListeObjet.
            assign
                viSeq                       = viSeq + 1
                ttListeObjet.cTypeContrat   = pcTypeContrat
                ttListeObjet.iNumeroContrat = piNumeroContrat
                ttListeObjet.cEtape         = "PEC"
                ttListeObjet.iSeq           = viSeq
                ttListeObjet.cRpRun         = sys_pg.rprun
                ttListeObjet.cNmPrg         = sys_pg.nmprg
                ttListeObjet.cdOpeCtr       = sys_pg.zone2
                ttListeObjet.cLbPrmCtr      = sys_pg.zone8
                ttListeObjet.lObligatoire   = (sys_pg.minim >= 1)
                ttListeObjet.cLibelleObjet  = trim(outilTraduction:getLibelle(sys_pg.nome1))
            .
        end.
    end.

end procedure.

procedure rechercheExercices private:
    /*------------------------------------------------------------------------------
    Purpose: permet de se positionner sur l'exercice en-cours selon le mois comptable
    Notes  : Ancienne procédure PrcPerEnc dans chgper01.p
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroMandat          as integer no-undo.
    define input  parameter pdaMoisComptable        as date    no-undo.
    define output parameter piNumeroExerciceN       as integer no-undo.
    define output parameter piNumeroExerciceNmoins1 as integer no-undo.
    define output parameter piNumeroExerciceNmoins2 as integer no-undo.
    define output parameter piNumeroExerciceNmoins3 as integer no-undo.  /**Ajout OF le 22/04/2002**/
    define output parameter piCodeRetour            as integer no-undo initial 1.

    define variable vcListeExercices as character no-undo.
    define variable vcTempo          as character no-undo.
    define variable vdaDebut         as date      no-undo.
    define variable vdaFin           as date      no-undo.
    define variable viNumeroExercice as integer   no-undo.

    define buffer perio for perio.

    /* RT: Si modification dans cette partie, penser à modifier librairie l_perio : RecPerio */
    assign
        vdaDebut = pdaMoisComptable
        vdaFin   = pdaMoisComptable
    .
    /* Recherche de l'exercice donné */
    find first perio no-lock
        where perio.tpctt =  {&TYPECONTRAT-mandat2Syndic}
          and perio.nomdt =  piNumeroMandat
          and perio.dtdeb <= vdaDebut
          and perio.dtfin >= vdaFin
          and perio.noper = 0 no-error.
    if not available perio
    then find last perio no-lock
        where perio.tpctt = {&TYPECONTRAT-mandat2Syndic}
          and perio.nomdt = piNumeroMandat
          and perio.cdtrt = "00001" no-error.
    if available perio then assign
        vcTempo          = "1"
        viNumeroExercice = perio.noexo
        vcListeExercices = substitute("&1@", perio.noexo)
    .
    else vcTempo = "0".
    /* Recherche de l'exercice N-1 */
    for first perio no-lock
        where perio.tpctt = {&TYPECONTRAT-mandat2Syndic}
          and perio.nomdt = piNumeroMandat
          and perio.noper = 0
          and perio.noexo = viNumeroExercice - 1:
        vcListeExercices = substitute("&1&2@", vcListeExercices, perio.noexo).
    end.
    /* Recherche de l'exercice N-2 */
    for first perio no-lock
        where perio.tpctt = {&TYPECONTRAT-mandat2Syndic}
          and perio.nomdt = piNumeroMandat
          and perio.noper = 0
          and perio.noexo = viNumeroExercice - 2:
        vcListeExercices = substitute("&1&2@", vcListeExercices, perio.noexo).
    end.
    /* Recherche de l'exercice N-3 (Ajout OF le 22/04/2002) */
    for first perio no-lock
        where perio.tpctt = {&TYPECONTRAT-mandat2Syndic}
          and perio.nomdt = piNumeroMandat
          and perio.noper = 0
          and perio.noexo = viNumeroExercice - 3:
        vcListeExercices = substitute("&1&2", vcListeExercices, perio.noexo).
    end.
    if integer(vcTempo) <> 0 then do:
        assign
            piNumeroExerciceN       = integer(entry(1, vcListeExercices, "@"))
            piNumeroExerciceNmoins1 = integer(entry(2, vcListeExercices, "@"))
            piNumeroExerciceNmoins2 = integer(entry(3, vcListeExercices, "@"))
            piNumeroExerciceNmoins3 = integer(entry(4, vcListeExercices, "@")) /**Ajout OF le 22/04/2202**/
        no-error.
        if piNumeroExerciceN = 0 then piCodeRetour = 0.
    end.
    else piCodeRetour = 0.

end procedure.

procedure creationAutoTache:
    /*------------------------------------------------------------------------------
    Purpose: Procedure qui permet de generer
             1- Les Liens 'Contrat-Tache' pour les Taches de type 'Contrat' ou automatique (CTTAC),
             2- Les Taches de Type Gestion et Automatiques (TACHE).
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat as character no-undo.
    define input parameter piNumeroContrat as int64 no-undo.

    define variable vcProgrammeCreation as character no-undo.

    define buffer ctrat for ctrat.

    find first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat then mError:createError({&error}, 100057).

    run getListeTache(ctrat.nocon, ctrat.tpcon, output table ttListeTache by-reference).
    if mError:erreur() then return.

    empty temp-table ttCttac.
    for first ttListeTache
        where ttListeTache.cTypeTache = {&TYPETACHE-services}
          and not can-find(first cttac no-lock
                           where cttac.tpcon = ctrat.tpcon
                             and cttac.nocon = ctrat.nocon
                             and cttac.tptac = ttListeTache.cTypeTache):
        create ttCttac.
        assign
            ttCttac.tpcon = ctrat.tpcon
            ttCttac.nocon = ctrat.nocon
            ttCttac.tptac = ttListeTache.cTypeTache
            ttCttac.CRUD  = "C"
        .
    end.
    for each ttListeTache
        where ttListeTache.lCodificationCreationAutoCttac
          and ttListeTache.cTypeTache <> {&TYPETACHE-services}
          and not can-find(first cttac no-lock
                           where cttac.tpcon = ctrat.tpcon
                             and cttac.nocon = ctrat.nocon
                             and cttac.tptac = ttListeTache.cTypeTache):
        create ttCttac.
        assign
            ttCttac.tpcon = ctrat.tpcon
            ttCttac.nocon = ctrat.nocon
            ttCttac.tptac = ttListeTache.cTypeTache
            ttCttac.CRUD  = "C"
        .
    end.
    lancementPgm("adblib/cttac_CRUD.p", "setCttac", table ttCttac by-reference).
    if mError:erreur() then return.

    for each ttListeTache
        where (ttListeTache.lParamDefautCreationAutoTache or ttListeTache.lCodificationCreationAutoTache)
          and not can-find(first tache no-lock
                           where tache.tpcon = ctrat.tpcon
                             and tache.nocon = ctrat.nocon
                             and tache.tptac = ttListeTache.cTypeTache):
        vcProgrammeCreation = "".
/*gga todo
a voir comment parametrer nom programme par rapport a type de tache et verifier si le pgm existe avec procedure de creation auto
pour l'instant coder en dur
gga todo */
        if ttListeTache.cTypeTache = {&TYPETACHE-depotGarantieMandat}
        then vcProgrammeCreation = "tache/tacheDepotGarantie.p".
        else if ttListeTache.cTypeTache = {&TYPETACHE-compteRenduGestion}
        then vcProgrammeCreation = "tache/tacheCrg.p".
        else if ttListeTache.cTypeTache = {&TYPETACHE-ImpotRevenusFonciers}
        then vcProgrammeCreation = "tache/tacheIrf.p".
        else if ttListeTache.cTypeTache = {&TYPETACHE-ImpotSolidariteFortune}
        then vcProgrammeCreation = "tache/tacheIsf.p".
/*gga todo
        else "ano". si programe pas existant 
gga todo*/
        if vcProgrammeCreation > ""
        then lancementPgmCreationTache(vcProgrammeCreation, ctrat.nocon, ctrat.tpcon).
    end.

end procedure.
