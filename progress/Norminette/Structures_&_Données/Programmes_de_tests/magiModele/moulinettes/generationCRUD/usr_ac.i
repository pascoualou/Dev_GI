/*------------------------------------------------------------------------
File        : usr_ac.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttUsr_ac
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field CdUti as character  initial ? 
    field ChAcs as character  initial ? 
    field NmTbl as character  initial ? 
    field TbAcs as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
