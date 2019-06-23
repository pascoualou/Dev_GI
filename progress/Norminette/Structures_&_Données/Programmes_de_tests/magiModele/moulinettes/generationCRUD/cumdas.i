/*------------------------------------------------------------------------
File        : cumdas.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCumdas
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field antrt  as integer    initial ? 
    field cdcsy  as character  initial ? 
    field cdmsy  as character  initial ? 
    field cdori  as character  initial ? 
    field dtcsy  as date       initial ? 
    field dtems  as date       initial ? 
    field dtmsy  as date       initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field lbrub  as character  initial ? 
    field modul  as character  initial ? 
    field mspai  as integer    initial ? 
    field nomdt  as integer    initial ? 
    field norol  as decimal    initial ?  decimals ?
    field tpmdt  as character  initial ? 
    field tprol  as character  initial ? 
    field vlext  as decimal    initial ?  decimals 4
    field vlmgi  as decimal    initial ?  decimals 4
    field vlmod  as decimal    initial ?  decimals 4
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
