/*------------------------------------------------------------------------
File        : istatfour.i
Purpose     : Statistiques concernant les fournisseurs.
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIstatfour
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field caht      as decimal    initial ?  decimals 2
    field caht-EURO as decimal    initial ?  decimals 2
    field etab-cd   as integer    initial ? 
    field four-cle  as character  initial ? 
    field prd-cd    as integer    initial ? 
    field prd-num   as integer    initial ? 
    field soc-cd    as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
