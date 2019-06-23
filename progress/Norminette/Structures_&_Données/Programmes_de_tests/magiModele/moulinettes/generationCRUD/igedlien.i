/*------------------------------------------------------------------------
File        : igedlien.i
Purpose     : Table de liens ged
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIgedlien
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdivers1 as character  initial ? 
    field cdivers2 as character  initial ? 
    field cdpar1   as character  initial ? 
    field cdpar2   as character  initial ? 
    field ddivers1 as decimal    initial ?  decimals 2
    field ddivers2 as decimal    initial ?  decimals 2
    field idivers1 as int64      initial ? 
    field idivers2 as int64      initial ? 
    field tppar    as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
