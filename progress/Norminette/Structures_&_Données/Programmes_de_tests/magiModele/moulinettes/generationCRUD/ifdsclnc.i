/*------------------------------------------------------------------------
File        : ifdsclnc.i
Purpose     : Designations complementaires des scenarios de factures diverses
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIfdsclnc
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdlng      as integer    initial ? 
    field desig      as character  initial ? 
    field etab-cd    as integer    initial ? 
    field etab-dest  as integer    initial ? 
    field lig-num    as integer    initial ? 
    field pos        as integer    initial ? 
    field scen-cle   as character  initial ? 
    field soc-cd     as integer    initial ? 
    field soc-dest   as integer    initial ? 
    field typenat-cd as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
