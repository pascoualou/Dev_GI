/*------------------------------------------------------------------------
File        : tacheUniteLocation.i
Purpose     : 
Author(s)   : GGA  -  2017/08/17
Notes       :
derneire revue: 2018/05/16 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheUniteLocation
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroTache       as int64     initial ?
    field cTypeContrat       as character initial ?
    field iNumeroContrat     as int64     initial ?
    field cTypeTache         as character initial ?
    field iChronoTache       as integer   initial ?
    field iNumeroUL          as integer   initial ?
    field iNumeroComposition as integer   initial ?
    field daDebut            as date

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
