/*------------------------------------------------------------------------
File        : rlctt.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
derniere revue: 2018/08/08 - phm: 
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRlctt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cddev     as character initial ?
    field lbdiv     as character initial ?
    field lbdiv2    as character initial ?
    field lbdiv3    as character initial ?
    field noct1     as int64     initial ?
    field noct1-dec as decimal   initial ? decimals 0
    field noct2     as int64     initial ?
    field noct2-dec as decimal   initial ? decimals 0
    field noidt     as int64     initial ?
    field noidt-dec as decimal   initial ? decimals 0
    field tpct1     as character initial ?
    field tpct2     as character initial ?
    field tpidt     as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
