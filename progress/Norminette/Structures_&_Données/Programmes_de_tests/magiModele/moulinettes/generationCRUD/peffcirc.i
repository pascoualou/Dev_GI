/*------------------------------------------------------------------------
File        : peffcirc.i
Purpose     : Effets en circulation
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPeffcirc
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field bq-dacompta  as date       initial ? 
    field bq-flag      as logical    initial ? 
    field bq-jou-cd    as character  initial ? 
    field bq-piece-int as integer    initial ? 
    field bq-prd-cd    as integer    initial ? 
    field bq-prd-num   as integer    initial ? 
    field chq-eff      as logical    initial ? 
    field coll-cle     as character  initial ? 
    field cours        as decimal    initial ?  decimals 8
    field cpt-cd       as character  initial ? 
    field dacompta     as date       initial ? 
    field daech        as date       initial ? 
    field dev-cd       as character  initial ? 
    field devetr-cd    as character  initial ? 
    field etab-cd      as integer    initial ? 
    field jou-cd       as character  initial ? 
    field lib          as character  initial ? 
    field libtier-cd   as integer    initial ? 
    field lig-tot      as integer    initial ? 
    field mt           as decimal    initial ?  decimals 2
    field mt-EURO      as decimal    initial ?  decimals 2
    field mtdev        as decimal    initial ?  decimals 2
    field piece-int    as integer    initial ? 
    field prd-cd       as integer    initial ? 
    field prd-num      as integer    initial ? 
    field sens         as logical    initial ? 
    field soc-cd       as integer    initial ? 
    field sscoll-cle   as character  initial ? 
    field tiers-cle    as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
