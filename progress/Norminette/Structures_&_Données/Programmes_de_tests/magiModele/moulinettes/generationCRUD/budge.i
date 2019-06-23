/*------------------------------------------------------------------------
File        : budge.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttBudge
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy       as character  initial ? 
    field cddev       as character  initial ? 
    field cdmsy       as character  initial ? 
    field cdper       as character  initial ? 
    field dtcsy       as date       initial ? 
    field dtmsy       as date       initial ? 
    field dtval       as date       initial ? 
    field fgval       as logical    initial ? 
    field hecsy       as integer    initial ? 
    field hemsy       as integer    initial ? 
    field lbbud       as character  initial ? 
    field lbdiv       as character  initial ? 
    field lbdiv2      as character  initial ? 
    field lbdiv3      as character  initial ? 
    field mtini       as decimal    initial ?  decimals 2
    field mtini-dev   as decimal    initial ?  decimals 2
    field mtree       as decimal    initial ?  decimals 2
    field mtree-dev   as decimal    initial ?  decimals 2
    field mtreerecloc as decimal    initial ?  decimals 2
    field mttva       as decimal    initial ?  decimals 2
    field mttva-dev   as decimal    initial ?  decimals 2
    field mttvarecloc as decimal    initial ?  decimals 2
    field nobud       as int64      initial ? 
    field nobud-dec   as decimal    initial ?  decimals 0
    field tpbud       as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
