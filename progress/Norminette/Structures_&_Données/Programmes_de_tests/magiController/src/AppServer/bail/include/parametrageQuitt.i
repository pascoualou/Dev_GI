/*------------------------------------------------------------------------
File        : parametrageQuitt.i
Purpose     :
Author(s)   : gga - 2018/06/22
Notes       :
derniere revue: 2018/07/28 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttParametrageQuitt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeContrat                 as character     /* code Type du contrat          */
    field iNumeroContrat               as int64         /* Numero du contrat             */
    field daEntree                     as date          // HwDatApp
    field daFin                        as date          // HwDatFin
    field daResiliationContrat         as date
    field daRenouvellementContrat      as date
    field cCodePeriodicite             as character     // HwPerQtt    CdPerQtt
    field cCodeTerme                   as character     // HwTerQtt    CdTerQtt
    field daPremiereQuittanceGI        as date
    field iMoisAvanceEmissionQuittance as integer       // HwDtaQav
    field cCodeModeReglement           as character     /* Code du mode de règlement     */
    field iJourPrelevement             as integer       // HwCmbJou
    field cMoisPrelevement             as character     // HwCmbMsp seulement cleint 3028 et 3062
    field cBanquePrelevement           as character
    field cInfoBanquePrelevement       as character     // HwTxtCpt
    field cCodeRUM                     as character     /* Code RUM                      */
    field daSignatureMandatSepa        as date          /* Date de signature             */
    field iNumeroMPrelSEPA             as integer
    field lDepotGarantie               as logical initial ?
    field cRepriseSolde                as character     // HwRepSol
    field lReglementDirectAuProp       as logical
    field iNumeroTexte                 as integer
    field cCodeEdition                 as character
    field cModeEnvoi                   as character
    field iMandatCompensation          as integer
    field cCollectifCompensation       as character
    field cCompteCompensation          as character
    field cSousCompteCompensation      as character

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
