/*------------------------------------------------------------------------
File        : ifdrgt.i
Purpose     : Table des regroupements
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIfdrgt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field lib        as character  initial ? 
    field rgt-cle    as character  initial ? 
    field soc-cd     as integer    initial ? 
    field typergt-cd as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
