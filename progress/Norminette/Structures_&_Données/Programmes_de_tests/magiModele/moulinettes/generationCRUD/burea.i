/*------------------------------------------------------------------------
File        : burea.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttBurea
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcle       as character  initial ? 
    field cdcsy       as character  initial ? 
    field cddev       as character  initial ? 
    field cdmsy       as character  initial ? 
    field cdrub       as integer    initial ? 
    field cdsrb       as integer    initial ? 
    field dtcsy       as date       initial ? 
    field dtmsy       as date       initial ? 
    field hecsy       as integer    initial ? 
    field hemsy       as integer    initial ? 
    field lbdiv       as character  initial ? 
    field lbdiv2      as character  initial ? 
    field lbdiv3      as character  initial ? 
    field mtbud       as decimal    initial ?  decimals 2
    field mtbud-dev   as decimal    initial ?  decimals 2
    field mtrecloc    as decimal    initial ?  decimals 2
    field mttva       as decimal    initial ?  decimals 2
    field mttvarecloc as decimal    initial ?  decimals 2
    field nobud       as int64      initial ? 
    field nobud-dec   as decimal    initial ?  decimals 0
    field noper       as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
