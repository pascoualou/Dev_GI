/*------------------------------------------------------------------------
File        : assrc.i
Purpose     : 
Author(s)   : GGA - 2017/11/13
Notes       :
derniere revue: 2018/04/27 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAssrc
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field dtcsy  as date
    field hecsy  as integer   initial ?
    field cdcsy  as character initial ?
    field dtmsy  as date
    field hemsy  as integer   initial ?
    field cdmsy  as character initial ?
    field nomdt  as integer   initial ?
    field cdrub  as integer   initial ?
    field cdlib  as integer   initial ?
    field cdcle  as character initial ?
    field lbcle  as character initial ?
    field nbbas  as decimal   initial ? decimals 2
    field cddev  as character initial ?
    field lbdiv  as character initial ?
    field lbdiv2 as character initial ?
    field lbdiv3 as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
