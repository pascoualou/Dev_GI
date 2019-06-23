/*------------------------------------------------------------------------
File        : ijouprd.i
Purpose     : Periode de journal
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIjouprd
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field etab-cd as integer    initial ? 
    field jou-cd  as character  initial ? 
    field prd-cd  as integer    initial ? 
    field prd-num as integer    initial ? 
    field soc-cd  as integer    initial ? 
    field statut  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
