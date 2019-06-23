/*------------------------------------------------------------------------
File        : rqrol.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRqrol
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cduti as character  initial ? 
    field nbenr as integer    initial ? 
    field noref as integer    initial ? 
    field Noreq as integer    initial ? 
    field noses as integer    initial ? 
    field rqref as integer    initial ? 
    field tprol as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
