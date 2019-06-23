/*------------------------------------------------------------------------
File        : acomp.i
Purpose     : table des compensations
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAcomp
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field appel-num      as character  initial ? 
    field cmpc-jou-cd    as character  initial ? 
    field cmpc-mandat-cd as integer    initial ? 
    field cmpc-piece-int as integer    initial ? 
    field cmpc-prd-cd    as integer    initial ? 
    field cmpc-prd-num   as integer    initial ? 
    field cmpg-jou-cd    as character  initial ? 
    field cmpg-mandat-cd as integer    initial ? 
    field cmpg-manu-int  as integer    initial ? 
    field cmpg-mt        as decimal    initial ?  decimals 2
    field cmpg-mt-EURO   as decimal    initial ?  decimals 2
    field cmpg-piece-int as integer    initial ? 
    field cmpg-prd-cd    as integer    initial ? 
    field cmpg-prd-num   as integer    initial ? 
    field datecr         as date       initial ? 
    field fg-sup         as logical    initial ? 
    field natjou-gi      as character  initial ? 
    field soc-cd         as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
