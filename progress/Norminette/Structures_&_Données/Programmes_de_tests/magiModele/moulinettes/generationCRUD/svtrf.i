/*------------------------------------------------------------------------
File        : svtrf.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttSvtrf
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdban  as character  initial ? 
    field cdcsy  as character  initial ? 
    field cddev  as character  initial ? 
    field cdmsy  as character  initial ? 
    field cdtrt  as character  initial ? 
    field dtcsy  as date       initial ? 
    field dtmsy  as date       initial ? 
    field dttrf  as date       initial ? 
    field ettrf  as character  initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field hetrf  as integer    initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field mstrt  as integer    initial ? 
    field nbmod  as integer    initial ? 
    field noder  as integer    initial ? 
    field NoOrd  as integer    initial ? 
    field nopha  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
