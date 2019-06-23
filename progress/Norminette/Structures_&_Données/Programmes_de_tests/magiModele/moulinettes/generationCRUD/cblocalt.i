/*------------------------------------------------------------------------
File        : cblocalt.i
Purpose     : alerte du bloc note
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCblocalt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field alerte-cle as character  initial ? 
    field daech-prev as date       initial ? 
    field etab-cd    as integer    initial ? 
    field ind-cle    as character  initial ? 
    field ind2-cle   as character  initial ? 
    field lib        as character  initial ? 
    field soc-cd     as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
