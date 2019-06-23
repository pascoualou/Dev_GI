/*------------------------------------------------------------------------
File        : proce.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttProce
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdbar  as character  initial ? 
    field cdcsy  as character  initial ? 
    field cddev  as character  initial ? 
    field cdmsy  as character  initial ? 
    field dtcsy  as date       initial ? 
    field dtmsy  as date       initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field lbpro  as character  initial ? 
    field nolo1  as integer    initial ? 
    field nolo2  as integer    initial ? 
    field nomd1  as integer    initial ? 
    field nomd2  as integer    initial ? 
    field norol  as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
