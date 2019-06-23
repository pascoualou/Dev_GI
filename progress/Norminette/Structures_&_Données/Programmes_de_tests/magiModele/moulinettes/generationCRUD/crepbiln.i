/*------------------------------------------------------------------------
File        : crepbiln.i
Purpose     : ligne de code reporting bilan
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCrepbiln
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field categ-immo as integer    initial ? 
    field cpt-cd     as character  initial ? 
    field etab-cd    as integer    initial ? 
    field jou-cd     as character  initial ? 
    field rub-cd     as integer    initial ? 
    field soc-cd     as integer    initial ? 
    field type       as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
