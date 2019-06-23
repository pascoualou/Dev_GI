/*------------------------------------------------------------------------
File        : trf_pr.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTrf_pr
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdpar as character  initial ? 
    field nome1 as integer    initial ? 
    field nome2 as integer    initial ? 
    field tppar as character  initial ? 
    field zone1 as decimal    initial ?  decimals 2
    field zone2 as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
