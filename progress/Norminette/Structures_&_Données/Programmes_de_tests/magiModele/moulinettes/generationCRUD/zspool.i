/*------------------------------------------------------------------------
File        : zspool.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttZspool
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field client-ip   as character  initial ? 
    field client-port as integer    initial ? 
    field event-cmd   as character  initial ? 
    field event-date  as date       initial ? 
    field event-time  as integer    initial ? 
    field port        as integer    initial ? 
    field statut      as character  initial ? 
    field type        as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
