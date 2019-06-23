/*------------------------------------------------------------------------
File        : ifprart.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIfprart
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana1-cd     as character  initial ? 
    field ana2-cd     as character  initial ? 
    field ana3-cd     as character  initial ? 
    field ana4-cd     as character  initial ? 
    field art-cle     as character  initial ? 
    field cptg-dest   as character  initial ? 
    field etab-dest   as integer    initial ? 
    field soc-cd      as integer    initial ? 
    field soc-dest    as integer    initial ? 
    field sscpt-dest  as character  initial ? 
    field taxe-cd     as integer    initial ? 
    field typefac-cle as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
