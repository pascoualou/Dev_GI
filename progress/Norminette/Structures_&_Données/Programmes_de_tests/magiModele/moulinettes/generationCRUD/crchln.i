/*------------------------------------------------------------------------
File        : crchln.i
Purpose     : Table des lignes de repartitions de charges
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCrchln
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cpt-cd        as character  initial ? 
    field cptrep-repart as character  initial ? 
    field etab-cd       as integer    initial ? 
    field lig           as integer    initial ? 
    field soc-cd        as integer    initial ? 
    field taux          as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
