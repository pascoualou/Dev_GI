/*------------------------------------------------------------------------
File        : beMandatGerance.cls
Purpose     :
Author(s)   : KANTENA
Created     : Wed Jul 13 13:59:25 CEST 2016
Notes       :
derniere revue: 2018/05/16 - phm: KO
            (cosmetique fait: méthodes exposées mises en début de classe, trim trailing spaces.)
            traiter les todo
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/codeReglement.i}

@program FILE(name="beMandatGerance.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beMandatGerance", URI="/beMandatGerance", schemaName="dsbeMandatGerance", schemaFile="").

using outils.outilHandle.
using outils.collection.

block-level on error undo, throw.

class mandat.gerance.beMandatGerance:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define private property goCollection as class collection no-undo private get. private set.
    define public  property selfDestroy  as logical no-undo initial true private get. public set.
    {application/include/error.i}
    {application/include/listeErreur.i}    
    define variable ghProc           as handle no-undo.  /* plutôt que définir dans chacune des procédures. */
    define variable ghttAutorisation as handle no-undo.
    define variable ghttError        as handle no-undo.
    {mandat/include/mandat.i &nomtable=ttMandatGerance &serialName=ttMandatGerance}
    {mandat/include/listeMandat.i &nomtable=ttListeMandatGerance &serialName=ttListeMandatGerance}
    {mandat/include/listeNumeroContratDispo.i}
    {mandat/include/roleMandat.i &nomtable=ttRoleAnnexe}
    {mandat/include/roleMandat.i &nomtable=ttRoleContractant}
    {mandat/include/listeTache.i &nomtable=ttListeTacheMandatGerance &serialName=ttListeTacheMandatGerance}
    {mandat/include/listeObjet.i &nomtable=ttlisteObjetMandatGerance &serialName=ttlisteObjetMandatGerance}
    {tache/include/tacheDepotGarantie.i}
    {tache/include/tacheTva.i}
    {tache/include/tacheTvaEdi.i}
    {tache/include/tacheService.i}
    {tache/include/tacheClotureManuelle.i}
    {tache/include/tacheBaux.i}
    {tache/include/paramBaseRubrique.i}
    {tache/include/tacheCrg.i}
    {tache/include/tacheSigle.i}
    {tache/include/tacheAcomptes.i}
    {tache/include/tacheDas2.i}
    {tache/include/tacheAssurancesLoyer.i}
    {tache/include/tacheUniteLocation.i}
    {tache/include/tacheBeneficiaire.i}
    {tache/include/honoraire.i}
    {tache/include/honoraireCalculeUL.i}
    {tache/include/tacheRefacturationDepense.i}
    {tache/include/baremeHonoraire.i}
    {tache/include/tacheCrl.i}
    {tache/include/tachePaiePegase.i}
    {adb/paie/include/salariePegase.i}
    {adb/paie/include/organismesSociauxPegase.i}
    {adresse/include/adresse.i}
    {adresse/include/moyenCommunication.i}
    {application/include/combo.i}
    {mandat/include/bienMandat.i}
    {mandat/include/indivisaireMandat.i}
    {note/include/notes.i}
    {mandat/include/uniteComposition.i}
    {mandat/include/objetMandat.i}
    {mandat/include/uniteLocation.i}
    {adb/paie/include/etablissementPaie.i}
    {tache/include/usageUL.i}
    {tache/include/correspondanceUsageNatureUL.i}
    {tache/include/tachePNO.i}
    {tache/include/tacheChargeLocative.i}
    {tache/include/tacheTaxeBureau.i}
    {tache/include/tacheISF.i}
    {tache/include/tacheLoiDefiscalisationIRF.i}
    {tache/include/tacheEmpruntISF.i}
    {tache/include/tacheIRF.i}
    {tache/include/empruntISFAnnee.i}
    {tache/include/tacheEmpruntISF.i &nomtable=ttRecapEmpruntISF &serialName=ttRecapEmpruntISF}
    {tache/include/tacheEclatEnc.i}
    {tache/include/tacheCleRepartition.i}
    {mandat/include/clemi.i}
    {mandat/include/clemi.i &nomtable=ttCleRepartition &serialName=ttCleRepartition}
    {tache/include/tacheReleve.i}
    {tache/include/compteurReleve.i}
    {tache/include/tacheMutation.i}
    {tache/include/imputationParticuliere.i}
    
    define dataset dsbeMandatGerance for ttMandatGerance, ttListeMandatGerance, ttTacheDepotGarantie, ttTacheClotureManuelle, ttTacheBaux,
    ttTacheTva, ttProrataParExercice, ttTacheTvaEdi, ttTacheService, ttListeService, ttTacheUniteLocation, ttListeNumeroContratDispo,
    ttBaseCalcul, ttFamilleRubrique, ttRubrique,
    ttListeTacheMandatGerance, ttListeObjetMandatGerance,
    ttIndivisaire, ttTacheBeneficiaire,
    ttRoleAnnexe,
    ttRoleContractant,
    ttBienMandat, ttLotDispo,
    ttUsageUL, ttCorrespondanceUsageNatureUL,
    ttNotes,
    ttUniteLocation, ttCompositionUnite,
    ttBaremeHonoraire, ttTranche, ttHonoraireUL, ttHonoraireCalculeUL, ttChampsSaisissable, ttFamilleArticle, ttSousFamilleArticle, ttArticle,
    ttTacheRefacturationDepense, ttRefacturationRubrique, ttRefacturationLocataire, ttEdRefacturationDepense,
    ttTacheCrg,
    ttDocumentsCrg,
    ttCalendrierCrg,
    ttObjetMandatDescriptifGeneral,
    ttTacheSigle,
    ttSigle,
    ttTacheAcomptes,
    ttEcheancierAcomptes,
    ttParametrageAcomptes,
    ttTacheCrl,
    ttTachePaiePegase, ttOrganismeSociauxPegase,
    ttEtablissementPaie, ttSalariePegase, ttAdresse, ttMoyenCommunication,
    ttTacheDas2,
    ttTacheAssurancesLoyer,
    ttTachePNO, ttLotPNO, ttBareme, ttGarantie,
    ttTacheChargeLocative, ttCleChargeLocative, ttRubriqueChargeLocative,
    ttTacheTaxeBureau, ttULTaxeBureau, ttSurfaceTaxeBureau,
    ttTacheISF, ttSoldeProprietaireISF, ttRecapEmpruntISF,
    ttTacheEmpruntISF, ttEmpruntISFAnnee,
    ttTacheIRF,
    ttListeLotLoiDefiscalisationIRF, ttDetailLotLoiDefiscalisationIRF,
    ttTacheEclatEnc, ttFamilleRubriqueQuitt, ttSousFamilleRubriqueQuitt,
    ttTacheReleve,ttListeCompteur,
    ttListeLotMutation, ttMutation,
    ttImputationParticuliere,ttLigneImputationParticuliere,
    ttTacheCleRepartition, ttCleRepartition, ttDetailCle, ttClemi,
    ttCombo, ttError,
    ttListeErreur
    data-relation CompoUL for ttUniteLocation, ttCompositionUnite nested
        relation-fields (ttUniteLocation.iNumeroContrat    , ttCompositionUnite.iNumeroContrat,
                         ttUniteLocation.iNumeroAppartement, ttCompositionUnite.iNumeroAppartement,
                         ttUniteLocation.iNumeroComposition, ttCompositionUnite.iNumeroComposition)
    data-relation Usage for ttUsageUL, ttCorrespondanceUsageNatureUL nested foreign-key-hidden
        relation-fields (ttUsageUL.cCodeUsage, ttCorrespondanceUsageNatureUL.cCodeUsage)
	data-relation familleRubrique for ttBaseCalcul, ttFamilleRubrique nested
        relation-fields(ttBaseCalcul.cCodeBaseCalcul, ttFamilleRubrique.cCodeBaseCalcul)
    data-relation rubrique for ttFamilleRubrique, ttRubrique nested
        relation-fields(ttFamilleRubrique.cCodeBaseCalcul,  ttRubrique.cCodeBaseCalcul,
                        ttFamilleRubrique.iCodeFamille,     ttRubrique.iCodeFamille,
                        ttFamilleRubrique.iCodeSousFamille, ttRubrique.iCodeSousFamille)
    data-relation tranche for ttBaremeHonoraire, ttTranche nested foreign-key-hidden
        relation-fields(ttBaremeHonoraire.cTypeHonoraire, ttTranche.cTypeHonoraire,
                        ttBaremeHonoraire.iCodeHonoraire, ttTranche.iNumeroHonoraire)
    data-relation honoraireUL for ttBaremeHonoraire, ttHonoraireUL nested foreign-key-hidden
        relation-fields(ttBaremeHonoraire.cTypeHonoraire, ttHonoraireUL.cTypeHonoraire,
                        ttBaremeHonoraire.iCodeHonoraire, ttHonoraireUL.iCodeHonoraire)
    data-relation sousFamille for ttFamilleArticle, ttSousFamilleArticle  nested foreign-key-hidden
        relation-fields(ttFamilleArticle.cCodeFamille, ttSousFamilleArticle.cCodeFamille)
    data-relation Article for ttSousFamilleArticle, ttArticle  nested foreign-key-hidden
        relation-fields(ttSousFamilleArticle.cCodeFamille, ttArticle.cCodeFamille,
                        ttSousFamilleArticle.cCodeSousFamille, ttArticle.cCodeSousFamille)
        data-relation EcheancierAcomptes for ttTacheAcomptes, ttEcheancierAcomptes nested  foreign-key-hidden
            relation-fields(ttTacheAcomptes.iNumeroProprietaire, ttEcheancierAcomptes.iNumeroProprietaire)
        data-relation ParametrageAcomptes for ttTacheAcomptes, ttParametrageAcomptes nested  foreign-key-hidden
            relation-fields(ttTacheAcomptes.iNumeroProprietaire, ttParametrageAcomptes.iNumeroProprietaire)
    data-relation refacturationRubrique for ttTacheRefacturationDepense, ttRefacturationRubrique nested
        relation-fields(ttTacheRefacturationDepense.iNumeroMandat, ttRefacturationRubrique.iNumeroMandat)
    data-relation refacturationLocataire for ttRefacturationRubrique, ttRefacturationLocataire nested
        relation-fields(ttRefacturationRubrique.iNumeroMandat, ttRefacturationLocataire.iNumeroMandat,
                        ttRefacturationRubrique.iCodeRubriqueDepense, ttRefacturationLocataire.iCodeRubriqueDepense,
                        ttRefacturationRubrique.iCodeSousRubriqueDepense, ttRefacturationLocataire.iCodeSousRubriqueDepense,
                        ttRefacturationRubrique.iCodeFiscalite, ttRefacturationLocataire.iCodeFiscalite)
    data-relation PNO for ttTachePNO, ttLotPNO nested foreign-key-hidden
        relation-fields(ttTachePNO.iNumeroMandat, ttLotPNO.iNumeroMandat)
    data-relation soldeProprioISF for ttTacheISF, ttSoldeProprietaireISF nested foreign-key-hidden
        relation-fields(ttTacheISF.iNumeroTache, ttSoldeProprietaireISF.iNumeroTache)
    data-relation recapEmpruntISF for ttTacheISF, ttRecapEmpruntISF nested foreign-key-hidden
        relation-fields(ttTacheISF.cTypeContrat, ttRecapEmpruntISF.cTypeContrat)
    data-relation empruntISF for ttTacheEmpruntISF, ttEmpruntISFAnnee nested foreign-key-hidden
        relation-fields(ttTacheEmpruntISF.cTypeContrat,   ttEmpruntISFAnnee.cTypeContrat,
                        ttTacheEmpruntISF.iNumeroContrat, ttEmpruntISFAnnee.iNumeroContrat,
                        ttTacheEmpruntISF.iNumeroTache,   ttEmpruntISFAnnee.iNumeroTache)
    data-relation ttTacheEclatEncFam for ttTacheEclatEnc, ttFamilleRubriqueQuitt nested
        relation-fields(ttTacheEclatEnc.iNumeroContrat, ttFamilleRubriqueQuitt.iNumeroContrat)
    data-relation ttTacheEclatEncSsFam for ttFamilleRubriqueQuitt, ttSousFamilleRubriqueQuitt nested
        relation-fields(ttFamilleRubriqueQuitt.iNumeroContrat, ttSousFamilleRubriqueQuitt.iNumeroContrat,
                        ttFamilleRubriqueQuitt.iCodeFamille,   ttSousFamilleRubriqueQuitt.iCodeFamille)
    data-relation SalariePegaseAdresse         for ttSalariePegase, ttAdresse               nested
         relation-fields (ttSalariePegase.iNumeroIdentifiant, ttAdresse.iNumeroIdentifiant)
    data-relation SalariePegaseMoyenComm       for ttSalariePegase, ttMoyenCommunication    nested
         relation-fields (ttSalariePegase.iNumeroIdentifiant, ttMoyenCommunication.iNumeroIdentifiant)
    data-relation detail for ttImputationParticuliere, ttLigneImputationParticuliere nested foreign-key-hidden
        relation-fields (ttImputationParticuliere.iNumeroMandat   , ttLigneImputationParticuliere.iNumeroMandat,
                         ttImputationParticuliere.iNumeroImmeuble , ttLigneImputationParticuliere.iNumeroImmeuble,
                         ttImputationParticuliere.daDateImputation, ttLigneImputationParticuliere.daDateImputation)
    data-relation tacheCleRepartition for ttTacheCleRepartition, ttCleRepartition nested
        relation-fields(ttTacheCleRepartition.cTypeContrat, ttCleRepartition.cTypeContrat,
                        ttTacheCleRepartition.iNumeroContrat, ttCleRepartition.iNumeroContrat)
    data-relation detailCle for ttCleRepartition, ttDetailCle nested
        relation-fields(ttCleRepartition.cTypeContrat, ttDetailCle.cTypeContrat,
                        ttCleRepartition.iNumeroContrat, ttDetailCle.iNumeroContrat,
                        ttCleRepartition.cCodeCle, ttDetailCle.cCodeCle)
    data-relation LoiDefiscalisation for ttListeLotLoiDefiscalisationIRF, ttDetailLotLoiDefiscalisationIRF nested
        relation-fields(ttListeLotLoiDefiscalisationIRF.iNumeroContrat, ttDetailLotLoiDefiscalisationIRF.iNumeroContrat,
                        ttListeLotLoiDefiscalisationIRF.iNumeroLot, ttDetailLotLoiDefiscalisationIRF.iNumeroLot)
    data-relation taxebureau for ttULTaxeBureau, ttSurfaceTaxeBureau nested
        relation-fields(ttULTaxeBureau.iNumeroContrat,  ttSurfaceTaxeBureau.iNumeroContrat,
                        ttULTaxeBureau.iNumeroImmeuble, ttSurfaceTaxeBureau.iNumeroImmeuble,
                        ttULTaxeBureau.iNumeroUL,       ttSurfaceTaxeBureau.iNumeroUL,
                        ttULTaxeBureau.iComposition,    ttSurfaceTaxeBureau.iComposition)
