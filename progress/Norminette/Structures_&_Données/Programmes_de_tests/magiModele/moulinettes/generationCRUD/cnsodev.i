/*------------------------------------------------------------------------
File        : cnsodev.i
Purpose     : recap non soldes en devises
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCnsodev
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cours      as decimal    initial ?  decimals 8
    field cpt-cd     as character  initial ? 
    field dafin      as date       initial ? 
    field dev-cd     as character  initial ? 
    field diff       as decimal    initial ?  decimals 2
    field diff-EURO  as decimal    initial ?  decimals 2
    field etab-cd    as integer    initial ? 
    field mt         as decimal    initial ?  decimals 2
    field mt-EURO    as decimal    initial ?  decimals 2
    field mtdev      as decimal    initial ?  decimals 2
    field soc-cd     as integer    initial ? 
    field sscoll-cle as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
