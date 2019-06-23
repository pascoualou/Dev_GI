/*------------------------------------------------------------------------
File        : crepcpt.i
Purpose     : Fichier comptes a repartir
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCrepcpt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cpt-cd     as character  initial ? 
    field cpt-global as character  initial ? 
    field etab-cd    as integer    initial ? 
    field lig        as integer    initial ? 
    field repart-cle as character  initial ? 
    field soc-cd     as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
