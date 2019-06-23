/*------------------------------------------------------------------------
File        : amor2.i
Purpose     : Echéancier amort. locataires
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAmor2
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field annep     as integer    initial ? 
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdmsy     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtmsy     as date       initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field moisp     as integer    initial ? 
    field mtamo     as decimal    initial ?  decimals 2
    field mtamo-dev as decimal    initial ?  decimals 2
    field nocon     as int64      initial ? 
    field nocon-dec as decimal    initial ?  decimals 0
    field nofic     as integer    initial ? 
    field tpcon     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
