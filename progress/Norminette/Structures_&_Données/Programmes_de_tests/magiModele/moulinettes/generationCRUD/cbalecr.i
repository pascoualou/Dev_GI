/*------------------------------------------------------------------------
File        : cbalecr.i
Purpose     : balance ecran
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCbalecr
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cpt-cd     as character  initial ? 
    field flag-1l    as logical    initial ? 
    field gi-ttyid   as character  initial ? 
    field mtcre      as decimal    initial ?  decimals 2
    field mtcre-EURO as decimal    initial ?  decimals 2
    field mtdeb      as decimal    initial ?  decimals 2
    field mtdeb-EURO as decimal    initial ?  decimals 2
    field noord      as integer    initial ? 
    field sscoll-cle as character  initial ? 
    field type       as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
