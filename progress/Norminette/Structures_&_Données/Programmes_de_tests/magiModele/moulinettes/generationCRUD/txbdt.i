/*------------------------------------------------------------------------
File        : txbdt.i
Purpose     : Table detail de la taxe sur bureaux
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTxbdt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field annee     as integer    initial ? 
    field cdcsy     as character  initial ? 
    field cdmsy     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtmsy     as date       initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field mtbur     as decimal    initial ?  decimals ?
    field mtbur-dev as decimal    initial ?  decimals ?
    field mtcom     as decimal    initial ?  decimals ?
    field mtcom-dev as decimal    initial ?  decimals ?
    field mtpkg     as decimal    initial ?  decimals ?
    field mtstk     as decimal    initial ?  decimals ?
    field mtstk-dev as decimal    initial ?  decimals ?
    field noimm     as integer    initial ? 
    field noloc     as int64      initial ? 
    field noloc-dec as decimal    initial ?  decimals 0
    field nolot     as integer    initial ? 
    field noman     as integer    initial ? 
    field nomdt     as integer    initial ? 
    field noulo     as integer    initial ? 
    field sfbur     as decimal    initial ?  decimals ?
    field sfcom     as decimal    initial ?  decimals ?
    field sfpkg     as decimal    initial ?  decimals 2
    field sfstk     as decimal    initial ?  decimals ?
    field tpbar     as character  initial ? 
    field tpzon     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
