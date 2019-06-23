/*------------------------------------------------------------------------
File        : ifdlncom.i
Purpose     : Table des designations complementaires des factures
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIfdlncom
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdlng   as integer    initial ? 
    field com-num as integer    initial ? 
    field desig   as character  initial ? 
    field etab-cd as integer    initial ? 
    field lig-num as integer    initial ? 
    field pos     as integer    initial ? 
    field soc-cd  as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
