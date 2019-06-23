/*------------------------------------------------------------------------
File        : iusers.i
Purpose     : table des utilisateurs pour defauts
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIusers
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field depot-cd as integer    initial ? 
    field div-cd   as integer    initial ? 
    field soc-cd   as integer    initial ? 
    field user-cle as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
