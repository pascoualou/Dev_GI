/*------------------------------------------------------------------------
File        : apaie.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttApaie
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy     as character  initial ? 
    field cdmsy     as character  initial ? 
    field cdori     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtmsy     as date       initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field lbrub     as character  initial ? 
    field modul     as character  initial ? 
    field mspai     as integer    initial ? 
    field norol     as int64      initial ? 
    field norol-dec as decimal    initial ?  decimals 0
    field tprol     as character  initial ? 
    field vlext     as decimal    initial ?  decimals 4
    field vlmgi     as decimal    initial ?  decimals 4
    field vlmod     as decimal    initial ?  decimals 4
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
