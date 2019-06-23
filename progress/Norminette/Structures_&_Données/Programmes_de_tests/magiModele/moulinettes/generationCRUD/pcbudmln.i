/*------------------------------------------------------------------------
File        : pcbudmln.i
Purpose     : construction des budgets : Affectation des Montants
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPcbudmln
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana1-cd       as character  initial ? 
    field ana2-cd       as character  initial ? 
    field ana3-cd       as character  initial ? 
    field ana4-cd       as character  initial ? 
    field budget-cd     as character  initial ? 
    field cpt-cd        as character  initial ? 
    field etab-cd       as integer    initial ? 
    field modif         as logical    initial ? 
    field mt            as decimal    initial ?  decimals 2
    field mt-EURO       as decimal    initial ?  decimals 2
    field mtrevise      as decimal    initial ?  decimals 2
    field mtrevise-EURO as decimal    initial ?  decimals 2
    field prd-numdeb    as integer    initial ? 
    field prd-numdebr   as integer    initial ? 
    field prd-numfin    as integer    initial ? 
    field prd-numfinr   as integer    initial ? 
    field rub-cd        as integer    initial ? 
    field signe         as character  initial ? 
    field signerev      as character  initial ? 
    field soc-cd        as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
