/*------------------------------------------------------------------------
File        : eqprov.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttEqprov
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdmsy     as character  initial ? 
    field cdter     as character  initial ? 
    field dacpta    as date       initial ? 
    field dtcsy     as date       initial ? 
    field dtdeb     as date       initial ? 
    field dtdpr     as date       initial ? 
    field dtent     as date       initial ? 
    field dtfin     as date       initial ? 
    field dtfpr     as date       initial ? 
    field dtmsy     as date       initial ? 
    field dtsor     as date       initial ? 
    field fgcpta    as logical    initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field msqpv     as integer    initial ? 
    field msqtt     as integer    initial ? 
    field msqui     as integer    initial ? 
    field mtqtt     as decimal    initial ?  decimals 2
    field mtqtt-dev as decimal    initial ?  decimals 2
    field noimm     as integer    initial ? 
    field noint     as integer    initial ? 
    field noloc     as int64      initial ? 
    field nomdt     as integer    initial ? 
    field noqtt     as integer    initial ? 
    field pdqtt     as character  initial ? 
    field tblib     as integer    initial ? 
    field tbmtq     as decimal    initial ?  decimals 2
    field tbmtq-dev as decimal    initial ?  decimals 2
    field tbrub     as integer    initial ? 
    field tbtot     as decimal    initial ?  decimals 2
    field tbtot-dev as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
