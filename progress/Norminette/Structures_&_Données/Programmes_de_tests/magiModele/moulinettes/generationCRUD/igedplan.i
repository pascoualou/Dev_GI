/*------------------------------------------------------------------------
File        : igedplan.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIgedplan
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdivers    as character  initial ? 
    field fg-actif   as logical    initial ? 
    field niv-entite as character  initial ? 
    field niv-lib    as character  initial ? 
    field niv-type   as character  initial ? 
    field plan-cd    as character  initial ? 
    field plan-lib   as character  initial ? 
    field plan-nbniv as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
