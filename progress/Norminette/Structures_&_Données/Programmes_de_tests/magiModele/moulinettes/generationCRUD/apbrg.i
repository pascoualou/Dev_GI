/*------------------------------------------------------------------------
File        : apbrg.i
Purpose     : appel de fonds de régularisation
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttApbrg
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcle     as character  initial ? 
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdmsy     as character  initial ? 
    field cdtrt     as character  initial ? 
    field dtapp     as date       initial ? 
    field dtcsy     as date       initial ? 
    field dtmsy     as date       initial ? 
    field dttrf     as date       initial ? 
    field fgsel     as logical    initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field hetrf     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field mtecr     as decimal    initial ?  decimals 2
    field mtecr-dev as decimal    initial ?  decimals 2
    field mtsai     as decimal    initial ?  decimals 2
    field mtsai-dev as decimal    initial ?  decimals 2
    field noapp     as integer    initial ? 
    field noarg     as integer    initial ? 
    field nobud     as int64      initial ? 
    field nobud-dec as decimal    initial ?  decimals 0
    field nocop     as integer    initial ? 
    field noecr     as integer    initial ? 
    field noimm     as integer    initial ? 
    field nolot     as integer    initial ? 
    field nomdt     as integer    initial ? 
    field noord     as integer    initial ? 
    field tblib     as character  initial ? 
    field tpapp     as character  initial ? 
    field tparg     as character  initial ? 
    field tpbud     as character  initial ? 
    field tplig     as character  initial ? 
    field tvecr     as decimal    initial ?  decimals 2
    field tvecr-dev as decimal    initial ?  decimals 2
    field tvsai     as decimal    initial ?  decimals 2
    field tvsai-dev as decimal    initial ?  decimals 2
    field vltan     as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
