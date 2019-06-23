/*------------------------------------------------------------------------
File        : cttac.i
Description : 
Author(s)   : GGA - 2017/09/27
Notes       :
derniere revue: 2018/07/24 - spo: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCttac
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
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
