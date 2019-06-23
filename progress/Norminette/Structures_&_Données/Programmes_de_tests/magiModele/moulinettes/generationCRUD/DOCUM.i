/*------------------------------------------------------------------------
File        : DOCUM.i
Purpose     : Document
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttDocum
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cCodeTheme as character  initial ? 
    field cdcsy      as character  initial ? 
    field cddev      as character  initial ? 
    field cdmsy      as character  initial ? 
    field dtcsy      as date       initial ? 
    field dtmsy      as date       initial ? 
    field hecsy      as integer    initial ? 
    field hemsy      as integer    initial ? 
    field idged      as integer    initial ? 
    field lbcav      as character  initial ? 
    field lbcom      as character  initial ? 
    field lbdiv      as character  initial ? 
    field lbdiv2     as character  initial ? 
    field lbdiv3     as character  initial ? 
    field lbdoc      as character  initial ? 
    field lbobj      as character  initial ? 
    field noact      as integer    initial ? 
    field noaction   as integer    initial ? 
    field nocol      as integer    initial ? 
    field nodoc      as int64      initial ? 
    field nodot      as integer    initial ? 
    field noges      as integer    initial ? 
    field notrt      as integer    initial ? 
    field tbdat      as date       initial ? 
    field tbsig      as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
