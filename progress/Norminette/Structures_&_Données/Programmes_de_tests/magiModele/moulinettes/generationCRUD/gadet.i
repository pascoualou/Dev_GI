/*------------------------------------------------------------------------
File        : gadet.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttGadet
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field agence   as integer    initial ? 
    field cdcsy    as character  initial ? 
    field cdmsy    as character  initial ? 
    field cdrub    as character  initial ? 
    field cdsru    as character  initial ? 
    field dtcsy    as date       initial ? 
    field dtfin    as date       initial ? 
    field dtmsy    as date       initial ? 
    field dtref    as date       initial ? 
    field hecsy    as integer    initial ? 
    field hemsy    as integer    initial ? 
    field lbdiv    as character  initial ? 
    field lbdiv2   as character  initial ? 
    field lbdiv3   as character  initial ? 
    field mtbud    as decimal    initial ?  decimals 2
    field mtfactu  as decimal    initial ?  decimals 2
    field MtPrevis as decimal    initial ?  decimals 2
    field mtree    as decimal    initial ?  decimals 2
    field noct1    as int64      initial ? 
    field noct2    as int64      initial ? 
    field noctt    as decimal    initial ?  decimals 0
    field noexe    as integer    initial ? 
    field noidt    as int64      initial ? 
    field nolib    as integer    initial ? 
    field nolig    as integer    initial ? 
    field noord    as integer    initial ? 
    field notac    as integer    initial ? 
    field tpct1    as character  initial ? 
    field tpct2    as character  initial ? 
    field tpctt    as character  initial ? 
    field tpidt    as character  initial ? 
    field TpPrevis as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
