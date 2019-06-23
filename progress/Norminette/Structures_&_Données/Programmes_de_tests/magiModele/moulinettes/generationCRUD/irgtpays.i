/*------------------------------------------------------------------------
File        : irgtpays.i
Purpose     : Groupe de pays (Entete) pour niveau de relance
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIrgtpays
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field lib    as character  initial ? 
    field rgt-cd as character  initial ? 
    field soc-cd as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
