/*------------------------------------------------------------------------
File        : offlc.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       : champs techniques utiles pour cette table
derniere revue: 2018/08/08 - phm: 
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttOfflc
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cddev     as character initial ?
    field dtmaj     as integer   initial ?
    field lbdiv     as character initial ?
    field lbdiv2    as character initial ?
    field lbdiv3    as character initial ?
    field noapp     as integer   initial ?
    field nocon     as integer   initial ?
    field nocon-dec as decimal   initial ? decimals 0
    field nomaj     as integer   initial ?
    field noobs     as integer   initial ?
    field tbfam     as decimal   initial ? decimals 2 extent 6
    field tbfam-dev as decimal   initial ? decimals 2 extent 6
    field tpcon     as character initial ?

    field cdcsy     as character  initial ?
    field cdmsy     as character  initial ?
    field dtcsy     as date
    field dtmsy     as date
    field hecsy     as integer    initial ?
    field hemsy     as integer    initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
