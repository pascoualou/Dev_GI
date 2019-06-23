/*------------------------------------------------------------------------
File        : iprtparam.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIprtparam
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field critere-lib as character  initial ? 
    field critere-val as character  initial ? 
    field order-num   as integer    initial ? 
    field prg-name    as character  initial ? 
    field util-num    as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
