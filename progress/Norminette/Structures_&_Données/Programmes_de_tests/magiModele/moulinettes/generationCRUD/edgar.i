/*------------------------------------------------------------------------
File        : edgar.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttEdgar
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdana     as character  initial ? 
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdmsy     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtecr     as date       initial ? 
    field dtmsy     as date       initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field lbecr     as character  initial ? 
    field mscpt     as integer    initial ? 
    field mtecr     as decimal    initial ?  decimals 2
    field mtecr-dev as decimal    initial ?  decimals 2
    field nolig     as integer    initial ? 
    field noloc     as int64      initial ? 
    field nomdt     as integer    initial ? 
    field pcpte     as integer    initial ? 
    field scpte     as integer    initial ? 
    field tpecr     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
