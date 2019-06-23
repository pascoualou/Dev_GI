/*------------------------------------------------------------------------
File        : ilibope.i
Purpose     : libelles operations bancaires
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIlibope
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field flag-piece as logical    initial ? 
    field lib        as character  initial ? 
    field libope-cd  as character  initial ? 
    field libsens-cd as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
