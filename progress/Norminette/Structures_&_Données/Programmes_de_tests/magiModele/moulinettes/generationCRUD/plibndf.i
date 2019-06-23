/*------------------------------------------------------------------------
File        : plibndf.i
Purpose     : Fichier Table notes de frais
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPlibndf
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cpt-cd    as character  initial ? 
    field etab-cd   as integer    initial ? 
    field lib       as character  initial ? 
    field libndf-cd as integer    initial ? 
    field mt2       as decimal    initial ?  decimals 2
    field mt2-EURO  as decimal    initial ?  decimals 2
    field signe     as character  initial ? 
    field soc-cd    as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
