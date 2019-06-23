/*------------------------------------------------------------------------
File        : LSTTYPDEM.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttLsttypdem
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field CDTYPDEM as character  initial ? 
    field LBTYPDEM as character  initial ? 
    field NOITE    as integer    initial ? 
    field NOMEN    as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
