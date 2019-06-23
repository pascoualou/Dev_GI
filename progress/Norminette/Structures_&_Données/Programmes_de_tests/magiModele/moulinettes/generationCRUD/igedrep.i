/*------------------------------------------------------------------------
File        : igedrep.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIgedrep
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdmsy       as character  initial ? 
    field chemin-corb as character  initial ? 
    field chemin-doss as character  initial ? 
    field dtmsy       as date       initial ? 
    field hemsy       as integer    initial ? 
    field lib-doss    as character  initial ? 
    field login-corb  as character  initial ? 
    field login-doss  as character  initial ? 
    field nom-corb    as character  initial ? 
    field nom-doss    as character  initial ? 
    field pwd-corb    as character  initial ? 
    field pwd-doss    as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
