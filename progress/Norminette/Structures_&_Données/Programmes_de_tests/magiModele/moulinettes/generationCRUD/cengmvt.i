/*------------------------------------------------------------------------
File        : cengmvt.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCengmvt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana-cd    as character  initial ? 
    field budget-cd as character  initial ? 
    field etab-cd   as integer    initial ? 
    field mt        as decimal    initial ?  decimals 2
    field mtfac     as decimal    initial ?  decimals 2
    field mtpaie    as decimal    initial ?  decimals 2
    field mtplaf    as decimal    initial ?  decimals 2
    field niv-num   as integer    initial ? 
    field rub-cd    as integer    initial ? 
    field soc-cd    as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
