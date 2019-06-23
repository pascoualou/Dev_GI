/*------------------------------------------------------------------------
File        : cblocsce.i
Purpose     : Scenario du bloc note
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCblocsce
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field act-cle  as character  initial ? 
    field etab-cd  as integer    initial ? 
    field fg-cpt   as logical    initial ? 
    field fg-ecr   as logical    initial ? 
    field ind-cle  as character  initial ? 
    field ind2-cle as character  initial ? 
    field lib      as character  initial ? 
    field lib-cd   as character  initial ? 
    field libscen  as character  initial ? 
    field ori-cle  as character  initial ? 
    field scen-cle as character  initial ? 
    field soc-cd   as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
