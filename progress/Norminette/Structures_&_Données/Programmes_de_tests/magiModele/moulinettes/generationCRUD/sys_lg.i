/*------------------------------------------------------------------------
File        : sys_lg.i
Purpose     : Codes langues supportés par l'application
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttSys_lg
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cddiv as integer    initial ? 
    field cdlng as integer    initial ? 
    field lbdiv as character  initial ? 
    field lblng as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
