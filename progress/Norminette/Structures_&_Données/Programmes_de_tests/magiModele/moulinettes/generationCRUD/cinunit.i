/*------------------------------------------------------------------------
File        : cinunit.i
Purpose     : Unités de valeurs immobilisations ifrs
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCinunit
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field lib     as character  initial ? 
    field lib-abr as character  initial ? 
    field lib-aff as character  initial ? 
    field unit-cd as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
