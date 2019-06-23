/*------------------------------------------------------------------------
File        : trf_pg.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTrf_pg
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdpar as character  initial ? 
    field lbpar as character  initial ? 
    field maxim as integer    initial ? 
    field minim as integer    initial ? 
    field nmprg as character  initial ? 
    field nome1 as integer    initial ? 
    field nome2 as integer    initial ? 
    field rprun as character  initial ? 
    field tppar as character  initial ? 
    field zone1 as character  initial ? 
    field zone2 as character  initial ? 
    field zone3 as character  initial ? 
    field zone4 as character  initial ? 
    field zone5 as character  initial ? 
    field zone6 as character  initial ? 
    field zone7 as character  initial ? 
    field zone8 as character  initial ? 
    field zone9 as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
