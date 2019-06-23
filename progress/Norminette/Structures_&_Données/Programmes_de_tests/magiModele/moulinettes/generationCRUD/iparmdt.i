/*------------------------------------------------------------------------
File        : iparmdt.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIparmdt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field etab-cd           as integer    initial ? 
    field fg-mandat-ind     as logical    initial ? 
    field fg-regime         as logical    initial ? 
    field fg-soumis         as logical    initial ? 
    field fg-type-decla-dep as logical    initial ? 
    field fg-type-decla-rec as logical    initial ? 
    field soc-cd            as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
