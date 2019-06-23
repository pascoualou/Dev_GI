/*------------------------------------------------------------------------
File        : ifdjou.i
Purpose     : tables des journaux facturation
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIfdjou
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field etab-cd     as integer    initial ? 
    field jou-cd      as character  initial ? 
    field jou-dest    as character  initial ? 
    field soc-cd      as integer    initial ? 
    field soc-dest    as integer    initial ? 
    field sscoll-cle  as character  initial ? 
    field typefac-cle as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
