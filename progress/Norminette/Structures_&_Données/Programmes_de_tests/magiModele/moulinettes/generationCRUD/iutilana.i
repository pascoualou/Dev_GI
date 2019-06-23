/*------------------------------------------------------------------------
File        : iutilana.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIutilana
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana-cd  as character  initial ? 
    field etab-cd as integer    initial ? 
    field ident_u as character  initial ? 
    field niv-num as integer    initial ? 
    field soc-cd  as integer    initial ? 
    field type    as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
