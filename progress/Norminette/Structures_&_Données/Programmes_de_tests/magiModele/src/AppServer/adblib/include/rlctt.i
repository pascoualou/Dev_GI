/*------------------------------------------------------------------------
File        : rlctt.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRlctt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdmsy     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtmsy     as date       initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field noct1     as int64      initial ? 
    field noct1-dec as decimal    initial ?  decimals 0
    field noct2     as int64      initial ? 
    field noct2-dec as decimal    initial ?  decimals 0
    field noidt     as int64      initial ? 
    field noidt-dec as decimal    initial ?  decimals 0
    field tpct1     as character  initial ? 
    field tpct2     as character  initial ? 
    field tpidt     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
