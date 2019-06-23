/*------------------------------------------------------------------------
File        : ctctt.i
Description : 
Author(s)   : GGA - 2017/12/22
Notes       :
derniere revue: 2018/08/07 - phm: 
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCtctt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field tpct1       as character          initial ?
    field noct1       as int64              initial ?
    field tpct2       as character          initial ?
    field noct2       as int64              initial ?
    field cddev       as character          initial ?
    field lbdiv       as character          initial ?
    field lbdiv2      as character          initial ?
    field lbdiv3      as character          initial ?
    field noct1-dec   as decimal decimals 0 initial ?
    field noct2-dec   as decimal decimals 0 initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
