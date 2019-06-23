/*------------------------------------------------------------------------
File        : ccptaff.i
Purpose     : Imputation des affaires par compte
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCcptaff
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field affimp-cd as integer    initial ? 
    field cpt-cd    as character  initial ? 
    field etab-cd   as integer    initial ? 
    field soc-cd    as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
