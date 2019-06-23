/*------------------------------------------------------------------------
File        : pquit.i
Purpose     : 
Author(s)   : generation automatique le 04/27/18
Notes       :
derniere revue: 2018/08/13 - phm:
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPquit
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcor     as character initial ?
    field cddep     as character initial ?
    field cddev     as character initial ?
    field cdprs     as character initial ?
    field cdprv     as character initial ?
    field cdquo     as integer   initial ?
    field cdrev     as character initial ?
    field cdsol     as character initial ?
    field cdter     as character initial ?
    field dtdeb     as date
    field dtdpr     as date
    field dteff     as date
    field dtent     as date
    field dtfin     as date
    field dtfpr     as date
    field dtprv     as date
    field dtrev     as date
    field dtsor     as date
    field dubai     as integer   initial ?
    field fgtrf     as logical   initial ?
    field lbdiv     as character initial ?
    field lbdiv2    as character initial ?
    field lbdiv3    as character initial ?
    field mdreg     as character initial ?
    field msqtt     as integer   initial ?
    field msqui     as integer   initial ?
    field mtqtt     as decimal   initial ? decimals 2
    field mtqtt-dev as decimal   initial ? decimals 2
    field nbden     as integer   initial ?
    field nbedt     as integer   initial ?
    field nbnum     as integer   initial ?
    field nbrub     as integer   initial ?
    field noidc     as integer   initial ?
    field noimm     as integer   initial ?
    field noint     as int64     initial ?
    field noloc     as int64     initial ?
    field noloc-dec as decimal   initial ? decimals 0
    field nomdt     as integer   initial ?
    field noqtt     as integer   initial ?
    field ntbai     as character initial ?
    field pdidc     as character initial ?
    field pdqtt     as character initial ?
    field tbden     as integer   initial ?
    field tbdet     as character initial ?
    field tbdt1     as date
    field tbdt2     as date
    field tbfam     as integer   initial ?
    field tbfil     as character initial ?
    field tbgen     as character initial ?
    field tblib     as integer   initial ?
    field tbmtq     as decimal   initial ? decimals 2
    field tbmtq-dev as decimal   initial ? decimals 2
    field tbnum     as integer   initial ?
    field tbpro     as integer   initial ?
    field tbpun     as decimal   initial ? decimals 4
    field tbpun-dev as decimal   initial ? decimals 4
    field tbqte     as decimal   initial ? decimals 4
    field tbrub     as integer   initial ?
    field tbsfa     as integer   initial ?
    field tbsig     as character initial ?
    field tbtot     as decimal   initial ? decimals 2
    field tbtot-dev as decimal   initial ? decimals 2
    field tpidc     as character initial ?
    field utdur     as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
