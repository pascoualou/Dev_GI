/*------------------------------------------------------------------------
File        : equit.i
Purpose     : 
Author(s)   : Kantena 02/01/2018
Notes       : les extent 20 contiennent les caractéristiques des 1 à 20 rubriques de la quittance
derniere revue: 2018/08/13 - phm: 
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttEquit 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcor       as character initial ?
    field cddep       as character initial ?
    field cddev       as character initial ?
    field cdprs       as character initial ?
    field cdprv       as character initial ?
    field cdquo       as integer   initial ?
    field cdrev       as character initial ?
    field cdsol       as character initial ?
    field cdter       as character initial ?
    field dtdeb       as date
    field dtdpr       as date
    field dteff       as date
    field dtent       as date
    field dtfin       as date
    field dtfpr       as date
    field dtprv       as date
    field dtrev       as date
    field dtSolde     as date
    field dtsor       as date
    field dttrf       as date
    field dubai       as integer   initial ?
    field fgtrf       as logical   initial ?
    field lbdiv       as character initial ?
    field lbdiv2      as character initial ?
    field lbdiv3      as character initial ?
    field mdreg       as character initial ?
    field msqtt       as integer   initial ?
    field msqui       as integer   initial ?
    field mtqtt       as decimal   initial ?           decimals 2
    field mtqtt-dev   as decimal   initial ?           decimals 2
    field mtSolde     as decimal   initial ?           decimals 2
    field nbden       as integer   initial ?
    field nbech       as integer   initial ?
    field nbedt       as integer   initial ?
    field nbnum       as integer   initial ?
    field nbrub       as integer   initial ?
    field noidc       as integer   initial ?
    field noimm       as integer   initial ?
    field noint       as int64     initial ?
    field noloc       as int64     initial ?
    field noloc-dec   as decimal   initial ?           decimals 0
    field nomdt       as integer   initial ?
    field noqtt       as integer   initial ?
    field ntbai       as character initial ?
    field pdidc       as character initial ?
    field pdqtt       as character initial ?
    field tbden       as integer   initial ? extent 20
    field tbdet       as character initial ? extent 20
    field tbdt1       as date                extent 20
    field tbdt2       as date                extent 20
    field tbechDate   as date                extent 6
    field tbEchMtqtt  as decimal   initial ? extent 6  decimals 2
    field tbechmtSld  as decimal   initial ? extent 6  decimals 2
    field tbfam       as integer   initial ? extent 20
    field tbfil       as character initial ? extent 20
    field tbgen       as character initial ? extent 20
    field tblib       as integer   initial ? extent 20
    field tbmntenc    as decimal   initial ? extent 20 decimals 2
    field tbmtq       as decimal   initial ? extent 20 decimals 2
    field tbmtq-dev   as decimal   initial ? extent 20 decimals 2
    field tbNochrono  as integer   initial ? extent 5
    field tbnum       as integer   initial ? extent 20
    field tbpro       as integer   initial ? extent 20
    field tbpun       as decimal   initial ? extent 20 decimals 4
    field tbpun-dev   as decimal   initial ? extent 20 decimals 4
    field tbqte       as decimal   initial ? extent 20 decimals 4
    field tbrub       as integer   initial ? extent 20
    field tbrubenc    as integer   initial ? extent 20
    field tbsfa       as integer   initial ? extent 20
    field tbsig       as character initial ? extent 20
    field tbtot       as decimal   initial ? extent 20 decimals 2
    field tbtot-dev   as decimal   initial ? extent 20 decimals 2
    field tbtpchrono  as character initial ? extent 5
    field tpidc       as character initial ?
    field utdur       as character initial ?
    field cdcsy       as character  initial ? 
    field cdmsy       as character  initial ? 
    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.