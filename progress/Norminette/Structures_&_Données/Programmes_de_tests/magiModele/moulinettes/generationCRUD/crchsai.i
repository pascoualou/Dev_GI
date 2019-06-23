/*------------------------------------------------------------------------
File        : crchsai.i
Purpose     : Table des entetes de repartitions de charges
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCrchsai
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cptctrl     as character  initial ? 
    field cptrep      as character  initial ? 
    field etab-cd     as integer    initial ? 
    field period      as integer    initial ? 
    field repart-cle  as character  initial ? 
    field soc-cd      as integer    initial ? 
    field type-repart as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
