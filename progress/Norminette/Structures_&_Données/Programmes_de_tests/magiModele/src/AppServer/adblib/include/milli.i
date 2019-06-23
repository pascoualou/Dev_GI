/*------------------------------------------------------------------------
File        : milli.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttMilli
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdbat  as character  initial ? 
    field cdcle  as character  initial ? 
    field cdcsy  as character  initial ? 
    field cddev  as character  initial ? 
    field cdmsy  as character  initial ? 
    field clrec  as character  initial ? 
    field dtcsy  as date 
    field dtmsy  as date 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field nbpar  as decimal    initial ?  decimals 2
    field noimm  as integer    initial ? 
    field nolot  as integer    initial ? 
    field norep  as integer    initial ? 
    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
