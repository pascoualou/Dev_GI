/*------------------------------------------------------------------------
File        : cind.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCind
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field fixe      as logical    initial ? 
    field ind-cle   as character  initial ? 
    field lib       as character  initial ? 
    field order     as integer    initial ? 
    field principal as logical    initial ? 
    field soc-cd    as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
