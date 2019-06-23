/*------------------------------------------------------------------------
File        : ichroatt.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIchroatt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field bque       as character  initial ? 
    field chrono-num as integer    initial ? 
    field cpt        as character  initial ? 
    field etab-cd    as integer    initial ? 
    field fg-util    as logical    initial ? 
    field guichet    as character  initial ? 
    field soc-cd     as integer    initial ? 
    field type-cd    as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
