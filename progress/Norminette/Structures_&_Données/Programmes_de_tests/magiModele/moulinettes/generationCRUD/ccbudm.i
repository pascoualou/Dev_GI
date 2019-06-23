/*------------------------------------------------------------------------
File        : ccbudm.i
Purpose     : construction des budgets mixtes
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCcbudm
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana-cd        as character  initial ? 
    field ana1-cd       as character  initial ? 
    field ana2-cd       as character  initial ? 
    field ana3-cd       as character  initial ? 
    field ana4-cd       as character  initial ? 
    field anacor        as logical    initial ? 
    field anacor-int    as integer    initial ? 
    field budget-cd     as character  initial ? 
    field cpt-cd        as character  initial ? 
    field etab-cd       as integer    initial ? 
    field libsens-cd    as integer    initial ? 
    field mt            as decimal    initial ?  decimals 2
    field mt-EURO       as decimal    initial ?  decimals 2
    field mtrevise      as decimal    initial ?  decimals 2
    field mtrevise-EURO as decimal    initial ?  decimals 2
    field rub-cd        as integer    initial ? 
    field sensrev       as integer    initial ? 
    field soc-cd        as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
