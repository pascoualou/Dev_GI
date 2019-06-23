/*------------------------------------------------------------------------
File        : ltrol.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttLtrol
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdext     as character  initial ? 
    field cduti     as character  initial ? 
    field lbrol     as character  initial ? 
    field noref     as integer    initial ? 
    field noreq     as integer    initial ? 
    field norol     as integer    initial ? 
    field norol-dec as decimal    initial ?  decimals 0
    field noses     as integer    initial ? 
    field tprol     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
