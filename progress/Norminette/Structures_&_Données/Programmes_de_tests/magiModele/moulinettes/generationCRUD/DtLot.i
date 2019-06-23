/*------------------------------------------------------------------------
File        : DtLot.i
Purpose     : Chaine Travaux : Table des Lots des Travaux
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttDtlot
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy as character  initial ? 
    field cdmsy as character  initial ? 
    field dtcsy as date       initial ? 
    field dtmsy as date       initial ? 
    field hecsy as integer    initial ? 
    field hemsy as integer    initial ? 
    field lbdiv as character  initial ? 
    field NoLoc as integer    initial ? 
    field NoTrt as integer    initial ? 
    field TpTrt as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
