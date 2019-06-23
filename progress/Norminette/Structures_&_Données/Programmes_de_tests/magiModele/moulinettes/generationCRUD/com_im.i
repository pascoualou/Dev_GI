/*------------------------------------------------------------------------
File        : com_im.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCom_im
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdlng as integer    initial ? 
    field lbimg as character  initial ? 
    field nmimg as character  initial ? 
    field noimg as integer    initial ? 
    field rpimg as character  initial ? 
    field zone1 as character  initial ? 
    field zone2 as character  initial ? 
    field zone3 as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
