/*------------------------------------------------------------------------
File        : adb_cm.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAdb_cm
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdisp as character  initial ? 
    field cdmsp as character  initial ? 
    field lbimg as character  initial ? 
    field lbins as character  initial ? 
    field noite as integer    initial ? 
    field nomen as integer    initial ? 
    field noord as integer    initial ? 
    field tpecr as character  initial ? 
    field tpsep as character  initial ? 
    field zone1 as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
