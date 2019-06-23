/*-----------------------------------------------------------------------------
File        : tacheAcomptes.i
Purpose     : Définition dataset tache acomptes propriétaires et mandat (04342)
Author(s)   : OFA  -  2017/10/31
Notes       : 
derneire revue: 2018/05/16 - phm: OK
-----------------------------------------------------------------------------*/
define temp-table ttTacheAcomptes no-undo
    field cTypeContrat        as character initial ?
    field iNumeroContrat      as int64     initial ?
    field iNumeroProprietaire as integer   initial ?
    field iNumerateur         as integer   initial ?
    field iDenominateur       as integer   initial ?
    field cNomProprietaire    as character initial ?
    field cPeriodiciteCrg     as character initial ?
    field cIbanProprietaire   as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
define temp-table ttEcheancierAcomptes no-undo
    field cTypeContrat        as character initial ?
    field iNumeroContrat      as int64     initial ?
    field cCodeTypeAcompte    as character initial ?
    field cLibelleTypeAcompte as character initial ?
    field cCodeTypeRole       as character initial ?
    field iNumeroProprietaire as integer   initial ?
    field iMoisEcheance       as integer   initial ?
    field iJourEcheance       as integer   initial ?
    field cMoisEcheance       as character initial ?
    field lForfait            as logical   initial ?
    field dMontantForfait     as decimal   initial ?
    field dTaux               as decimal   initial ?
    field lVirement           as logical   initial ?
    field cModeCreation       as character initial ?
.
define temp-table ttParametrageAcomptes no-undo
    field cTypeContrat        as character initial ?
    field iNumeroContrat      as int64     initial ?
    field cCodeTypeAcompte    as character initial ?
    field cLibelleTypeAcompte as character initial ?
    field cCodeTypeRole       as character initial ?
    field iNumeroProprietaire as integer   initial ?
    field iNumeroAcompte      as integer   initial ?
    field iNumeroMois         as integer   initial ?
    field cLibelleMois        as character initial ?
    field iJourAcompte        as integer   initial ?
    field lForfait            as logical   initial ?
    field dMontantForfait     as decimal   initial ?
    field dTaux               as decimal   initial ?
    field lVirement           as logical   initial ?
.
