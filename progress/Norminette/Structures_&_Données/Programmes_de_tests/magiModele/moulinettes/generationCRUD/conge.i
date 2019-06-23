/*------------------------------------------------------------------------
File        : conge.i
Purpose     : Suivi des congés payés
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttConge
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy  as character  initial ? 
    field cdmsy  as character  initial ? 
    field cdori  as character  initial ? 
    field dtcsy  as date       initial ? 
    field dtmsy  as date       initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field mspai  as integer    initial ? 
    field norol  as int64      initial ? 
    field tbcpa  as decimal    initial ?  decimals 2
    field tbcpl  as decimal    initial ?  decimals 2
    field tbdv1  as decimal    initial ?  decimals 2
    field tbdv2  as decimal    initial ?  decimals 2
    field tbdv3  as decimal    initial ?  decimals 2
    field tbjco  as decimal    initial ?  decimals 2
    field tbjpa  as decimal    initial ?  decimals 2
    field tbmpa  as decimal    initial ?  decimals 2
    field tbsal  as decimal    initial ?  decimals 2
    field tprol  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
