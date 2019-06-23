/*------------------------------------------------------------------------
File        : eqprov.i
Purpose     : 
Author(s)   : generation automatique le 04/27/18
Notes       :
derniere revue: 2018/08/07 - phm: 
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttEqprov
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cddev     as character initial ?
    field cdter     as character initial ?
    field dacpta    as date
    field dtdeb     as date
    field dtdpr     as date
    field dtent     as date
    field dtfin     as date
    field dtfpr     as date
    field dtsor     as date
    field fgcpta    as logical   initial ?
    field lbdiv     as character initial ?
    field lbdiv2    as character initial ?
    field lbdiv3    as character initial ?
    field msqpv     as integer   initial ?
    field msqtt     as integer   initial ?
    field msqui     as integer   initial ?
    field mtqtt     as decimal   initial ? decimals 2
    field mtqtt-dev as decimal   initial ? decimals 2
    field noimm     as integer   initial ?
    field noint     as integer   initial ?
    field noloc     as int64     initial ?
    field nomdt     as integer   initial ?
    field noqtt     as integer   initial ?
    field pdqtt     as character initial ?
    field tblib     as integer   initial ?
    field tbmtq     as decimal   initial ? decimals 2
    field tbmtq-dev as decimal   initial ? decimals 2
    field tbrub     as integer   initial ?
    field tbtot     as decimal   initial ? decimals 2
    field tbtot-dev as decimal   initial ? decimals 2

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
