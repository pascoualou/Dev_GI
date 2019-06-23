/*------------------------------------------------------------------------
File        : unite.i
Description : 
Author(s)   : gga - 2017/08/23
Notes       : champs techniques utiles pour cette table
derniere revue: 2018/08/08 - phm: 
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttUnite
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field noman        as integer   initial ?
    field nomdt        as integer   initial ?
    field noapp        as integer   initial ?
    field noact        as integer   initial ?
    field nocmp        as integer   initial ?
    field cdcmp        as character initial ?
    field dtdeb        as date
    field dtfin        as date
    field noimm        as integer   initial ?
    field nolot        as integer   initial ?
    field nolie        as int64     initial ?
    field cdocc        as character initial ?
    field tprol        as character initial ?
    field norol        as int64     initial ?
    field dtent        as date
    field dtsor        as date
    field tpfin        as character initial ?
    field mtloy        as decimal   initial ? decimals 2
    field mtpro        as decimal   initial ? decimals 2
    field mtpro-dev    as decimal   initial ? decimals 2
    field mtloy-dev    as decimal   initial ? decimals 2
    field cddev        as character initial ?
    field lbdiv        as character initial ?
    field lbdiv2       as character initial ?
    field lbdiv3       as character initial ?
    field norol-dec    as decimal   initial ? decimals 0
    field dtdebindis   as date
    field dtfinindis   as date
    field cdmotindis   as character initial ?
    field cdusa        as character initial ?

    field cdcsy     as character  initial ?
    field cdmsy     as character  initial ?
    field dtcsy     as date
    field dtmsy     as date
    field hecsy     as integer    initial ?
    field hemsy     as integer    initial ?

    field dtTimestamp  as datetime
    field CRUD         as character
    field rRowid       as rowid
.
