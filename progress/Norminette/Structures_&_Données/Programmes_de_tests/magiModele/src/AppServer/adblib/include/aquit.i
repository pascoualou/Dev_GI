/*------------------------------------------------------------------------
File        : aquit.i
Purpose     : 
Author(s)   : generation automatique le 04/27/18
Notes       :
derniere revue: 2018/05/14 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAquit
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy       as character  initial ?
    field cddev       as character  initial ?
    field cdmsy       as character  initial ?
    field cdquo       as integer    initial ?
    field cdter       as character  initial ?
    field dacompta    as date
    field dtcsy       as date
    field dtdeb       as date
    field dtdpr       as date
    field dteff       as date
    field dtems       as date
    field dtent       as date
    field dtfin       as date
    field dtfpr       as date
    field dtmsy       as date
    field dtrev       as date
    field dtsolde     as date
    field dtsor       as date
    field dttrf       as date
    field dubai       as integer    initial ?
    field fgdetail    as logical    initial ?
    field fgfac       as logical    initial ?
    field fgqttav     as logical    initial ?
    field fgtrf       as logical    initial ?
    field hecsy       as integer    initial ?
    field hemsy       as integer    initial ?
    field idbai       as character  initial ?
    field lbdiv       as character  initial ?
    field lbdiv2      as character  initial ?
    field lbdiv3      as character  initial ?
    field mdreg       as character  initial ?
    field msqtt       as integer    initial ?
    field msqtt-edt   as integer    initial ?
    field msqui       as integer    initial ?
    field mstrt-fac   as integer    initial ?
    field mtqtt       as decimal    initial ? decimals 2
    field mtqtt-dev   as decimal    initial ? decimals 2
    field mtsolde     as decimal    initial ? decimals 2
    field nbden       as integer    initial ?
    field nbech       as integer    initial ?
    field nbnum       as integer    initial ?
    field nbrub       as integer    initial ?
    field noimm       as integer    initial ?
    field noint       as int64      initial ?
    field noloc       as int64      initial ?
    field noloc-dec   as decimal    initial ? decimals 0
    field nomdt       as integer    initial ?
    field noqtt       as integer    initial ?
    field ntbai       as character  initial ?
    field num-int-fac as integer    initial ?
    field pdqtt       as character  initial ?
    field tbechdate   as date
    field tbechmtqtt  as decimal    initial ? decimals 2
    field tbechmtsld  as decimal    initial ? decimals 2
    field tbmntenc    as decimal    initial ? decimals 2
    field tbnochrono  as integer    initial ?
    field tbrub       as character  initial ?
    field tbrub-dev   as character  initial ?
    field tbrubenc    as integer    initial ?
    field tbtpchrono  as character  initial ?
    field type-fac    as character  initial ?
    field utdur       as character  initial ?
    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
