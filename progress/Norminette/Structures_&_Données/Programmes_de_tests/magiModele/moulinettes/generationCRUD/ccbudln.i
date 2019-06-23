/*------------------------------------------------------------------------
File        : ccbudln.i
Purpose     : fichier de construction des lignes de budget general
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCcbudln
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field budget-cd as character  initial ? 
    field cpt-cd    as character  initial ? 
    field etab-cd   as integer    initial ? 
    field mt        as decimal    initial ?  decimals 2
    field mt-EURO   as decimal    initial ?  decimals 2
    field prd-cd    as integer    initial ? 
    field prd-num   as integer    initial ? 
    field rub-cd    as integer    initial ? 
    field soc-cd    as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
