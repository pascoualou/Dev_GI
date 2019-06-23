/*------------------------------------------------------------------------
File        : ratlo.i
Purpose     : rattachements des lots
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRatlo
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy     as character  initial ? 
    field cdmsy     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtdeb     as date       initial ? 
    field dtfin     as date       initial ? 
    field dtmsy     as date       initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field nbden     as integer    initial ? 
    field nbnum     as integer    initial ? 
    field noctt     as int64      initial ? 
    field noctt-dec as decimal    initial ?  decimals 0
    field noidt     as int64      initial ? 
    field noidt-dec as decimal    initial ?  decimals 0
    field noimm     as integer    initial ? 
    field nolot     as integer    initial ? 
    field nomdt     as integer    initial ? 
    field tpctt     as character  initial ? 
    field tpidt     as character  initial ? 
    field tpmdt     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
