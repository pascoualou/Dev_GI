/*------------------------------------------------------------------------
File        : aquit.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
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
    field dacompta    as date       initial ? 
    field dtcsy       as date       initial ? 
    field dtdeb       as date       initial ? 
    field dtdpr       as date       initial ? 
    field dteff       as date       initial ? 
    field dtems       as date       initial ? 
    field dtent       as date       initial ? 
    field dtfin       as date       initial ? 
    field dtfpr       as date       initial ? 
    field dtmsy       as date       initial ? 
    field dtrev       as date       initial ? 
    field DtSolde     as date       initial ? 
    field dtsor       as date       initial ? 
    field dttrf       as date       initial ? 
    field dubai       as integer    initial ? 
    field FgDetail    as logical    initial ? 
    field FgFac       as logical    initial ? 
    field fgqttav     as logical    initial ? 
    field FgTrf       as logical    initial ? 
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
    field mtqtt       as decimal    initial ?  decimals 2
    field mtqtt-dev   as decimal    initial ?  decimals 2
    field mtSolde     as decimal    initial ?  decimals 2
    field nbden       as integer    initial ? 
    field nbech       as integer    initial ? 
    field nbnum       as integer    initial ? 
    field nbrub       as integer    initial ? 
    field noimm       as integer    initial ? 
    field noint       as int64      initial ? 
    field noloc       as int64      initial ? 
    field noloc-dec   as decimal    initial ?  decimals 0
    field nomdt       as integer    initial ? 
    field noqtt       as integer    initial ? 
    field ntbai       as character  initial ? 
    field num-int-fac as integer    initial ? 
    field pdqtt       as character  initial ? 
    field tbechDate   as date       initial ? 
    field tbEchMtqtt  as decimal    initial ?  decimals 2
    field tbechmtSld  as decimal    initial ?  decimals 2
    field tbmntenc    as decimal    initial ?  decimals 2
    field tbNochrono  as integer    initial ? 
    field tbrub       as character  initial ? 
    field tbrub-dev   as character  initial ? 
    field tbrubenc    as integer    initial ? 
    field tbtpchrono  as character  initial ? 
    field type-fac    as character  initial ? 
    field utdur       as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
