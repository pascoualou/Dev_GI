/*------------------------------------------------------------------------
File        : erlet.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttErlet
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field anaer     as character  initial ? 
    field anarc     as character  initial ? 
    field ancdt     as date       initial ? 
    field cdana     as character  initial ? 
    field cdbat     as character  initial ? 
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdmsy     as character  initial ? 
    field cdter     as character  initial ? 
    field cdtva     as character  initial ? 
    field cduni     as character  initial ? 
    field clrec     as character  initial ? 
    field clrep     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtdpo     as date       initial ? 
    field dtfpo     as date       initial ? 
    field dtmsy     as date       initial ? 
    field dtrec     as date       initial ? 
    field dtrlv     as date       initial ? 
    field FgRlvImm  as logical    initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field liber     as character  initial ? 
    field librc     as character  initial ? 
    field mdsai     as character  initial ? 
    field nocon     as integer    initial ? 
    field noimm     as integer    initial ? 
    field norli     as integer    initial ? 
    field norlv     as integer    initial ? 
    field pxuer     as decimal    initial ?  decimals 6
    field pxuer-dev as decimal    initial ?  decimals 6
    field pxuni     as decimal    initial ?  decimals 6
    field pxuni-dev as decimal    initial ?  decimals 6
    field recer     as character  initial ? 
    field totco     as decimal    initial ?  decimals 3
    field toter     as decimal    initial ?  decimals 2
    field toter-dev as decimal    initial ?  decimals 2
    field totrc     as decimal    initial ?  decimals 2
    field totrc-dev as decimal    initial ?  decimals 2
    field totrl     as decimal    initial ?  decimals 2
    field totrl-dev as decimal    initial ?  decimals 2
    field tpcon     as character  initial ? 
    field tpcpt     as character  initial ? 
    field tvaer     as decimal    initial ?  decimals 2
    field tvaer-dev as decimal    initial ?  decimals 2
    field tvarc     as decimal    initial ?  decimals 2
    field tvarc-dev as decimal    initial ?  decimals 2
    field tvarl     as decimal    initial ?  decimals 2
    field tvarl-dev as decimal    initial ?  decimals 2
    field txter     as decimal    initial ?  decimals 3
    field txtva     as decimal    initial ?  decimals 3
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
