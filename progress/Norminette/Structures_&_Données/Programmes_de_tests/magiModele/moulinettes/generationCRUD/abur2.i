/*------------------------------------------------------------------------
File        : abur2.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAbur2
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdbat  as character  initial ? 
    field cdcsy  as character  initial ? 
    field cddev  as character  initial ? 
    field cdeta  as character  initial ? 
    field cdexe  as integer    initial ? 
    field cdmsy  as character  initial ? 
    field dtcsy  as date       initial ? 
    field dtmsy  as date       initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field lblot  as character  initial ? 
    field lbnom  as character  initial ? 
    field noimm  as integer    initial ? 
    field nolot  as integer    initial ? 
    field noman  as integer    initial ? 
    field nomdt  as integer    initial ? 
    field sfbu1  as integer    initial ? 
    field sfbu2  as integer    initial ? 
    field tpart  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
