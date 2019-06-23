/*------------------------------------------------------------------------
File        : perio.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPerio
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy  as character  initial ? 
    field cddev  as character  initial ? 
    field cdmsy  as character  initial ? 
    field cdper  as character  initial ? 
    field cdtrt  as character  initial ? 
    field dtage  as date       initial ? 
    field dtapc  as date       initial ? 
    field dtcsy  as date       initial ? 
    field dtdeb  as date       initial ? 
    field dtfin  as date       initial ? 
    field dtmsy  as date       initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field lbper  as character  initial ? 
    field nbmoi  as integer    initial ? 
    field noexo  as integer    initial ? 
    field nomdt  as integer    initial ? 
    field noper  as integer    initial ? 
    field tpctt  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
