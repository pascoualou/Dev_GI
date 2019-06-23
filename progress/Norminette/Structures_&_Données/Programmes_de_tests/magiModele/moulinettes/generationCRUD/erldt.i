/*------------------------------------------------------------------------
File        : erldt.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttErldt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ancco     as decimal    initial ?  decimals 3
    field ancix     as decimal    initial ?  decimals 3
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdmsy     as character  initial ? 
    field conso     as decimal    initial ?  decimals 3
    field dtcsy     as date       initial ? 
    field dtmsy     as date       initial ? 
    field dttva     as decimal    initial ?  decimals 3
    field dttva-dev as decimal    initial ?  decimals 3
    field fgest     as logical    initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field mtlig     as decimal    initial ?  decimals 2
    field mtlig-dev as decimal    initial ?  decimals 2
    field newix     as decimal    initial ?  decimals 3
    field nmcop     as character  initial ? 
    field nocop     as integer    initial ? 
    field nocpt     as character  initial ? 
    field nolot     as integer    initial ? 
    field norli     as integer    initial ? 
    field norlv     as integer    initial ? 
    field ntlot     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
