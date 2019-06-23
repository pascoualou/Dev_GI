/*------------------------------------------------------------------------
File        : freThEt.i
Purpose     : RIE : tableau  des fréquentations Théoriques (entete)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttFrethet
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcleapp as character  initial ? 
    field cdcsy    as character  initial ? 
    field cdmsy    as character  initial ? 
    field dtcsy    as date       initial ? 
    field dtmsy    as date       initial ? 
    field hecsy    as integer    initial ? 
    field hemsy    as integer    initial ? 
    field lbcleapp as character  initial ? 
    field lbdiv    as character  initial ? 
    field lbdiv2   as character  initial ? 
    field lbdiv3   as character  initial ? 
    field nbtot    as int64      initial ? 
    field nocon    as int64      initial ? 
    field noexo    as integer    initial ? 
    field tpcon    as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
