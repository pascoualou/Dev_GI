/*------------------------------------------------------------------------
File        : cprub.i
Purpose     : 

Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCprub
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field etab-cd as integer    initial ? 
    field fg-div  as logical    initial ? 
    field fg-taxe as logical    initial ? 
    field lib-rub as character  initial ? 
    field lst-cpt as character  initial ? 
    field num-ord as integer    initial ? 
    field soc-cd  as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
