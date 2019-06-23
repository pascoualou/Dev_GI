/*------------------------------------------------------------------------
File        : iaction.i
Purpose     : Table des actions utilisateurs
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIaction
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field action   as character  initial ? 
    field computer as character  initial ? 
    field dacrea   as date       initial ? 
    field ihcrea   as integer    initial ? 
    field nocon    as int64      initial ? 
    field noidt    as int64      initial ? 
    field nomprg   as character  initial ? 
    field notac    as int64      initial ? 
    field tpcon    as character  initial ? 
    field tpidt    as character  initial ? 
    field tptac    as character  initial ? 
    field username as character  initial ? 
    field usrid    as character  initial ? 
    field zone1    as character  initial ? 
    field zone2    as character  initial ? 
    field zone3    as character  initial ? 
    field zone4    as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
