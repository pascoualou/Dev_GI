/*------------------------------------------------------------------------
File        : tbficct.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTbficct
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field LbFic as character  initial ? 
    field nocon as int64      initial ? 
    field noidt as int64      initial ? 
    field tpcon as character  initial ? 
    field tpidt as character  initial ? 
    field tpsel as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
