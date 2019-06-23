/*------------------------------------------------------------------------
File        : apartva.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttApartva
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cpt-cd      as character  initial ? 
    field fg-debours  as logical    initial ? 
    field rmb-ana1-cd as character  initial ? 
    field rmb-ana2-cd as character  initial ? 
    field rmb-ana3-cd as character  initial ? 
    field rmb-lib-ecr as character  initial ? 
    field slb-lib-ecr as character  initial ? 
    field sld-ana1-cd as character  initial ? 
    field sld-ana2-cd as character  initial ? 
    field sld-ana3-cd as character  initial ? 
    field soc-cd      as integer    initial ? 
    field sscoll-cle  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
