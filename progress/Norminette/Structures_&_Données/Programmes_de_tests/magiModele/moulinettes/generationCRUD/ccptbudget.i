/*------------------------------------------------------------------------
File        : ccptbudget.i
Purpose     : Fichier codes &/ou Comptes Budgetaires
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCcptbudget
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana1-cd     as character  initial ? 
    field ana2-cd     as character  initial ? 
    field ana3-cd     as character  initial ? 
    field ana4-cd     as character  initial ? 
    field budg-cd     as integer    initial ? 
    field budget-cle  as integer    initial ? 
    field clecalcul   as integer    initial ? 
    field cptbudg     as integer    initial ? 
    field datdebcompt as date       initial ? 
    field datfincompt as date       initial ? 
    field etab-cd     as integer    initial ? 
    field libudget    as character  initial ? 
    field soc-cd      as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
