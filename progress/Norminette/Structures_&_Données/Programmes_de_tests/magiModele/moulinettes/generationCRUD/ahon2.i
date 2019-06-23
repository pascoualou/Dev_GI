/*------------------------------------------------------------------------
File        : ahon2.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAhon2
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdmsy     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtmsy     as date       initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field lbhon     as character  initial ? 
    field mtaut     as decimal    initial ?  decimals 2
    field mtaut-dev as decimal    initial ?  decimals 2
    field mtfra     as decimal    initial ?  decimals 2
    field mtfra-dev as decimal    initial ?  decimals 2
    field mthon     as decimal    initial ?  decimals 2
    field mthon-dev as decimal    initial ?  decimals 2
    field mttot     as decimal    initial ?  decimals 2
    field mttot-dev as decimal    initial ?  decimals 2
    field mttva     as decimal    initial ?  decimals 2
    field mttva-dev as decimal    initial ?  decimals 2
    field nofac     as integer    initial ? 
    field noman     as integer    initial ? 
    field nomdt     as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
