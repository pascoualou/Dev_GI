/*------------------------------------------------------------------------
File        : SuiExport.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttSuiexport
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field DtExp as date       initial ? 
    field HeExp as integer    initial ? 
    field NoIdt as character  initial ? 
    field TpExp as character  initial ? 
    field TpIdt as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
