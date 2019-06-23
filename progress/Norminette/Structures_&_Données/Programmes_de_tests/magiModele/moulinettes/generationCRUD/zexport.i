/*------------------------------------------------------------------------
File        : zexport.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttZexport
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field datrans    as date       initial ? 
    field libtype-cd as integer    initial ? 
    field soc-cd     as integer    initial ? 
    field tiers-cle  as character  initial ? 
    field transfert  as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
