/*------------------------------------------------------------------------
File        : igedrusr.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIgedrusr
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdivers1 as character  initial ? 
    field cdmsy    as character  initial ? 
    field dtmsy    as date       initial ? 
    field hemsy    as integer    initial ? 
    field ident_u  as character  initial ? 
    field nom-doss as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
