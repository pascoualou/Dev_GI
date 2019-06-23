/*------------------------------------------------------------------------
File        : TrfTx.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTrftx
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy  as character  initial ? 
    field cddev  as character  initial ? 
    field cdmsy  as character  initial ? 
    field dtcsy  as date       initial ? 
    field dtmsy  as date       initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field lgtx1  as character  initial ? 
    field lgtx2  as character  initial ? 
    field lgtx3  as character  initial ? 
    field lgtx4  as character  initial ? 
    field lgtx5  as character  initial ? 
    field lgtx6  as character  initial ? 
    field nomdt  as integer    initial ? 
    field TpApp  as character  initial ? 
    field TpTrf  as character  initial ? 
    field TpTxt  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
