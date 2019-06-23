/*------------------------------------------------------------------------
File        : trf_it.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTrf_it
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdisp as character  initial ? 
    field lbpth as character  initial ? 
    field lbrun as character  initial ? 
    field mtcle as character  initial ? 
    field noite as integer    initial ? 
    field nomes as integer    initial ? 
    field rcclv as character  initial ? 
    field tprun as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
