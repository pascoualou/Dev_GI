/*------------------------------------------------------------------------
File        : cttac.i
Description : 
Author(s)   : GGA - 2017/09/27
Notes       :
derniere revue: 2018/05/04 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCttac
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field dtcsy       as date
    field hecsy       as integer   initial ?
    field cdcsy       as character initial ?
    field dtmsy       as date
    field hemsy       as integer   initial ?
    field cdmsy       as character initial ?
    field tpcon       as character initial ?
    field nocon       as int64     initial ?
    field tptac       as character initial ?
    field cddev       as character initial ?
    field lbdiv       as character initial ?
    field lbdiv2      as character initial ?
    field lbdiv3      as character initial ?
    field nocon-dec   as decimal   initial ?
    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