/*
    data-relation Mutation for ttMutation, ttListeLotMutation nested
        relation-fields(ttMutation.cTypeContrat, ttListeLotMutation.cTypeContrat,
                        ttMutation.iNumeroContrat, ttListeLotMutation.iNumeroContrat,
                        ttMutation.iNumeroContratMutation, ttListeLotMutation.iNumeroContratMutation)
*/
    .

    constructor public beMandatGerance():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        goCollection = new collection().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeMandat(pcFiltre as longchar, output pcMandatGerance as longchar):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhttFilter            as handle    no-undo.
        define variable vhttField             as handle    no-undo.
        define variable vhBuffer              as handle    no-undo.
        define variable viNumeroMandat        as int64     no-undo.
        define variable vcVue                 as character no-undo.
        define variable vcTypeTrt             as character no-undo.
        define variable vcNatureMandat        as character no-undo.
        define variable viNumeroIndivisaire   as integer   no-undo.
        define variable vcListeCodeBaseCalcul as character no-undo.
        define variable viI                   as integer   no-undo.
        define variable viNumeroUL            as integer   no-undo.
        define variable vcCodeTypeSigle       as character no-undo.
        define variable viAnnee               as integer   no-undo.
        define variable vhDynamicDataSet      as handle    no-undo.
        define variable vcTypeCompteur        as character no-undo.
        define variable vcCodeLoi             as character no-undo.

        dataset dsbeMandatGerance:empty-dataset().
        pcFiltre = replace(pcFiltre, '[]', '""'). // Cas d'un extent vide
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viNumeroMandat      = vhBuffer::iNumeroContrat     no-error.
                viNumeroIndivisaire = vhBuffer::iNumeroIndivisaire no-error.
                vcVue               = vhBuffer::cVue               no-error.
                vcTypeTrt           = vhBuffer::cTypeTrt           no-error.
                vcNatureMandat      = vhBuffer::cNatureContrat     no-error.
                viNumeroUL          = vhBuffer::iNumeroUL          no-error.
                vhttField           = vhBuffer:buffer-field('cCodeBaseCalcul') no-error.
                vcCodeTypeSigle     = vhBuffer::cCodeTypeSigle     no-error.
                viAnnee             = vhBuffer::iAnnee             no-error.
                vcTypeCompteur      = vhBuffer::cTypeCompteur      no-error.
                vcCodeLoi           = vhBuffer::cCodeLoi           no-error.
                if valid-handle(vhttField)
                then if vhttField:extent > 0
                    then do viI = 1 to vhttField:extent:
                       vcListeCodeBaseCalcul = substitute('&1,&2', vcListeCodeBaseCalcul, vhttField:buffer-value(viI)) no-error.
                    end.
                    else vcListeCodeBaseCalcul = vhttField:buffer-value().
                vcListeCodeBaseCalcul = trim(vcListeCodeBaseCalcul, ",").
            end.
        end.
        if vcTypeTrt = "AUTORISATION"
        then do:
            create dataset vhDynamicDataSet.
            vhDynamicDataSet:name = "dsbeAutorisation".
        end.
        case vcVue:
            when 'MANDAT'                         then readMandat(vcTypeTrt, viNumeroMandat, vcNatureMandat).
            when 'MANDATOBJET'                    then readObjet(vcTypeTrt, viNumeroMandat).
            when 'MANDATROLEANNEXE'               then readRoleAnnexe(vcTypeTrt, viNumeroMandat).
            when 'MANDATINDIVISAIRE'              then readIndivisaire(vcTypeTrt, viNumeroMandat).
            when 'MANDATROLECONTRACTANT'          then readRoleContractant(vcTypeTrt, viNumeroMandat).
            when 'MANDATBIEN'                     then readBien(viNumeroMandat).
            when 'MANDATNOTES'                    then readNotes(viNumeroMandat).
            when 'TACHEDEPOTGARANTIE'             then readTacheDepotGarantie(vcTypeTrt, viNumeroMandat).
            when 'TACHEBAUX'                      then readTacheBaux(viNumeroMandat).
            when 'TACHECLOTUREMANUELLE'           then readTacheClotureManuelle(viNumeroMandat).
            when 'TACHEBENEFICIAIRE'              then readTacheBeneficiaire(vcTypeTrt, viNumeroMandat, viNumeroIndivisaire).
            when 'TACHETVA'                       then readTacheTva(vcTypeTrt, viNumeroMandat).
            when 'TACHETVAEDI'                    then readTacheTvaEdi(vcTypeTrt, viNumeroMandat).
            when 'TACHESERVICE'                   then readTacheService(vcTypeTrt, viNumeroMandat).
            when 'TACHEUNITELOCATION'             then readTacheUniteLocation(vcTypeTrt, viNumeroMandat, viNumeroUL).
            when 'PARAMUSAGES'                    then readParamUsages().
            when 'PARAMBASERUBRIQUE'              then readParamBaseRubrique(vcTypeTrt, vcListeCodeBaseCalcul).
            when 'BAREMEHONORAIRE'                then readBaremeHonoraire(vcTypeTrt, vhBuffer).
            when 'TACHEHONORAIRE'                 then readTacheHonoraire(vcTypeTrt, vhBuffer).
            when 'TACHECRG'                       then readTacheCrg(viNumeroMandat, vcTypeTrt).
            when 'TACHESIGLE'                     then readTacheSigle(viNumeroMandat, vcTypeTrt, vcCodeTypeSigle).
            when 'TACHEACOMPTES'                  then readTacheAcomptes(viNumeroMandat, vcTypeTrt).
            when 'TACHECRL'                       then readTacheCrl(viNumeroMandat, vcTypeTrt).
            when 'TACHEPAIEPEGASE'                then readTachePaiePegase(viNumeroMandat, vcTypeTrt).
            when 'TACHEPAIEPEGASEEMPLOYEIMMEUBLE' then readTachePaiePegaseEmployeImm(viNumeroMandat).
    	    when 'TACHEREFACTURATIONDEPENSE'      then readTacheRefacturationDepense(viNumeroMandat, vcTypeTrt, vhBuffer).
            when 'TACHEDAS2'                      then readTacheDas2(viNumeroMandat, vcTypeTrt).
            when 'TACHEASSURANCESLOYER'           then readTacheAssurancesLoyer(viNumeroMandat, vcTypeTrt).
            when 'TACHEPNO'                       then readTachePNO(viNumeroMandat, vcTypeTrt, vhBuffer).
	        when 'TACHECHARGELOCATIVEPRESTATION'  then readTacheChargeLocativePrestation(vcTypeTrt, viNumeroMandat).
            when 'TACHETAXEBUREAU'                then readTacheTaxeBureau(vcTypeTrt, viAnnee, viNumeroMandat).
	        when 'IMPUTATIONPARTICULIERE'         then readListeImputationParticuliere(viNumeroMandat).
            when 'TACHELOIDEFISCALISATIONIRF'     then readTacheLoiDefiscalisationIRF(vcTypeTrt, viNumeroMandat, vcCodeLoi).
            when 'TACHEMUTATION'                  then readTacheMutation(vcTypeTrt, viNumeroMandat).
            when 'REGROUPEMENTTACHE'              then do:
                readObjet(vcTypeTrt, viNumeroMandat).
                if vcTypeTrt <> "COMBO"                                 //gga todo a revoir pour gerer combo initialisation
                then do:
                    if not can-find(first ttError where ttError.iType >= {&error})
                    then readTacheClotureManuelle(viNumeroMandat).
                    if not can-find(first ttError where ttError.iType >= {&error})
                    then readTacheDepotGarantie(vcTypeTrt, viNumeroMandat).
                    if not can-find(first ttError where ttError.iType >= {&error})
                    then readTacheService(vcTypeTrt, viNumeroMandat).
                end.
                else do:
                    if not can-find(first ttError where ttError.iType >= {&error})
                    then readTacheDepotGarantie(vcTypeTrt, viNumeroMandat).
                end.
            end.
            when 'TACHEISF'            then readTacheISF(vcTypeTrt, viNumeroMandat).
            when 'TACHEEMPRUNTISF'     then readTacheEmpruntISF(vcTypeTrt, viNumeroMandat, vhBuffer).
            when 'TACHEIRF'            then readTacheIRF(vcTypeTrt, viNumeroMandat).
            when 'TACHEECLATENC'       then readTacheEclatEnc(vcTypeTrt, viNumeroMandat).
            when 'TACHERELEVE'         then readTacheReleve(viNumeroMandat, vcTypeTrt, vcTypeCompteur).
            when 'TACHECLEREPARTITION' then readTacheCleRepartition(vcTypeTrt, viNumeroMandat, vhbuffer).
            otherwise do:
                ghProc = outilHandle:connectMaGIModele("outils/erreur.p").
                run createError in ghProc({&error}, 211691, vcVue).          // vue demandée inexistante.
                run getErrors   in ghProc(output table ttError).
            end.
        end case.
        delete object vhttFilter no-error.
        if vcTypeTrt = "AUTORISATION"
        then do:
            vhDynamicDataSet:set-buffers(ghttAutorisation, ghttError).
            vhDynamicDataSet:write-json("LONGCHAR", pcMandatGerance, false, ?, false, false, false).
            /* 5eme parametre = false pour conserver les valeurs d'initialisation dans le flux (au moins pour les tests) */
        end.
        else do:
            dataset dsbeMandatGerance:write-json("LONGCHAR", pcMandatGerance, false, ?, false, false, false).
            /* 5eme parametre = false pour conserver les valeurs d'initialisation dans le flux (au moins pour les tests) */
        end.
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void rechercheMandatGerance(pcFiltre as longchar, output dataset dsbeMandatGerance):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhttFilter as handle  no-undo.
        define variable vhBuffer   as handle  no-undo.

        dataset dsbeMandatGerance:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                goCollection:set('iNumeroMandat'     , integer(vhBuffer::iNumeroMandat))    no-error.
                goCollection:set('iNumeroMandatDeb'  , integer(vhBuffer::iNumeroMandat1))   no-error.
                goCollection:set('iNumeroMandatFin'  , integer(vhBuffer::iNumeroMandat2))   no-error.
                goCollection:set('iNumeroMandant'    , integer(vhBuffer::iNumeroMandant))   no-error.
                goCollection:set('iNumeroMandantDeb' , integer(vhBuffer::iNumeroMandant1))  no-error.
                goCollection:set('iNumeroMandantFin' , integer(vhBuffer::iNumeroMandant2))  no-error.
                goCollection:set('iNumeroImmeuble'   , integer(vhBuffer::iNumeroImmeuble))  no-error.
                goCollection:set('iNumeroImmeubleDeb', integer(vhBuffer::iNumeroImmeuble1)) no-error.
                goCollection:set('iNumeroImmeubleFin', integer(vhBuffer::iNumeroImmeuble2)) no-error.
                goCollection:set('cNomMandant'       , vhBuffer::cNomMandant)               no-error.
                goCollection:set('cNatureMandat'     , vhBuffer::cNatureMandat)             no-error.
                goCollection:set('lActif'            , logical(vhBuffer::lActif))           no-error.
                goCollection:set('lInactif'          , logical(vhBuffer::lInactif))         no-error.
                goCollection:set('lProvisoire'       , logical(vhBuffer::lProvisoire))      no-error.
                goCollection:set('lEnCoursCreation'  , logical(vhBuffer::lEnCoursCreation)) no-error.
            end.
        end.
        delete object vhttFilter no-error.
        ghProc = outilHandle:connectMaGIModele("mandat/mandat.p").
        run getListeMandat in ghProc(goCollection, output table ttListeMandatGerance).
        run getErrors in ghProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    method public void readbeListeTache(pcFiltre as longchar, output dataset dsbeMandatGerance):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhttFilter     as handle    no-undo.
        define variable vhBuffer       as handle    no-undo.
        define variable viNumeroMandat as integer   no-undo.
        define variable vcVue          as character no-undo.

        dataset dsbeMandatGerance:empty-dataset().
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viNumeroMandat = vhBuffer::iNumeroContrat no-error.
                vcVue          = vhBuffer::cVue           no-error.
            end.
        end.
        delete object vhttFilter no-error.
        ghProc = outilHandle:connectMaGIModele("mandat/outilMandat.p").
        case vcVue:
            when 'TACHE' then run getListeTache in ghProc(viNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttListeTacheMandatGerance).
            when 'OBJET' then run getListeObjet in ghProc(viNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttListeObjetMandatGerance).
            otherwise do:
                run getListeTache in ghProc(viNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttListeTacheMandatGerance).
                run getListeObjet in ghProc(viNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttListeObjetMandatGerance).
            end.
        end case.
        run getErrors in ghProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void updatebeMandat(pcFiltre as longchar, input-output dataset dsbeMandatGerance):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhttFilter     as handle    no-undo.
        define variable vhBuffer       as handle    no-undo.
        define variable vcVue          as character no-undo.
        define variable viNumeroMandat as int64     no-undo.
        define variable vcTypeTrt      as character no-undo.
        define variable vcTypeUL       as character no-undo.

        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", pcFiltre, "empty") no-error. // il faut le no-error, mais error-status:error = false !!!
        vhBuffer = vhttFilter:default-buffer-handle no-error.
        if valid-handle(vhBuffer) then do:
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                viNumeroMandat = vhBuffer::iNumeroContrat no-error.
                vcVue          = vhBuffer::cVue           no-error.
                vcTypeTrt      = vhBuffer::cTypeTrt       no-error.
                vcTypeUL       = vhBuffer::cTypeUL        no-error.
            end.
        end.
        case vcVue:
            when 'MANDAT'                         then updateMandat(viNumeroMandat).
            when 'MANDATOBJET'                    then updateObjet(vcTypeTrt).
            when 'MANDATROLEANNEXE'               then updateRoleAnnexe().
            when 'MANDATROLECONTRACTANT'          then updateRoleContractant().
            when 'MANDATINDIVISAIRE'              then updateIndivisaire(viNumeroMandat).
            when 'MANDATBIEN'                     then updateBien(vcTypeTrt).
            when 'MANDATNOTES'                    then updateNotes(viNumeroMandat).
            when 'TACHEDEPOTGARANTIE'             then updateTacheDepotGarantie().
            when 'TACHECLOTUREMANUELLE'           then updateTacheClotureManuelle().
            when 'TACHETVA'                       then updateTacheTva().
            when 'TACHETVAEDI'                    then updateTacheTvaEdi().
            when 'TACHESERVICE'                   then updateTacheService().
            when 'TACHEBENEFICIAIRE'              then updateTacheBeneficiaire().
            when 'TACHEUNITELOCATION'             then updateTacheUniteLocation(vcTypeTrt, viNumeroMandat).
            when 'PARAMUSAGES'                    then updateParamUsages().
            when 'PARAMBASERUBRIQUE'              then updateParamBaseRubrique().
            when 'BAREMEHONORAIRE'                then updateBaremeHonoraire(vcTypeTrt).
            when 'TACHEHONORAIRE'                 then updateTacheHonoraire(vcTypeTrt, vhBuffer).
            when 'TACHECRG'                       then updateTacheCrg().
            when 'TACHESIGLE'                     then updateTacheSigle().
            when 'TACHEACOMPTES'                  then updateTacheAcomptes(vcTypeTrt).
            when 'TACHECRL'                       then updateTacheCrl().
            when 'TACHEPAIEPEGASE'                then updateTachePaiePegase().
            when 'TACHEREFACTURATIONDEPENSE'      then updateTacheRefacturationDepense(vcTypeTrt).
            when 'TACHEDAS2'                      then updateTacheDas2().
            when 'TACHEASSURANCESLOYER'           then updateTacheAssurancesLoyer().
            when 'TACHEPNO'                       then updateTachePNO(vcTypeTrt).
            when 'TACHECHARGELOCATIVEPRESTATION'  then updateChargeLocativePrestation().
            when 'TACHETAXEBUREAU'                then updateTaxeBureau().
            when 'TACHELOIDEFISCALISATIONIRF'     then updateLoiDefiscalisationIRF().
            when 'TACHEMUTATION'                  then updateTacheMutation(vcTypeTrt, vcTypeUL).
            when 'REGROUPEMENTTACHE'              then do:
                updateObjet(vcTypeTrt).
                if not can-find(first ttError where ttError.iType >= {&error}) then updateTacheClotureManuelle().
                if not can-find(first ttError where ttError.iType >= {&error}) then updateTacheDepotGarantie().
                if not can-find(first ttError where ttError.iType >= {&error}) then updateTacheService().
            end.
            when 'TACHEISF'            then updateTacheISF().
            when 'TACHEEMPRUNTISF'     then updateTacheEmpruntISF(vcTypeTrt).
            when 'TACHEIRF'            then updateTacheIRF().
            when 'TACHEECLATENC'       then updateTacheEclatEnc().
            when 'TACHERELEVE'         then updateTacheReleve().
            when 'TACHECLEREPARTITION' then updateTacheCleRepartition(vcTypeTrt).
            otherwise do:
                ghProc = outilHandle:connectMaGIModele("outils/erreur.p").
                run createError in ghProc({&error}, 211691, vcVue).          // vue demandée inexistante.
                run getErrors   in ghProc(output table ttError).
            end.
        end case.
        delete object vhttFilter no-error.
        {outils/include/tryCatch.i}
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    method public void createbeMandat(input-output dataset dsbeMandatGerance):
        /*------------------------------------------------------------------------------
        Purpose: Update one or more records
        Notes:
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("mandat/mandat.p").
        run CreateMandat in ghProc(table ttMandatGerance).
        dataset dsbeMandatGerance:empty-dataset().
        run getErrors in ghProc(output table ttError).
        {outils/include/tryCatch.i}

    end method.

    method private logical readMandat(pcTypeTrt as character, piNumeroMandat as int64, pcNatureMandat as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        case pcTypeTrt:
            when "LISTENATURECONTRAT"
            then do:
                ghProc = outilHandle:connectMaGIModele("mandat/listeCategorieContrat.p").
                run getListeCategorieContrat  in ghProc({&TYPECONTRAT-mandat2Gerance}, output table ttCombo).
            end.
            when "LISTENUMEROCONTRATDISPONIBLE"
            then do:
                ghProc = outilHandle:connectMaGIModele("adblib/ctrat_CRUD.p").
                run getListeNumeroContratDispo in ghProc({&TYPECONTRAT-mandat2Gerance}, pcNatureMandat, output table ttListeNumeroContratDispo).
            end.
            otherwise do:
                ghProc = outilHandle:connectMaGIModele("mandat/mandat.p").
                if pcTypeTrt = "INITIALISATION"
                then run initMandat in ghProc({&TYPECONTRAT-mandat2Gerance}, pcNatureMandat, output table ttMandatGerance).
                else
                if pcTypeTrt = "CONTROLE"
                then run controleMandat in ghProc({&TYPECONTRAT-mandat2Gerance}, piNumeroMandat).
            end.
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readObjet(pcTypeTrt as character, piNumeroMandat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("mandat/objetMandat.p").
        case pcTypeTrt:
            when "COMBO" then run initComboObjet in ghProc(output table ttCombo).
            when "AUTORISATION" then do:
                run initAutorisationObjet in ghProc(piNumeroMandat, output table-handle ghttAutorisation).
                run getErrors in ghProc(output table-handle ghttError).
            end.
            otherwise         run getObjet       in ghProc(pcTypeTrt, piNumeroMandat, output table ttMandatGerance, output table ttObjetMandatDescriptifGeneral).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readIndivisaire(pcTypeTrt as character, piNumeroMandat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("mandat/indivisaireContrat.p").
        case pcTypeTrt:
            when "COMBO" then run initComboIndivisaire in ghProc(output table ttCombo).
            otherwise         run getIndivisaire       in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttIndivisaire).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readRoleAnnexe(pcTypeTrt as character, piNumeroMandat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("mandat/roleAnnexeContrat.p").
        case pcTypeTrt:
            when "COMBO" then run initComboRoleAnnexe in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttCombo).
            otherwise         run getRoleAnnexe in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttRoleAnnexe).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readRoleContractant(pcTypeTrt as character, piNumeroMandat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("mandat/contractantContrat.p").
        case pcTypeTrt:
            when "COMBO" then run initComboContractant in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttCombo).
            otherwise         run getRoleContractant   in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttRoleContractant).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readBien(piNumeroMandat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("mandat/bienContrat.p").
        run getLot in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttBienMandat, output table ttLotDispo).
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readNotes(piNumeroMandat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("mandat/commentaireContrat.p").
        run getNotesContrat in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttNotes).
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readTacheDepotGarantie(pcTypeTrt as character, piNumeroMandat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheDepotGarantie.p").
        case pcTypeTrt:
            when "INITIALISATION" then run initDepotGarantie      in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttTacheDepotGarantie).
            when "COMBO"          then run initComboDepotGarantie in ghProc(output table ttCombo append).
            otherwise                  run getDepotGarantie       in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttTacheDepotGarantie).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readTacheBaux(piNumeroMandat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheBaux.p").
        run getListeBaux in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, {&TYPECONTRAT-bail}, output table ttTacheBaux).
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readTacheClotureManuelle(piNumeroMandat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheClotureManuelle.p").
        run getClotureManuelle in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttTacheClotureManuelle).
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readTacheBeneficiaire(pcTypeTrt as character, piNumeroMandat as int64, piNumeroIndivisaire as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheBeneficiaire.p").
        case pcTypeTrt:
            when "COMBO" then run initComboBeneficiaire in ghProc(output table ttCombo).
            otherwise         run getBeneficiaire       in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, piNumeroIndivisaire, output table ttTacheBeneficiaire).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readTacheTva(pcTypeTrt as character, piNumeroMandat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheTva.p").
        case pcTypeTrt:
            when "INITIALISATION" then run initTva      in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttTacheTva, output table ttProrataParExercice).
            when "COMBO"          then run initComboTva in ghProc(output table ttCombo).
            otherwise                  run getTva       in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttTacheTva, output table ttProrataParExercice).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readTacheISF(pcTypeTrt as character, piNumeroMandat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheISF.p").
        case pcTypeTrt:
            when "INITIALISATION" then run initISF      in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttTacheISF).
            when "COMBO"          then run initComboISF in ghProc(output table ttCombo).
            otherwise                  run getISF       in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttTacheISF, output table ttSoldeProprietaireISF, output table ttRecapEmpruntISF).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.
    method private logical readTacheIRF(pcTypeTrt as character, piNumeroMandat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheIRF.p").
        case pcTypeTrt:
            when "INITIALISATION" then run initIRF      in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttTacheIRF).
            when "COMBO"          then run initComboIRF in ghProc(output table ttCombo).
            otherwise                  run getIRF       in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttTacheIRF).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.
    method private logical readTacheEclatEnc(pcTypeTrt as character, piNumeroMandat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheEclatEnc.p").
        case pcTypeTrt:
            when "INITIALISATION" then run initEclatEnc      in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttTacheEclatEnc, output table ttFamilleRubriqueQuitt, output table ttSousFamilleRubriqueQuitt).
            when "COMBO"          then run initComboEclatEnc in ghProc(output table ttCombo).
            otherwise                  run getEclatEnc       in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttTacheEclatEnc, output table ttFamilleRubriqueQuitt, output table ttSousFamilleRubriqueQuitt).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readTacheCleRepartition(pcTypeTrt as character, piNumeroMandat as int64, phbuffer as handle):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vcNatureCle as character no-undo.

        ghProc = outilHandle:connectMaGIModele("tache/tacheCleRepartition.p").
        if phBuffer:available then vcNatureCle = phBuffer::cNatureCle no-error.
        case pcTypeTrt:
            when "INITIALISATION"  then run initEclatEnc            in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttTacheEclatEnc, output table ttFamilleRubriqueQuitt, output table ttSousFamilleRubriqueQuitt).
            when "COMBO"           then run initComboCleRepartition in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttCombo,  output table ttClemi).
            when "COMBOLIBELLECLE" then run initComboLibelleCle     in ghProc(vcNatureCle, output table ttCombo).
            when "AUTORISATION"    then do:
                run initAutorisation in ghProc(vcNatureCle, output table-handle ghttAutorisation).
                run getErrors        in ghProc(output table-handle ghttError).
            end.
            otherwise                   run getCleRepartition       in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttTacheCleRepartition, output table ttCleRepartition, output table ttDetailCle).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readTacheEmpruntISF(pcTypeTrt as character, piNumeroMandat as int64, phbuffer as handle):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable viAnnee       as integer no-undo.
        define variable viNumeroTache as integer no-undo.

        ghProc = outilHandle:connectMaGIModele("tache/tacheEmpruntISF.p").
        if phBuffer:available then do:
            viAnnee       = phBuffer::iAnnee       no-error.
            viNumeroTache = phBuffer::iNumeroTache no-error.
        end.
        case pcTypeTrt:
            when "INITIALISATION" then run initEmpruntISF      in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttTacheISF).
            when "COMBO"          then run initComboEmpruntISF in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttCombo).
            otherwise run getEmpruntISF in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, viAnnee, viNumeroTache, output table ttTacheEmpruntISF, output table ttEmpruntISFAnnee).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.
    method private logical readTacheTvaEdi(pcTypeTrt as character, piNumeroMandat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheTvaEdi.p").
        case pcTypeTrt:
            when "INITIALISATION" then run initTvaEdi      in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttTacheTvaEdi).
            when "COMBO"          then run initComboTvaEdi in ghProc(output table ttCombo).
            otherwise                  run getTvaEdi       in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttTacheTvaEdi).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readTacheService(pcTypeTrt as character, piNumeroMandat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheService.p").
        case pcTypeTrt:
            when "INITIALISATION" then run initService in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttTacheService, output table ttListeService).
            otherwise                  run getService  in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttTacheService, output table ttListeService).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readTacheUniteLocation(pcTypeTrt as character, piNumeroMandat as int64, piNumeroUL as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheUniteLocation.p").
        case pcTypeTrt:
            when "COMBO"            then run initComboUniteLocation     in ghProc(output table ttCombo).
            when "HISTOCOMPOSITION" then run getHistoriqueCompositionUL in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, piNumeroUL, output table ttUniteLocation, output table ttCompositionUnite).
            otherwise                    run getUniteLocation           in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttUniteLocation, output table ttCompositionUnite).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readParamBaseRubrique(pcTypeTrt as character, vcListeBaseCalcul as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/paramBaseRubrique.p").
        run getParamBaseRubrique in ghProc(pcTypeTrt, {&TYPETACHE-Honoraires}, vcListeBaseCalcul, output table ttBaseCalcul, output table ttFamilleRubrique, output table ttRubrique).
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readTacheHonoraire(pcTypeTrt as character, phbuffer as handle) :
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable viNumeroContrat as int64     no-undo.
        define variable vcTypeHonoraire as character no-undo.
        define variable vlCreation      as logical   no-undo.
        define variable vcCodeNature    as character no-undo.
        define variable viCodeHonoraire as integer   no-undo.

        ghProc = outilHandle:connectMaGIModele("tache/tacheHonoraire.p").
        if phBuffer:available then do:
            viNumeroContrat      = phBuffer::iNumeroContrat no-error.
            vcTypeHonoraire      = phBuffer::cTypeHonoraire no-error.
            vlCreation           = phBuffer::lCreation      no-error.
            vcCodeNature         = phBuffer::cCodeNature    no-error.
            viCodeHonoraire      = phbuffer::iCodeHonoraire no-error.
        end.
        case pcTypeTrt:
            when "INITIALISATION"     then run initHonoraire             in ghProc(viNumeroContrat, {&TYPECONTRAT-mandat2Gerance}, output table ttBaremeHonoraire).
            when "COMBO"              then run initComboHonoraire        in ghProc(viNumeroContrat, {&TYPECONTRAT-mandat2Gerance}, output table ttCombo).
            when "COMBOPARTYPEHONO"   then run initComboParTypeHonoraire in ghProc(viNumeroContrat, {&TYPECONTRAT-mandat2Gerance}, vcTypeHonoraire, output table ttCombo).
            when "COMBOTYPEHONO"      then run comboTypeHonoraire        in ghProc(viNumeroContrat, {&TYPECONTRAT-mandat2Gerance}, vcTypeHonoraire, output table ttCombo).
            when "CHAMPSSAISISSABLE"  then run getChampsSaisissable      in ghProc(vlCreation, vcTypeHonoraire, vcCodeNature, output table ttChampsSaisissable).
            when "HONORAIRECALCULEUL" then run getHonoraireCalculeUL     in ghProc(viNumeroContrat, vcTypeHonoraire, output table ttHonoraireCalculeUL).
            otherwise                      run getHonoraire              in ghProc(viNumeroContrat, {&TYPECONTRAT-mandat2Gerance}, vcTypeHonoraire, viCodeHonoraire, output table ttBaremeHonoraire, output table ttHonoraireUL).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readBaremeHonoraire(pcTypeTrt as character, phbuffer as handle) :
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable viCodeHonoraire      as integer   no-undo initial ?.  // init ? pour gérer le code 0
        define variable viNumeroHonoraire    as integer   no-undo.
        define variable vcTypeHonoraire      as character no-undo.
        define variable vcCodeNature         as character no-undo.
        define variable vcCodebaseCalcul     as character no-undo.
        define variable viCodeIndiceRevision as integer   no-undo.
        define variable vlCreation           as logical   no-undo.
        define variable vlDateApplication    as logical   no-undo.
        define variable vlTranche            as logical   no-undo.

        ghProc = outilHandle:connectMaGIModele("tache/baremeHonoraire.p").
        if phBuffer:available then do:
            viCodeHonoraire      = phBuffer::iCodeHonoraire      no-error.
            viNumeroHonoraire    = phBuffer::iNumeroHonoraire    no-error.
            vcTypeHonoraire      = phBuffer::cTypeHonoraire      no-error.
            vcCodeNature         = phBuffer::cCodeNature         no-error.
            vcCodeBaseCalcul     = phBuffer::cCodeBaseCalcul     no-error.
            viCodeIndiceRevision = phBuffer::iCodeIndiceRevision no-error.
            vlcreation           = phBuffer::lCreation           no-error.
            vlTranche            = phBuffer::lTranche            no-error.
            vlDateApplication    = phBuffer::lDateApplication    no-error.
        end.
        case pcTypeTrt:
            when "ARTICLE"               then run getArticle            in ghProc(vcTypeHonoraire, output table ttFamilleArticle, output table ttSousFamilleArticle, output table ttArticle).
            when "DERNIERINDICEREVISION" then run getListeDernierIndice in ghProc(viCodeIndiceRevision, output table ttCombo).
            when "INITIALISATION"        then run initBareme            in ghProc(vcTypeHonoraire, output table ttBaremeHonoraire).
            when "COMBO"                 then run initComboBareme       in ghProc({&TYPECONTRAT-mandat2Gerance}, output table ttCombo).
            when "CHAMPSSAISISSABLE"     then run getChampsSaisissable  in ghProc(vlCreation, vcTypeHonoraire, vcCodeNature, vcCodeBaseCalcul, viCodeHonoraire, output table ttChampsSaisissable).
            otherwise run getBaremeHonoraire in ghProc(vcTypeHonoraire, viNumeroHonoraire, viCodeHonoraire, {&TYPECONTRAT-mandat2Gerance}, vlDateApplication, vlTranche, output table ttBaremeHonoraire, output table ttTranche).
        end case.
        run getErrors in ghProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    method private logical readParamUsages():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/paramUsagesUL.p").
        run getUsageUL in ghProc(output table ttUsageUL, output table ttCorrespondanceUsageNatureUL).
        run getErrors  in ghProc(output table ttError).
    end method.

    method private logical readTacheRefacturationDepense(piNumeroMandat as int64, pcTypeTrt as character, phBuffer as handle):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vlCommercialUniquement as logical   no-undo. // Commercial et professionnel uniquement
        define variable vcCodeActif            as character no-undo. // A = Actif, R = Resilie, T = Tous

        ghProc = outilHandle:connectMaGIModele("tache/tacheRefacturationDepense.p").
        if phBuffer:available then do:
            vlCommercialUniquement = phBuffer::lCommercialUniquement no-error.
            vcCodeActif            = phBuffer::cCodeActif            no-error.
        end.
        case pcTypeTrt:
            when "COMBO"   then run initComboTacheRefacturationDepense in ghProc(output table ttCombo).
            when "EDITION" then run getEdRefacturationDepense          in ghProc(piNumeroMandat, vlCommercialUniquement, vcCodeActif, output table ttEdRefacturationDepense).
            otherwise           run getTacheRefacturationDepense       in ghProc(piNumeroMandat, output table ttTacheRefacturationDepense, output table ttRefacturationRubrique, output table ttRefacturationLocataire).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readTachePNO(piNumeroMandat as int64, pcTypeTrt as character, phBuffer as handle) :
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vcGereParCabinetMandat as character no-undo. // A = Actif, R = Resilie, T = Tous

        ghProc = outilHandle:connectMaGIModele("tache/tachePNO.p").
        if phBuffer:available
        then vcGereParCabinetMandat = phBuffer::cGereParCabinetMandant no-error.
        case pcTypeTrt:
            when "COMBO" then run initComboTachePNO in ghProc(output table ttGarantie, output table ttBareme).
            otherwise         run getTachePNO       in ghProc(piNumeroMandat, vcGereParCabinetMandat, output table ttTachePNO, output table ttlotPNO).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readTacheCrg(piNumeroMandat as int64, pcTypeTrt as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheCrg.p").
        case pcTypeTrt:
            when "INITIALISATION" then run initTacheCrg      in ghProc(piNumeroMandat, pcTypeTrt, output table ttTacheCrg).
            when "COMBO"          then run initComboTacheCrg in ghProc(output table ttCombo).
            otherwise                  run getTacheCrg       in ghProc(piNumeroMandat, output table ttTacheCrg, output table ttDocumentsCRG, output table ttCalendrierCRG).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readTacheSigle(piNumeroMandat as int64, pcTypeTrt as character, pcCodeTypeSigle as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheSigle.p").
        case pcTypeTrt:
            when "INITIALISATION" then run initTacheSigle      in ghProc(piNumeroMandat, output table ttTacheSigle).
            when "COMBO"          then run initComboTacheSigle in ghProc(pcCodeTypeSigle, output table ttCombo).
            when "SIGLES"         then run initSigles          in ghProc(piNumeroMandat, output table ttSigle).
            otherwise                  run getTacheSigle       in ghProc(piNumeroMandat, output table ttTacheSigle).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readTacheAcomptes(piNumeroMandat as int64, pcTypeTrt as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheAcomptes.p").
        case pcTypeTrt:
            when "COMBO"        then run initComboTacheAcomptes in ghProc(output table ttCombo).
            when "ECHEANCIER"   then run getEcheancierAcomptes  in ghProc(piNumeroMandat, output table ttTacheAcomptes, output table ttEcheancierAcomptes).
            when "PARAMETRAGE"  then run getParametrageAcomptes in ghProc(piNumeroMandat, output table ttTacheAcomptes, output table ttParametrageAcomptes).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readTacheCrl(piNumeroMandat as int64, pcTypeTrt as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheCrl.p").
        case pcTypeTrt:
            when "INITIALISATION" then run initCrl      in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttTacheCrl).
            when "COMBO"          then run initComboCrl in ghProc(output table ttCombo).
            otherwise                  run getCrl       in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttTacheCrl).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readTachePaiePegase(piNumeroMandat as int64, pcTypeTrt as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhOrgSociaux as handle no-undo.
        ghProc = outilHandle:connectMaGIModele("tache/tachePaiePegase.p").
        case pcTypeTrt:
            when "COMBO" then run initCombo in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttCombo).
            otherwise do:
                run getPaiePegase in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttTachePaiePegase).
                run getErrors in ghProc(output table ttError).
                if not can-find(first ttError where ttError.iType >= {&error})
                then do:
                    vhOrgSociaux = outilHandle:connectMaGIModele("adb/paie/organismesSociauxPegase.p").
                    run getOrgSociauxMandat in vhOrgSociaux(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttOrganismeSociauxPegase).
                    run getErrors in vhOrgSociaux(output table ttError).
                end.
            end.
        end case.
    end method.

    method private logical readTachePaiePegaseEmployeImm(piNumeroMandat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("adb/paie/paiePegaseEmployeImmeuble.p").
        run getPaiePegaseEmployeImmeuble in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttEtablissementPaie, output table ttSalariePegase, output table ttAdresse, output table ttMoyenCommunication).
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readTacheDas2(piNumeroMandat as int64, pcTypeTrt as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheDas2.p").
        case pcTypeTrt:
            when "INITIALISATION" then run initTacheDas2 in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, pcTypeTrt, output table ttTacheDas2).
            otherwise                  run getTacheDas2  in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttTacheDas2).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readTacheAssurancesLoyer(piNumeroMandat as int64, pcTypeTrt as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheAssurancesLoyer.p").
        case pcTypeTrt:
            when "INITIALISATION" then run initTacheAssurancesLoyer      in ghProc(piNumeroMandat, pcTypeTrt, output table ttTacheAssurancesLoyer).
            when "COMBO"          then run initComboTacheAssurancesLoyer in ghProc(output table ttCombo).
            otherwise                  run getTacheAssurancesLoyer       in ghProc(piNumeroMandat, output table ttTacheAssurancesLoyer).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readTacheChargeLocativePrestation(pcTypeTrt as character, piNumeroMandat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheChargeLocative.p").
        case pcTypeTrt:
            when "INITIALISATION" then run initChargeLocative      in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttTacheChargeLocative, output table ttRubriqueChargeLocative).
            when "COMBO"          then run initComboChargeLocative in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttCombo, output table ttCleChargeLocative).
            otherwise                  run getChargeLocative       in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttTacheChargeLocative, output table ttRubriqueChargeLocative).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.
    method private logical readTacheReleve(piNumeroMandat as int64, pcTypeTrt as character, pcTypeCompteur as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheReleve.p").
        case pcTypeTrt:
            when "INITIALISATION" then run initCompteurPrix in ghProc({&TYPECONTRAT-mandat2Gerance}, piNumeroMandat, pcTypeCompteur, output table ttTacheReleve, output table ttListeCompteur).
            otherwise                  run getCompteurPrix  in ghProc({&TYPECONTRAT-mandat2Gerance}, piNumeroMandat, pcTypeCompteur, output table ttTacheReleve, output table ttListeCompteur).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readTacheTaxeBureau(pcTypeTrt as character, piAnnee as integer, piNumeroMandat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheTaxeBureau.p").
        case pcTypeTrt:
            when "COMBO" then run initComboTaxeBureau in ghProc(output table ttCombo).
            otherwise         run getTaxeBureau       in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, piAnnee, output table ttTacheTaxeBureau, output table ttULTaxeBureau, output table ttSurfaceTaxeBureau).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readListeImputationParticuliere(piNumeroMandat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/imputationParticuliere.p").
        run getListeImputationParticuliere in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance},{&TYPETACHE-ImputParticuliereGerance}, 0, "ENCOU", output table ttImputationParticuliere,output table ttLigneImputationParticuliere).
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readTacheLoiDefiscalisationIRF(pcTypeTrt as character, piNumeroMandat as int64, pcCodeLoi as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheLoiDefiscalisationIRF.p").
        case pcTypeTrt:
            when "COMBO"  then run initComboLoiDefiscalisationIRF in ghProc(pcCodeLoi, output table ttCombo).
            otherwise          run getLoiDefiscalisationIRF       in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttListeLotLoiDefiscalisationIRF, output table ttDetailLotLoiDefiscalisationIRF).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical readTacheMutation(pcTypeTrt as character, piNumeroMandat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/mutation/listeMutation.p").
        case pcTypeTrt:
            when "HISTO"    then run getUlMutationHisto in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttListeLotMutation, output table ttMutation).
            otherwise            run getUlMutation      in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, output table ttListeLotMutation, output table ttMutation).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateMandat(piNumeroMandat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("mandat/mandat.p").
        run validationMandat in ghProc({&TYPECONTRAT-mandat2Gerance}, piNumeroMandat).
        dataset dsbeMandatGerance:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateObjet(pcTypeTrt as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("mandat/objetMandat.p").
        run setObjet in ghProc(pcTypeTrt, input-output table ttMandatGerance, input-output table ttObjetMandatDescriptifGeneral, table ttError).
        dataset dsbeMandatGerance:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateRoleAnnexe():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("mandat/roleAnnexeContrat.p").
        run setRoleAnnexe in ghProc(table ttRoleAnnexe).
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateRoleContractant():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("mandat/contractantContrat.p").
        run setRoleContractant in ghProc(table ttRoleContractant).
        dataset dsbeMandatGerance:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateIndivisaire(piNumeroMandat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("mandat/indivisaireContrat.p").
        run setIndivisaire in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, table ttIndivisaire).
        dataset dsbeMandatGerance:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateBien(pcTypeTrt as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("mandat/bienContrat.p").
        case pcTypeTrt:
            when "IMMEUBLE" then run setImmeuble in ghProc(table ttMandatGerance).
            otherwise            run setLot      in ghProc(table ttBienMandat).
        end case.
        dataset dsbeMandatGerance:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateNotes(piNumeroMandat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("mandat/commentaireContrat.p").
        run setNotesContrat in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, input-output table ttNotes).
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateTacheDepotGarantie():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheDepotGarantie.p").
        run setDepotGarantie in ghProc(table ttTacheDepotGarantie).
        dataset dsbeMandatGerance:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateTacheClotureManuelle():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheClotureManuelle.p").
        run setClotureManuelle in ghProc(table ttTacheClotureManuelle).
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateTacheTva():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheTva.p").
        run setTva in ghProc(table ttTacheTva, table ttProrataParExercice, table ttError).
        dataset dsbeMandatGerance:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateTacheISF():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheISF.p").
        run setISF in ghProc(table ttTacheISF).
        dataset dsbeMandatGerance:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateTacheIRF():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheIRF.p").
        run setIRF in ghProc(table ttTacheIRF).
        dataset dsbeMandatGerance:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateTacheEclatEnc():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheEclatEnc.p").
        run setEclatEnc in ghProc(table ttTacheEclatEnc, table ttFamilleRubriqueQuitt, table ttSousFamilleRubriqueQuitt).
        dataset dsbeMandatGerance:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateTacheEmpruntISF(pcTypeTrt as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheEmpruntISF.p").
        case pcTypeTrt:
            when "INITANNEE" then run initAnneeEmprunt in ghProc(input-output table ttTacheEmpruntISF, input-output table ttEmpruntISFAnnee, table ttError).
            when "CONTROLE"  then do:
                run verEmpruntISF in ghProc(input table ttTacheEmpruntISF).
                dataset dsbeMandatGerance:empty-dataset().
            end.
            otherwise run setEmpruntISF in ghProc(input-output table ttTacheEmpruntISF, input-output table ttEmpruntISFAnnee).
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateTacheCleRepartition(pcTypeTrt as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheCleRepartition.p").
        case pcTypeTrt:
            /* when "INITANNEE" then run initAnneeEmprunt in ghProc(input-output table ttTacheEmpruntISF, input-output table ttEmpruntISFAnnee, table ttError).*/
            when "CONTROLE" then run verCleRepartition in ghProc(table ttTacheCleRepartition, input-output table ttCleRepartition, input-output table ttDetailCle).
            otherwise            run setCleRepartition in ghProc(table ttTacheCleRepartition, table ttCleRepartition, table ttDetailCle).
        end case.
        dataset dsbeMandatGerance:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateTacheTvaEdi():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheTvaEdi.p").
        run setTvaEdi in ghProc(table ttTacheTvaEdi, table ttError).
        dataset dsbeMandatGerance:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateTacheService():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheService.p").
        run setService in ghProc(table ttTacheService).
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateTacheBeneficiaire():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheBeneficiaire.p").
        run setBeneficiaire in ghProc(table ttTacheBeneficiaire).
        dataset dsbeMandatGerance:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateTacheUniteLocation(pcTypeTrt as character, piNumeroMandat as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheUniteLocation.p").
        case pcTypeTrt:
            when "CONTROLE" then run verUniteLocation in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, table ttUniteLocation, table ttCompositionUnite).
            otherwise            run setUniteLocation in ghProc(piNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, table ttUniteLocation, table ttCompositionUnite).
        end case.
        dataset dsbeMandatGerance:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateParamUsages():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/paramUsagesUL.p").
        run setUsageUL in ghProc(table ttUsageUL, table ttCorrespondanceUsageNatureUL).
        dataset dsbeMandatGerance:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateTacheCrg():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheCrg.p").
        run setTacheCrg in ghProc(table ttTacheCrg, table ttDocumentsCRG, table ttError).
        dataset dsbeMandatGerance:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateTacheSigle():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheSigle.p").
        run setTacheSigle in ghProc(table ttTacheSigle).
        dataset dsbeMandatGerance:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateTacheAcomptes(pcTypeTrt as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheAcomptes.p").
        case pcTypeTrt:
            when "ECHEANCIER"  then run setEcheancierAcomptes  in ghProc(table ttTacheAcomptes, table ttEcheancierAcomptes, table ttError).
            when "PARAMETRAGE" then run setParametrageAcomptes in ghProc(table ttTacheAcomptes, table ttParametrageAcomptes, table ttError).
        end case.
        dataset dsbeMandatGerance:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateTacheCrl():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheCrl.p").
        run setCrl in ghProc(table ttTacheCrl, table ttError).
        dataset dsbeMandatGerance:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateTachePaiePegase():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tachePaiePegase.p").
        run setPaiePegase in ghProc(table ttTachePaiePegase).
        dataset dsbeMandatGerance:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateTacheDas2():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheDas2.p").
        run setTacheDas2 in ghProc(table ttTacheDas2).
        dataset dsbeMandatGerance:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateTacheAssurancesLoyer():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheAssurancesLoyer.p").
        run setTacheAssurancesLoyer in ghProc(table ttTacheAssurancesLoyer, table ttError).
        dataset dsbeMandatGerance:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateChargeLocativePrestation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheChargeLocative.p").
        run setChargeLocative in ghProc(table ttTacheChargeLocative, table ttRubriqueChargeLocative).
        dataset dsbeMandatGerance:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateTaxeBureau():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheTaxeBureau.p").
        run setTaxeBureau in ghProc(table ttTacheTaxeBureau, table ttULTaxeBureau, table ttSurfaceTaxeBureau).
        dataset dsbeMandatGerance:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateLoiDefiscalisationIRF():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheLoiDefiscalisationIRF.p").
        run setLoiDefiscalisationIRF in ghProc({&TYPECONTRAT-mandat2Gerance}, table ttListeLotLoiDefiscalisationIRF, table ttDetailLotLoiDefiscalisationIRF, table ttError).
        dataset dsbeMandatGerance:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateTacheMutation(pcTypeTrt as character, pcTypeUL as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        case pcTypeTrt:
            when "validation" then do:
                ghProc = outilHandle:connectMaGIModele("tache/mutation/validationMutation.p").
                run validationMutation in ghProc(pcTypeUL, "", table ttListeLotMutation, table ttMutation, table ttError).
            end.
            otherwise do:
                ghProc = outilHandle:connectMaGIModele("tache/mutation/listeMutation.p").
                run setMutation in ghProc(table ttListeLotMutation, table ttMutation, table ttError).
            end.    
        end case.
        dataset dsbeMandatGerance:empty-dataset().
        run getErrors      in ghProc(output table ttError).
        run getListeErreur in ghProc(output table ttListeErreur).
    end method.

    method private logical updateParamBaseRubrique():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/paramBaseRubrique.p").
        run updateParamBaseRubrique in ghProc({&TYPETACHE-Honoraires}, input table ttBaseCalcul, input table ttFamilleRubrique, input table ttRubrique).
        dataset dsbeMandatGerance:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateBaremeHonoraire(pcTypeTrt as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/baremeHonoraire.p").
        case pcTypeTrt:
            when "CONTROLE" then run getControleBareme in ghProc(input-output table ttBaremeHonoraire, input-output table ttTranche).
            otherwise do:
                run updateBaremeHonoraire in ghProc(input table ttBaremeHonoraire, input table ttTranche).
                dataset dsbeMandatGerance:empty-dataset().
            end.
        end case.
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateTacheHonoraire(pcTypeTrt as character, phbuffer as handle):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable viNumeroContrat as int64     no-undo.
        define variable vcTypeHonoraire as character no-undo.
        define variable viCodeHonoraire as int64     no-undo.

        ghProc = outilHandle:connectMaGIModele("tache/tacheHonoraire.p").
        if phBuffer:available then do:
            viNumeroContrat = phBuffer::iNumeroContrat no-error.
            vcTypeHonoraire = phBuffer::cTypeHonoraire no-error.
            viCodeHonoraire = phBuffer::iCodeHonoraire no-error.
        end.
        case pcTypeTrt :
            when "CONTROLE"      then run getControleTache in ghProc(viNumeroContrat,  {&TYPECONTRAT-mandat2Gerance}, input-output table ttBaremeHonoraire).
            when "AFFECTEBAREME" then run affecteNewBareme in ghProc(viNumeroContrat,  {&TYPECONTRAT-mandat2Gerance}, vcTypeHonoraire, viCodeHonoraire, input-output table ttBaremeHonoraire, input-output table ttHonoraireUL).
            otherwise do :
                run setTacheHonoraire in ghProc(viNumeroContrat, {&TYPECONTRAT-mandat2Gerance}, input table ttBaremeHonoraire, input table ttHonoraireUL, input table ttError).
                dataset dsbeMandatGerance:empty-dataset().
            end.
        end case.
        run getErrors in ghProc(output table ttError).
        {outils/include/tryCatch.i}
    end method.

    method private logical updateTacheRefacturationDepense(pcTypeTrt as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheRefacturationDepense.p").
        case pcTypeTrt:
            when "CONTROLE" then run getControleTacheRefacturationDepense in ghProc(
                table ttTacheRefacturationDepense,
                table ttRefacturationRubrique,
                table ttRefacturationLocataire).
            otherwise run updateTacheRefacturationDepense in ghProc(
                table ttTacheRefacturationDepense,
                table ttRefacturationRubrique,
                table ttRefacturationLocataire,
                table ttError).
        end case.
        dataset dsbeMandatGerance:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateTacheReleve():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tacheReleve.p").
        run setTacheReleve in ghProc(table ttTacheReleve, table ttListeCompteur).
        dataset dsbeMandatGerance:empty-dataset().
        run getErrors in ghProc(output table ttError).
    end method.

    method private logical updateTachePNO(pcTypeTrt as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        ghProc = outilHandle:connectMaGIModele("tache/tachePNO.p").
        case pcTypeTrt:
            when "CALCUL" then run getCalculCotisation in ghProc(table ttTachePNO, table ttError, input-output table ttLotPNO).
            otherwise do :
                run updateTachePNO in ghProc(table ttTachePNO, table ttLotPNO).
                dataset dsbeMandatGerance:empty-dataset().
            end.
        end case.

        run getErrors in ghProc(output table ttError).
    end method.

    destructor public beMandatGerance():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().
    end destructor.

end class.
