/*------------------------------------------------------------------------
File        : equitrev.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttEquitrev
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field anper     as integer    initial ? 
    field cdcsy     as character  initial ? 
    field cdirv     as integer    initial ? 
    field cdmsy     as character  initial ? 
    field cdquo     as integer    initial ? 
    field cdrev     as character  initial ? 
    field cdter     as character  initial ? 
    field daterevis as date       initial ? 
    field dtcsy     as date       initial ? 
    field dtdeb     as date       initial ? 
    field dtdpr     as date       initial ? 
    field dteff     as date       initial ? 
    field dtent     as date       initial ? 
    field dtfin     as date       initial ? 
    field dtfpr     as date       initial ? 
    field dtmsy     as date       initial ? 
    field dtsor     as date       initial ? 
    field dttrf     as date       initial ? 
    field dubai     as integer    initial ? 
    field fgtrf     as logical    initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field mdreg     as character  initial ? 
    field msqtt     as integer    initial ? 
    field msqui     as integer    initial ? 
    field mtqtt     as decimal    initial ?  decimals 2
    field nbden     as integer    initial ? 
    field nbnum     as integer    initial ? 
    field nbrub     as integer    initial ? 
    field noimm     as integer    initial ? 
    field noloc     as decimal    initial ?  decimals 0
    field nomdt     as integer    initial ? 
    field noord     as integer    initial ? 
    field noper     as integer    initial ? 
    field noqtt     as integer    initial ? 
    field ntbai     as character  initial ? 
    field pdqtt     as character  initial ? 
    field tbden     as integer    initial ? 
    field tbdet     as character  initial ? 
    field tbdt1     as date       initial ? 
    field tbdt2     as date       initial ? 
    field tbfam     as integer    initial ? 
    field tbfil     as character  initial ? 
    field tbgen     as character  initial ? 
    field tblib     as integer    initial ? 
    field tbmtq     as decimal    initial ?  decimals 2
    field tbnum     as integer    initial ? 
    field tbpro     as integer    initial ? 
    field tbpun     as decimal    initial ?  decimals 4
    field tbqte     as decimal    initial ?  decimals 4
    field tbrub     as integer    initial ? 
    field tbsfa     as integer    initial ? 
    field tbsig     as character  initial ? 
    field tbtot     as decimal    initial ?  decimals 2
    field txirv     as decimal    initial ?  decimals 8
    field utdur     as character  initial ? 
    field vlirv     as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
