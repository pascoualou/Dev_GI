/*------------------------------------------------------------------------
File        : cumsa.i
Purpose     : 
Author(s)   : generation automatique le 04/27/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCumsa
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field antrt     as integer    initial ?
    field cdcsy     as character  initial ?
    field cddev     as character  initial ?
    field cdmsy     as character  initial ?
    field dtcsy     as date      
    field dtems     as date      
    field dtmsy     as date      
    field hecsy     as integer    initial ?
    field hemsy     as integer    initial ?
    field lbcum     as character  initial ?
    field lbdiv     as character  initial ?
    field lbdiv2    as character  initial ?
    field lbdiv3    as character  initial ?
    field mtcex     as decimal    initial ? decimals 2
    field mtcgi     as decimal    initial ? decimals 2
    field mtcum     as decimal    initial ? decimals 2
    field mtcum-dev as decimal    initial ? decimals 2
    field nomdt     as integer    initial ?
    field nomod     as integer    initial ?
    field norol     as int64      initial ?
    field tpmdt     as character  initial ?
    field tprol     as character  initial ?
    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
