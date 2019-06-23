/*------------------------------------------------------------------------
File        : chaff.i
Purpose     : 
Author(s)   : generation automatique le 04/27/18
Notes       :
derniere revue: 2018/05/14 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttChaff
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cacal     as decimal    initial ? decimals 2
    field cacal-dev as decimal    initial ? decimals 2
    field cacoc     as decimal    initial ? decimals 2
    field cacoc-dev as decimal    initial ? decimals 2
    field cacom     as decimal    initial ? decimals 2
    field cacom-dev as decimal    initial ? decimals 2
    field caexe     as decimal    initial ? decimals 2
    field caexe-dev as decimal    initial ? decimals 2
    field cavec     as decimal    initial ? decimals 2
    field cavec-dev as decimal    initial ? decimals 2
    field caver     as decimal    initial ? decimals 2
    field caver-dev as decimal    initial ? decimals 2
    field cdcsy     as character  initial ?
    field cddev     as character  initial ?
    field cdmsy     as character  initial ?
    field cfabt     as decimal    initial ? decimals 2
    field dtcom     as date
    field dtcsy     as date
    field dtdeb     as date
    field dtfin     as date
    field dtmsy     as date
    field dtver     as date
    field hecsy     as integer    initial ?
    field hemsy     as integer    initial ?
    field lbact     as character  initial ?
    field lbdiv     as character  initial ?
    field lbdiv2    as character  initial ?
    field lbdiv3    as character  initial ?
    field noact     as integer    initial ?
    field nocal     as integer    initial ?
    field nocon     as int64      initial ?
    field nocon-dec as decimal    initial ? decimals 0
    field noper     as integer    initial ?
    field tpcon     as character  initial ?
    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
