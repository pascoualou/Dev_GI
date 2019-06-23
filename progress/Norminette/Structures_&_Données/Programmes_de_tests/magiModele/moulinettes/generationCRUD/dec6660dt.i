/*------------------------------------------------------------------------
File        : dec6660dt.i
Purpose     : Table detail de la declaration 6660
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttDec6660dt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field annee         as integer    initial ? 
    field cdcsy         as character  initial ? 
    field cdmsy         as character  initial ? 
    field dtcsy         as date       initial ? 
    field dtmsy         as date       initial ? 
    field hecsy         as integer    initial ? 
    field hemsy         as integer    initial ? 
    field lbdiv         as character  initial ? 
    field lbdiv2        as character  initial ? 
    field lbdiv3        as character  initial ? 
    field noapp         as integer    initial ? 
    field nobail        as int64      initial ? 
    field noimm         as integer    initial ? 
    field nolot         as integer    initial ? 
    field nomdt         as integer    initial ? 
    field sfparprc      as decimal    initial ?  decimals 2
    field sfparscouv    as decimal    initial ?  decimals 2
    field sfparsnoncouv as decimal    initial ?  decimals 2
    field tpmdt         as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
