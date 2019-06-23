/*------------------------------------------------------------------------
File        : tthonmd
Purpose     : 
Author(s)   : DM  -  2017/11/20
Notes       : 
derniere revue: 2018/08/08 - phm: 
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttHonmd
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field tpcon        as character initial ?
    field nocon        as integer   initial ?
    field tptac        as character initial ?
    field tphon        as character initial ?
    field cdhon        as integer   initial ?
    field catbai       as character initial ?
    field noapp        as integer   initial ?
    field pdges        as character initial ?
    field lbdiv        as character initial ?
    field lbdiv2       as character initial ?
    field lbdiv3       as character initial ?
    field moisdeclench as integer   initial ?
    field Statutcpta   as character initial ?
    field Com-num      as integer   initial ?
    field statutPrec   as character initial ?
    field num-prec     as integer   initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
