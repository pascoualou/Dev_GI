/*------------------------------------------------------------------------
File        : submdreg.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttSubmdreg
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy          as character  initial ? 
    field cdmsy          as character  initial ? 
    field dtapp          as date       initial ? 
    field dtcsy          as date       initial ? 
    field dtmsy          as date       initial ? 
    field hecsy          as integer    initial ? 
    field hemsy          as integer    initial ? 
    field lbdiv          as character  initial ? 
    field lbdiv2         as character  initial ? 
    field lbdiv3         as character  initial ? 
    field mdreg          as character  initial ? 
    field mtappprec      as decimal    initial ?  decimals 2
    field mtdispomandant as decimal    initial ?  decimals 2
    field mtdispomandat  as decimal    initial ?  decimals 2
    field mtecart        as decimal    initial ?  decimals 2
    field noapp          as integer    initial ? 
    field nobud          as int64      initial ? 
    field nocop          as integer    initial ? 
    field nomandant      as integer    initial ? 
    field nomdt          as decimal    initial ?  decimals 2
    field nomdtger       as decimal    initial ?  decimals 2
    field tpapp          as character  initial ? 
    field tptrt          as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
