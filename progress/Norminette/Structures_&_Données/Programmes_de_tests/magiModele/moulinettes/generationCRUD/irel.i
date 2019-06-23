/*------------------------------------------------------------------------
File        : irel.i
Purpose     : Liste des differents textes de lettre de relance.
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIrel
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field etab-cd   as integer    initial ? 
    field librelcd  as character  initial ? 
    field librelnum as character  initial ? 
    field rel-cd    as integer    initial ? 
    field rel-num   as integer    initial ? 
    field soc-cd    as integer    initial ? 
    field txt       as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
