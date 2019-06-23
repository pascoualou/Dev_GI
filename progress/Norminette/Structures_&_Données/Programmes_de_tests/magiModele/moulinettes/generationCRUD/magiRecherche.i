/*------------------------------------------------------------------------
File        : magiRecherche.i
Purpose     : Table de recherche pour auto completion.
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttMagirecherche
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cType   as character  initial ? 
    field cValeur as character  initial ? 
    field iCdLng  as int64      initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
