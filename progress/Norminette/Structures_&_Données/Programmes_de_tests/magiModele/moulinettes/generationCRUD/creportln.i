/*------------------------------------------------------------------------
File        : creportln.i
Purpose     : Ficher des lignes de codes reportings
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCreportln
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cpt-cd   as character  initial ? 
    field etab-cd  as integer    initial ? 
    field ope      as logical    initial ? 
    field rub-cd   as integer    initial ? 
    field rubln-cd as integer    initial ? 
    field soc-cd   as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
