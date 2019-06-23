/*------------------------------------------------------------------------
File        : scfct.i
Purpose     : 0110/0169 : Liste des fonctions pour le conseil de gérance
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttScfct
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy as character  initial ? 
    field cdfct as character  initial ? 
    field cdmsy as character  initial ? 
    field dtcsy as date       initial ? 
    field dtmsy as date       initial ? 
    field hecsy as integer    initial ? 
    field hemsy as integer    initial ? 
    field lbfct as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
