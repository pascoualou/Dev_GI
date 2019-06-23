/*------------------------------------------------------------------------
File        : apfet.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttApfet
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdeta     as integer    initial ? 
    field cdmsy     as character  initial ? 
    field dtapp     as date       initial ? 
    field dtcsy     as date       initial ? 
    field dtmsy     as date       initial ? 
    field dttrf     as date       initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbapp     as character  initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field mtapp     as decimal    initial ?  decimals 2
    field mtapp-dev as decimal    initial ?  decimals 2
    field noapp     as integer    initial ? 
    field nocpt     as integer    initial ? 
    field nofon     as int64      initial ? 
    field noimm     as integer    initial ? 
    field noscp     as integer    initial ? 
    field tpapf     as character  initial ? 
    field tpapp     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
