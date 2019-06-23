/*------------------------------------------------------------------------
File        : avenant.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAvenant
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy     as character  initial ? 
    field cdmsy     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtdeb     as date       initial ? 
    field dtfin     as date       initial ? 
    field dtmsy     as date       initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field nbheuA    as decimal    initial ?  decimals 2
    field nbUVB     as decimal    initial ?  decimals 2
    field noave     as integer    initial ? 
    field salcmp235 as decimal    initial ?  decimals 2
    field salcmp255 as decimal    initial ?  decimals 2
    field salcmp275 as decimal    initial ?  decimals 2
    field salcmp340 as decimal    initial ?  decimals 2
    field salcmp395 as decimal    initial ?  decimals 2
    field salcmp410 as decimal    initial ?  decimals 2
    field tppar     as character  initial ? 
    field valptA    as decimal    initial ?  decimals 2
    field valptB    as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
