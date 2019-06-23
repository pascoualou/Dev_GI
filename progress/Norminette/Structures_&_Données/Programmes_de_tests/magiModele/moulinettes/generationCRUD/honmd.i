/*------------------------------------------------------------------------
File        : honmd.i
Purpose     : lien mandat - bareme hono (+ categ ou UL)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttHonmd
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field catbai       as character  initial ? 
    field cdcsy        as character  initial ? 
    field cdhon        as integer    initial ? 
    field cdmsy        as character  initial ? 
    field Com-num      as integer    initial ? 
    field dtcsy        as date       initial ? 
    field dtmsy        as date       initial ? 
    field hecsy        as integer    initial ? 
    field hemsy        as integer    initial ? 
    field lbdiv        as character  initial ? 
    field lbdiv2       as character  initial ? 
    field lbdiv3       as character  initial ? 
    field moisdeclench as integer    initial ? 
    field noapp        as integer    initial ? 
    field nocon        as integer    initial ? 
    field num-prec     as integer    initial ? 
    field pdges        as character  initial ? 
    field Statutcpta   as character  initial ? 
    field statutPrec   as character  initial ? 
    field tpcon        as character  initial ? 
    field tphon        as character  initial ? 
    field tptac        as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
