/*------------------------------------------------------------------------
File        : txqtt.i
Purpose     : 
Author(s)   : generation automatique le 08/08/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTxqtt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cddev  as character initial ?
    field lbdiv  as character initial ?
    field lbdiv2 as character initial ?
    field lbdiv3 as character initial ?
    field nomdt  as integer   initial ?
    field qttx1  as character initial ?
    field qttx2  as character initial ?
    field qttx3  as character initial ?
    field qttx4  as character initial ?
    field qttx5  as character initial ?
    field qttx6  as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
