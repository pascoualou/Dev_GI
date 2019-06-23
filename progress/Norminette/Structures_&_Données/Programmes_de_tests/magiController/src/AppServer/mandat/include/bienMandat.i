/*------------------------------------------------------------------------
File        : bienMandat.i
Purpose     :
Author(s)   : gga - 2017/08/31
Notes       :
derniere revue: 2018/04/18 - gga : OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttBienMandat 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeContrat     as character initial ?
    field iNumeroContrat   as int64     initial ?
    field iNumeroImmeuble  as integer   initial ?
    field iNumeroBien      as integer   initial ?
    field iNumeroLot       as integer   initial ?
    field cNatureLot       as character initial ?
    field cLibNatureLot    as character initial ?
    field iSfLot           as integer   initial ?
    field cLibre           as character initial ? 
    field cNomOccupant     as character initial ?
    field daEntreeOccupant as character initial ?
    field daSortieOccupant as character initial ?
    field cNatureContrat   as character initial ?
    field cCdModele        as character initial ?

    field dtTimestamp      as datetime
    field CRUD             as character
    field rRowid           as rowid
.
&if defined(nomTableLot)   = 0 &then &scoped-define nomTableLot ttLotDispo 
&endif
&if defined(serialNameLot) = 0 &then &scoped-define serialNameLot {&nomTableLot}
&endif
define temp-table {&nomTableLot} no-undo serialize-name '{&serialNameLot}'
    field cTypeContrat    as character initial ?
    field iNumeroContrat  as integer   initial ?
    field iNumeroImmeuble as integer   initial ? 
    field iNumeroBien     as integer   initial ?
    field iNumeroLot      as integer   initial ?
    field cNatureLot      as character initial ?
    field cLibNatureLot   as character initial ?
    field iSfLot          as integer   initial ?
    field cLibre          as character initial ? 
    field cNatureContrat  as character initial ?
    field cCdModele       as character initial ?

    field dtTimestamp     as datetime
    field CRUD            as character
    field rRowid          as rowid
.
