/*------------------------------------------------------------------------
File        : aloyd.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAloyd
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdmat     as character  initial ? 
    field cdmsy     as character  initial ? 
    field cdsec     as character  initial ? 
    field cduni     as character  initial ? 
    field drexp     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtmsy     as date       initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field msqtt     as integer    initial ? 
    field mtini     as decimal    initial ?  decimals 2
    field mtini-dev as decimal    initial ?  decimals 2
    field mtsai     as decimal    initial ?  decimals 2
    field mtsai-dev as decimal    initial ?  decimals 2
    field nocon     as decimal    initial ?  decimals 0
    field rubpa     as character  initial ? 
    field tpcon     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
