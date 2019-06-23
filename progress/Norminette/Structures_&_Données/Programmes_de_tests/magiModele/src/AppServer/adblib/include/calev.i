/*------------------------------------------------------------------------
File        : calev.i
Purpose     : Calendrier d'evolution des loyers
Author(s)   : generation automatique le 04/27/18
Notes       :
derniere revue: 2018/05/14 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCalev
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy     as character  initial ?
    field cddev     as character  initial ?
    field cdlib     as integer    initial ?
    field cdmsy     as character  initial ?
    field cdrub     as integer    initial ?
    field dtcal     as date
    field dtcsy     as date
    field dtdeb     as date
    field dtfin     as date
    field dtmsy     as date
    field hecsy     as integer    initial ?
    field hemsy     as integer    initial ?
    field lbdiv     as character  initial ?
    field lbdiv2    as character  initial ?
    field lbdiv3    as character  initial ?
    field mtper     as decimal    initial ? decimals 2
    field mtper-dev as decimal    initial ? decimals 2
    field nocal     as integer    initial ?
    field nocon     as int64      initial ?
    field nocon-dec as decimal    initial ? decimals 0
    field noper     as integer    initial ?
    field tpcon     as character  initial ?
    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
