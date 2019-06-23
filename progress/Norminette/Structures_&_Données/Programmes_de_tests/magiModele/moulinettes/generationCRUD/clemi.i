/*------------------------------------------------------------------------
File        : clemi.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttClemi
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdarc  as character  initial ? 
    field cdbat  as character  initial ? 
    field cdcle  as character  initial ? 
    field cdcsy  as character  initial ? 
    field cddev  as character  initial ? 
    field cdeta  as character  initial ? 
    field cdmsy  as character  initial ? 
    field dtcsy  as date       initial ? 
    field dtdeb  as date       initial ? 
    field dtfin  as date       initial ? 
    field dtmsy  as date       initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field lbcle  as character  initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field nbeca  as decimal    initial ?  decimals 2
    field nbtot  as decimal    initial ?  decimals 2
    field nocon  as integer    initial ? 
    field noexo  as integer    initial ? 
    field noimm  as integer    initial ? 
    field noord  as integer    initial ? 
    field norep  as integer    initial ? 
    field tpcle  as character  initial ? 
    field tpcon  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
