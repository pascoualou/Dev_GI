/*------------------------------------------------------------------------
File        : ctrlb.i
Purpose     : 
Author(s)   : GGA - 2017/09/14
Notes       :
------------------------------------------------------------------------*/

&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCtrlb 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif

define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field dtcsy       as date      initial ?
    field hecsy       as integer   initial ?
    field cdcsy       as character initial ?
    field dtmsy       as date      initial ?
    field hemsy       as integer   initial ?
    field cdmsy       as character initial ?
    field tpctt       as character initial ?
    field noctt       as int64     initial ?
    field tpid1       as character initial ?
    field noid1       as int64     initial ?
    field tpid2       as character initial ?
    field noid2       as int64     initial ?
    field nbnum       as integer   initial ?
    field nbden       as integer   initial ?
    field mdreg       as character initial ?
    field tpct2       as character initial ?
    field noct2       as integer   initial ?
    field lbdiv       as character initial ?
    field cddev       as character initial ?
    field lbdiv2      as character initial ?
    field lbdiv3      as character initial ?
    field noctt-dec   as decimal   initial ?
    field noct2-dec   as decimal   initial ?
    field tpmadisp    as character initial ?                    
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
