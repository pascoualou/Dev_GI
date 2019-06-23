/*-----------------------------------------------------------------------------
File        : ImputationParticuliere.i
Purpose     : table Imputation Particulière
Author(s)   : RF  -  05/01/2018
Notes       :
derniere revue: 2018/05/16 - phm: OK
-----------------------------------------------------------------------------*/
define temp-table ttImputationParticuliere no-undo serialize-name 'ttImputationParticuliere'
    field cTypeContrat         as character initial ?
    field iNumeroMandat        as integer   initial ?
    field iNumeroImmeuble      as integer   initial ?
    field iNumeroPeriodeCharge as integer   initial ?
    field cLibelleImputation   as character initial ?
    field daDateImputation     as date
    field cCleRecuperation     as character initial ?
    field cCleImputation       as character initial ?
    field cRubrique            as character initial ?
    field cSousRubrique        as character initial ?
    field cCodeFiscalite       as character initial ?
    field cLibellePeriode      as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
define temp-table ttLigneImputationParticuliere no-undo
    field iNumeroMandat       as integer   initial ?
    field iNumeroImmeuble     as integer   initial ?
    field daDateImputation    as date
    field iNumeroLocataire    as integer   initial ?
    field iChronoLocataire    as integer   initial ?
    field cNomLocataire       as character initial ?
    field dMontantTTC         as decimal   initial ?
    field dMontantTVA         as decimal   initial ?
    field cCodeTVA            as character initial ?
    field dTauxTVA            as decimal   initial ?
    field cLibelleImputation  as character initial ? extent 9

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
define temp-table ttLocataire no-undo
    field iNumeroBail      as int64
    field iNumeroLocataire as integer
    field cNomLocataire    as character
.
