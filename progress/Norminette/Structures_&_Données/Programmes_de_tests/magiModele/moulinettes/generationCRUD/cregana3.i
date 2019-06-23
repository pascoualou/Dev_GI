/*------------------------------------------------------------------------
File        : cregana3.i
Purpose     : Regroupement analytique 3
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCregana3
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana3-cd as character  initial ? 
    field etab-cd as integer    initial ? 
    field grp-cd  as character  initial ? 
    field lib     as character  initial ? 
    field reg-cd  as character  initial ? 
    field soc-cd  as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
