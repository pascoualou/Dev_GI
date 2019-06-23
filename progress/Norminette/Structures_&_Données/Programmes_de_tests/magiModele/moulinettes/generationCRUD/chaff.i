/*------------------------------------------------------------------------
File        : chaff.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttChaff
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cacal     as decimal    initial ?  decimals 2
    field cacal-dev as decimal    initial ?  decimals 2
    field cacoc     as decimal    initial ?  decimals 2
    field cacoc-dev as decimal    initial ?  decimals 2
    field cacom     as decimal    initial ?  decimals 2
    field cacom-dev as decimal    initial ?  decimals 2
    field caexe     as decimal    initial ?  decimals 2
    field caexe-dev as decimal    initial ?  decimals 2
    field cavec     as decimal    initial ?  decimals 2
    field cavec-dev as decimal    initial ?  decimals 2
    field caver     as decimal    initial ?  decimals 2
    field caver-dev as decimal    initial ?  decimals 2
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdmsy     as character  initial ? 
    field cfabt     as decimal    initial ?  decimals 2
    field dtcom     as date       initial ? 
    field dtcsy     as date       initial ? 
    field dtdeb     as date       initial ? 
    field dtfin     as date       initial ? 
    field dtmsy     as date       initial ? 
    field dtver     as date       initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbact     as character  initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field noact     as integer    initial ? 
    field nocal     as integer    initial ? 
    field nocon     as int64      initial ? 
    field nocon-dec as decimal    initial ?  decimals 0
    field noper     as integer    initial ? 
    field tpcon     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
