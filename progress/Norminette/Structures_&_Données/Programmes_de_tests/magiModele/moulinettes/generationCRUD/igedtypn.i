/*------------------------------------------------------------------------
File        : igedtypn.i
Purpose     : Association type de doc / niveau 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIgedtypn
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdivers   as character  initial ? 
    field plan-cd   as character  initial ? 
    field plan-niv  as integer    initial ? 
    field typdoc-cd as integer    initial ? 
    field valeur    as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
