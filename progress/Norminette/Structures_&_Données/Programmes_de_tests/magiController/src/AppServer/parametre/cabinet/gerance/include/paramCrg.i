/*------------------------------------------------------------------------
File        : paramCrg.i
Purpose     : 
Author(s)   : OF  -  05/10/2017
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttParamCrg
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeTache                      as character initial ?
    field lParametrageActif               as logical   initial ?
    field lActivation                     as logical   initial ?
    field lAutomatique                    as logical   initial ?
    field cCodePresentationCrg            as character initial ?  //HwDtaReg
    field cLibellePresentationCrg         as character initial ?  //HwDtaReg
    field cCodePeriodicite                as character initial ?  //HwDtaFre
    field cLibellePeriodicite             as character initial ?  //HwDtaFre
    field cCodeTraitementAvisEcheance     as character initial ?  //HwDtaTrt
    field cLibelleTraitementAvisEcheance  as character initial ?  //HwDtaTrt
    field lPresentationDetailCalculHono   as logical   initial ?  //HwCmbDet    HwCmbHon
    field cCodeClassementCrg              as character initial ?  //HwCmbCls
    field cLibelleClassementCrg           as character initial ?  
    field cCodeTypeEdition                as character initial ?  //HwDtaEdi    HwCmbMod
    field cLibelleTypeEdition             as character initial ?  //HwDtaEdi
    field lGenererOdrtFinPeriode          as logical   initial ?  //HwCmbasm
    field lPresentationFactureLocataire   as logical   initial ?  //HwCmbFac
    field lPresentationDetailCalculHono-2 as logical   initial ?  //HwCmbDet    HwCmbHon
    field lPresentationJustifBaseHonFac   as logical   initial ?  //HwCmbJus
    field lDetailHonoraireMensuel         as logical   initial ?  //HwCmbDet
    field lTrimesDecalePartielFinAnnee    as logical   initial ?  //HwCmbSpe
    field lEditerDgSiResultantEgal0       as logical   initial ?  //HwCmbDG0
    field lEditerCoordonnesGestionnaire   as logical   initial ?  //HwCmbGes
    field lReleveRecapitulatifFinAnnee    as logical   initial ?  //HwCmbRec
    field cTriDetailSituationProp         as character initial ?  //HwCmbTri
    field cLibTriDetailSituationProp      as character initial ?  //HwCmbTri
    field cRegroupementEncaissement       as character initial ?  //HwCmbReg
    field cLibRegroupementEncaissement    as character initial ?  //HwCmbReg
    field lEditerSituationLocataire       as logical   initial ?  //HwCmbLoc
    field cCodeScenarioPresentation       as character initial ?  //HwDtaPr1    HwCmbSce
    field cLibelleScenarioPresentation    as character initial ?  
    field lCrgLibre                       as logical   initial ?  //HwDtaCal    HwCmbas2 
    field lAffichCrgLibre                 as logical   initial ?  
    field lProvisionPermanente            as logical   initial ?  //HwCmbPro    HwCmbProv
    field cLibelleProvisionPermanente     as character initial ?  //HwLibProv
    field cCodeEditionFacture             as character initial ?  //HwDtaFac        //HwCmbEdF 
    field cLibelleEditionFacture          as character initial ?  
    field lEditionDuplicata               as logical   initial ?  //HwCmbDup
    field lRegroupementGarantieLoyer      as logical   initial ?  //HwCmbGar
    field cEdSitCompteProprietaire        as character initial ? //HwCmbLet
    field cLibEdSitCompteProprietaire     as character initial ? 
    field cPeriodeTitreDocument           as character initial ? //HwCmbPrd 
    field cLibPeriodeTitreDocument        as character initial ? 
    field lRecapRubriqueVentilEncais      as logical   initial ? //HwCmbRub
    field lTotMandatVentilEncais          as logical   initial ? //HwCmbTMd
    field lTotMandantVentilEncais         as logical   initial ? //HwCmbTMa
    field lEdTvaEncais                    as logical   initial ? //HwCmbTve
    field lEdTvaDepenseSurCrgSimplifie    as logical   initial ? //HwCmbTvs
    field lTotSousTitreSurCrg             as logical   initial ? //HwCmbSsT
    field lEdSoldePropPartiSurPgIndex     as logical   initial ? //HwCmbSld
    field lEdVentilParMandat              as logical   initial ? //HwCmbVma  

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
define temp-table ttParamCrgSelectionDocument no-undo
    field iNumeroOrdre    as integer   initial ?
    field cCodeDocument   as character initial ?
    field cNomDocument    as character initial ?
    field lEditionCabinet as logical   initial ?
.
define temp-table ttParamCrgListeCrgSimplifie no-undo
    field iNumeroContrat as int64     initial ?
    field cNomMandant    as character initial ?
    field lSelection     as logical   initial ?
    field iNumeroTache   as int64     initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
index idxNumeroContrat iNumeroContrat 
.
define temp-table ttParamCrgSuiviTrt no-undo
    field lReportRecapAnnuel  as logical initial ?
    field lReportSelectionDoc as logical initial ?
.
