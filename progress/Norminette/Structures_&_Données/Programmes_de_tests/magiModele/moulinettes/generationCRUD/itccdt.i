/*------------------------------------------------------------------------
File        : itccdt.i
Purpose     : Transfert compta - parametres compta analytique - conditions
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttItccdt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana-cd    as character  initial ? 
    field code-cd   as character  initial ? 
    field etab-cd   as integer    initial ? 
    field gsc-cd    as integer    initial ? 
    field nature-cd as character  initial ? 
    field niv-cd    as integer    initial ? 
    field soc-cd    as integer    initial ? 
    field type      as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
