/*------------------------------------------------------------------------
File        : aeappel.i
Purpose     : table des appels de fond
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAeappel
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field appel-num      as character  initial ? 
    field cmpc-jou-cd    as character  initial ? 
    field cmpc-mandat-cd as integer    initial ? 
    field cmpc-nb        as integer    initial ? 
    field cmpc-piece-int as integer    initial ? 
    field cmpc-prd-cd    as integer    initial ? 
    field cmpc-prd-num   as integer    initial ? 
    field daeffet        as date       initial ? 
    field dev-cd         as character  initial ? 
    field etab-cd        as integer    initial ? 
    field fg-compta      as logical    initial ? 
    field fg-sup         as logical    initial ? 
    field fg-valid       as logical    initial ? 
    field jou-cd         as character  initial ? 
    field lib            as character  initial ? 
    field mt             as decimal    initial ?  decimals 2
    field mt-EURO        as decimal    initial ?  decimals 2
    field mtdev          as decimal    initial ?  decimals 2
    field natjou-gi      as character  initial ? 
    field piece-int      as integer    initial ? 
    field prd-cd         as integer    initial ? 
    field prd-num        as integer    initial ? 
    field soc-cd         as integer    initial ? 
    field typapp         as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
