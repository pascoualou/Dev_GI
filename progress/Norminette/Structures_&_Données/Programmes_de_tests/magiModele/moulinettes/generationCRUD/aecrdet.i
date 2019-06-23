/*------------------------------------------------------------------------
File        : aecrdet.i
Purpose     : Détails d'écritures
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAecrdet
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdfam     as integer    initial ? 
    field etab-cd   as integer    initial ? 
    field jou-cd    as character  initial ? 
    field lig       as integer    initial ? 
    field mt        as decimal    initial ?  decimals 2
    field mt-EURO   as decimal    initial ?  decimals 2
    field natjou-gi as character  initial ? 
    field piece-int as integer    initial ? 
    field prd-cd    as integer    initial ? 
    field prd-num   as integer    initial ? 
    field soc-cd    as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
