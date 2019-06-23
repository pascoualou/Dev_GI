/*------------------------------------------------------------------------
File        : cengcpta.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCengcpta
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana-cd       as character  initial ? 
    field cpt-cd       as character  initial ? 
    field dacompta     as date       initial ? 
    field etab-cd      as integer    initial ? 
    field jou-cd       as character  initial ? 
    field lig          as integer    initial ? 
    field mt           as decimal    initial ?  decimals 2
    field niv-num      as integer    initial ? 
    field num-int      as integer    initial ? 
    field piece-compta as integer    initial ? 
    field prd-cd       as integer    initial ? 
    field prd-num      as integer    initial ? 
    field rub-cd       as integer    initial ? 
    field sens         as logical    initial ? 
    field soc-cd       as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
