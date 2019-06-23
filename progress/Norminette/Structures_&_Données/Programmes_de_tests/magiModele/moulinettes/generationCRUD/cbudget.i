/*------------------------------------------------------------------------
File        : cbudget.i
Purpose     : fichier des budgets
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCbudget
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field arrondi    as logical    initial ? 
    field budget-cd  as character  initial ? 
    field etab-cd    as integer    initial ? 
    field lib        as character  initial ? 
    field modele-cd  as character  initial ? 
    field nature     as character  initial ? 
    field prd-cd     as integer    initial ? 
    field prd-numdeb as integer    initial ? 
    field prd-numfin as integer    initial ? 
    field soc-cd     as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
