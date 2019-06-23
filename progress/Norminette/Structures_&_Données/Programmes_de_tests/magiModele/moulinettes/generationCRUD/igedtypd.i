/*------------------------------------------------------------------------
File        : igedtypd.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIgedtypd
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdivers          as character  initial ? 
    field duree            as integer    initial ? 
    field fg-ged           as logical    initial ? 
    field gidemat-typdoc   as character  initial ? 
    field gidemat-typtrait as character  initial ? 
    field lib              as character  initial ? 
    field mots-cle         as character  initial ? 
    field orig-cd          as character  initial ? 
    field tp-vers          as character  initial ? 
    field typdoc-cd        as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
