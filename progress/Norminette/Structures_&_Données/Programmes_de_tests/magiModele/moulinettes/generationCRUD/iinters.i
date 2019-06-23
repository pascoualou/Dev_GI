/*------------------------------------------------------------------------
File        : iinters.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIinters
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cptdd-cd  as character  initial ? 
    field cptds-cd  as character  initial ? 
    field cpts-cd   as character  initial ? 
    field cptv-cd   as character  initial ? 
    field etab-cd   as integer    initial ? 
    field jou-cd    as character  initial ? 
    field soc-cd    as integer    initial ? 
    field typed-cle as character  initial ? 
    field typev-cle as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
