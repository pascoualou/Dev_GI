/*------------------------------------------------------------------------
File        : tantieme.i
Description : 
Author(s)   : kantena  -  2017/06/08
Notes       :
derniere revue: 2018/05/25 - phm: OK
------------------------------------------------------------------------*/
define temp-table ttCleTantieme no-undo
    field iNumeroImmeuble as integer   initial ?
    field cCodeCle        as character initial ?
    field cCodeBatiment   as character initial ?
    field cLibelleCle     as character initial ?
    field iNombreTantieme as integer   initial ?

    field CRUD        as character
    field dtTimestamp as datetime
    field rRowid      as rowid
.
define temp-table ttTantieme no-undo
    field iNumeroImmeuble as integer   initial ?
    field iNumeroLot      as integer   initial ?
    field cCodeCle        as character initial ?
    field cCodeBatiment   as character initial ?
    field cProprietaire   as character initial ?
    field iNombreTantieme as integer   initial ?

    field CRUD        as character
    field dtTimestamp as datetime
    field rRowid      as rowid
.
define temp-table ttTantiemeLot no-undo
    field iNumeroBien     as int64     initial ?
    field iNumeroMandat   as integer   initial ?
    field iOrdre          as integer   initial ?
    field cCodeCle        as character initial ?
    field cLibelleCle     as character initial ?
    field iNombreTantieme as integer   initial ?
    field dTotalImmeuble  as decimal   initial ?
    field dTotalMandat    as decimal   initial ?

    field CRUD        as character
    field dtTimestamp as datetime
    field rRowid      as rowid
    index primaire iNumeroBien cCodeCle
.
