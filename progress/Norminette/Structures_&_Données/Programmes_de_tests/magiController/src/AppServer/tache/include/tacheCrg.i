/*------------------------------------------------------------------------
File        : tacheCrg.i
Purpose     : 
Author(s)   : OF  -  05/10/2017
Notes       :
derneire revue: 2018/05/16 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheCrg
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroTache                   as int64     initial ?
    field cTypeContrat                   as character initial ?
    field iNumeroContrat                 as int64     initial ?
    field cCodeTypeRole                  as character initial ?
    field iNumeroRole                    as integer   initial ?
    field iNumeroTiers                   as integer   initial ?
    field cTypeTache                     as character initial ?
    field iChronoTache                   as integer   initial ?
    field lIndivision                    as logical   initial ?
    field daActivation                   as date                 //HwDtaDtd
    field cCodePresentationCrg           as character initial ?  //HwDtaReg
    field cLibellePresentationCrg        as character initial ?  //HwDtaReg
    field cCodePeriodicite               as character initial ?  //HwDtaFre
    field cLibellePeriodicite            as character initial ?  //HwDtaFre
    field lPresentationDetailCalculHono  as logical   initial ?  //HwCmbDet
    field iBordereauConcierge            as integer   initial ?  //HwDtaBor
    field lRepartitionTerme              as logical   initial ?  //HwDtaRep
    field cCodeTypeEdition               as character initial ?  //HwDtaEdi
    field cLibelleTypeEdition            as character initial ?  //HwDtaEdi
    field cCodeScenarioParamRubCRG123    as character initial ?  //HwCmb123
    field cLibelleScenarioParamRubCRG123 as character initial ?  //HwCmb123
    field lTriReleveQuittParBat          as logical   initial ?  //HwCmbTriBat
    field cCodeTraitementAvisEcheance    as character initial ?  //HwDtaTrt
    field cLibelleTraitementAvisEcheance as character initial ?  //HwDtaTrt
    field iNumeroRoleGardien             as integer   initial ?  //HwDtaGar
    field cNomGardien                    as character initial ?  //HwNomGar
    field cCodeMode2Reglement            as character initial ?  //HwDtaMdr
    field cLibelleMode2Reglement         as character initial ?  //HwDtaMdr
    field cIban                          as character initial ?  //HwLibBqu
    field cBic                           as character initial ?  //HwLibBqu
    field cTitulaire                     as character initial ?  //HwLibBqu
    field cDomiciliation                 as character initial ?  //HwLibBqu
    field cCodeModeEnvoi                 as character initial ?  //HwCmbMad
    field cLibelleModeEnvoi              as character initial ?  //HwCmbMad
    field cCodeEditionFacture            as character initial ?  //HwDtaFac
    field cLibelleEditionFacture         as character initial ?  //HwDtaFac
    field cListeDocuments                as character initial ?  //HwBrwDoc
    field cCodeLieuEditionDocument       as character initial ?  //HwDtaDoc
    field cLibelleLieuEditionDocument    as character initial ?  //HwDtaDoc
    field lCrgLibre                      as logical   initial ?  //HwDtaCal
    field lAccesCRGLibre                 as logical   initial ?  
    field lEditionSituationLocataire     as logical   initial ?  //HwDtaLoc
    field cCodeScenarioPresentation      as character initial ?  //HwDtaPr1
    field cLibelleScenarioPresentation   as character initial ?  //HwDtaPr1
    field lEditionHtTva                  as logical   initial ?  //HwCmbHtc
    field lCrgSimplifie                  as logical   initial ?  //HwCmbSpf
    field lProvisionPermanente           as logical   initial ?  //HwCmbPro
    field dMontantProvisionPermanente    as decimal   initial ?  //HwMtProv
    field cLibelleProvisionPermanente    as character initial ?  //HwMtProv
    field lRecapitulatifAnnuel           as logical   initial ?  //HwCmbAnn
    field lGiExtranetOuvert              as logical   initial ?
    field lGiExtranetTiersActif          as logical   initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
&if defined(nomTableDocument)   = 0 &then &scoped-define nomTableDocument ttDocumentsCRG
&endif
&if defined(serialNameDocument) = 0 &then &scoped-define serialNameDocument {&nomTableDocument}
&endif
define temp-table {&nomTableDocument} no-undo serialize-name '{&serialNameDocument}'
    field cTypeContrat    as character initial ?
    field iNumeroContrat  as int64     initial ? // zéro pour le paramétrage cabinet
    field iNumeroOrdre    as integer   initial ?
    field cCodeDocument   as character initial ?
    field cNomDocument    as character initial ?
    field lEditionMandat  as logical   initial ?
    field lEditionCabinet as logical   initial ?
.
&if defined(nomTableCalendrier) = 0 &then &scoped-define nomTableCalendrier ttCalendrierCRG
&endif
&if defined(serialNameCalendrier) = 0 &then &scoped-define serialNameCalendrier {&nomTableCalendrier}
&endif
define temp-table {&nomTableCalendrier} no-undo serialize-name '{&serialNameCalendrier}'
    field iNumeroCrg     as integer  initial ?
    field daDateDebutCrg as date
    field daDateFinCrg   as date
.
