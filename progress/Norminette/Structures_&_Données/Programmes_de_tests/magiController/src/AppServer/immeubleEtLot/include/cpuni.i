/*------------------------------------------------------------------------
File        : cpuni.i
Description : 
Author(s)   : gga - 2017/09/25
Notes       : 
derniere revue: 2018/05/25 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCpuni
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field nomdt  as integer   initial ?
    field noapp  as integer   initial ?
    field nocmp  as integer   initial ?
    field noman  as integer   initial ?
    field noord  as integer   initial ?
    field noimm  as integer   initial ?
    field nolot  as integer   initial ?
    field cdori  as character initial ?
    field sflot  as decimal   initial ?
    field cddev  as character initial ?
    field lbdiv  as character initial ?
    field lbdiv2 as character initial ?
    field lbdiv3 as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
