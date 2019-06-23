/*------------------------------------------------------------------------
File        : txrole.i
Purpose     : 1207/0082 - reglement direct loc-> prop
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTxrole
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy  as character  initial ? 
    field cdmsy  as character  initial ? 
    field dtcsy  as date       initial ? 
    field dtmsy  as date       initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field lbtx1  as character  initial ? 
    field lbtx2  as character  initial ? 
    field lbtx3  as character  initial ? 
    field lbtx4  as character  initial ? 
    field lbtx5  as character  initial ? 
    field lbtx6  as character  initial ? 
    field norol  as int64      initial ? 
    field notxt  as integer    initial ? 
    field tprol  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
