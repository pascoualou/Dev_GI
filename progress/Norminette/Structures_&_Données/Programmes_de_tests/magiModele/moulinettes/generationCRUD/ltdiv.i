/*------------------------------------------------------------------------
File        : ltdiv.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttLtdiv
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdext as character  initial ? 
    field cduti as character  initial ? 
    field lbdiv as character  initial ? 
    field nodiv as decimal    initial ?  decimals 0
    field noref as integer    initial ? 
    field noreq as integer    initial ? 
    field noses as integer    initial ? 
    field tpdiv as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
