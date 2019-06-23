/*------------------------------------------------------------------------
File        : entip.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttEntip
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdana     as character  initial ? 
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdmsy     as character  initial ? 
    field cdtva     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtdpo     as date       initial ? 
    field dtfpo     as date       initial ? 
    field dtimp     as date       initial ? 
    field dtmsy     as date       initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field lbimp     as character  initial ? 
    field lbrec     as character  initial ? 
    field mtttc     as decimal    initial ?  decimals 2
    field mtttc-dev as decimal    initial ?  decimals 2
    field mtttr     as decimal    initial ?  decimals 2
    field mtttr-dev as decimal    initial ?  decimals 2
    field mttva     as decimal    initial ?  decimals 2
    field mttva-dev as decimal    initial ?  decimals 2
    field mttvr     as decimal    initial ?  decimals 2
    field mttvr-dev as decimal    initial ?  decimals 2
    field nocle     as character  initial ? 
    field nocon     as int64      initial ? 
    field nocon-dec as decimal    initial ?  decimals 0
    field nocre     as character  initial ? 
    field noimm     as integer    initial ? 
    field tpcon     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
