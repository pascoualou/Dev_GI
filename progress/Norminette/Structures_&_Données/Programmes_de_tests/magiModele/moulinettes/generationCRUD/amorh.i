/*------------------------------------------------------------------------
File        : amorh.i
Purpose     : Historique amortissements calculés
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAmorh
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcal     as character  initial ? 
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdmsy     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtdeb-amo as date       initial ? 
    field dtfin-amo as date       initial ? 
    field dtmsy     as date       initial ? 
    field fgtmp     as logical    initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field msqtt     as integer    initial ? 
    field msqui     as integer    initial ? 
    field mtal0     as decimal    initial ?  decimals 2
    field mtal0-dev as decimal    initial ?  decimals 2
    field mtal1     as decimal    initial ?  decimals 2
    field mtal1-dev as decimal    initial ?  decimals 2
    field mtam0     as decimal    initial ?  decimals 2
    field mtam0-dev as decimal    initial ?  decimals 2
    field mtam1     as decimal    initial ?  decimals 2
    field mtam1-dev as decimal    initial ?  decimals 2
    field mtanx     as decimal    initial ?  decimals 2
    field mtanx-dev as decimal    initial ?  decimals 2
    field mtass     as decimal    initial ?  decimals 2
    field mtass-dev as decimal    initial ?  decimals 2
    field mtcl0     as decimal    initial ?  decimals 2
    field mtcl0-dev as decimal    initial ?  decimals 2
    field mtcl1     as decimal    initial ?  decimals 2
    field mtcl1-dev as decimal    initial ?  decimals 2
    field mthab     as decimal    initial ?  decimals 2
    field mthab-dev as decimal    initial ?  decimals 2
    field mtloy     as decimal    initial ?  decimals 2
    field mtpro     as decimal    initial ?  decimals 2
    field mtpro-dev as decimal    initial ?  decimals 2
    field mtsup     as decimal    initial ?  decimals 2
    field mtsup-dev as decimal    initial ?  decimals 2
    field nbjou     as integer    initial ? 
    field nocon     as int64      initial ? 
    field nocon-dec as decimal    initial ?  decimals 0
    field nofic     as integer    initial ? 
    field pcall     as decimal    initial ?  decimals 2
    field pcamo     as decimal    initial ?  decimals 2
    field pcass     as decimal    initial ?  decimals 2
    field tpcon     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
