/*------------------------------------------------------------------------
File        : ltctt.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttLtctt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdext     as character  initial ? 
    field cduti     as character  initial ? 
    field lbcon     as character  initial ? 
    field nocon     as integer    initial ? 
    field nocon-dec as decimal    initial ?  decimals 0
    field noref     as integer    initial ? 
    field noreq     as integer    initial ? 
    field noses     as integer    initial ? 
    field tpcon     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
