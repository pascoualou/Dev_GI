/*------------------------------------------------------------------------
File        : vacan.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttVacan
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdmsy     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtmsy     as date       initial ? 
    field dtop      as date       initial ? 
    field dtrdb     as date       initial ? 
    field etopt     as character  initial ? 
    field gfcau     as character  initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field herdv     as character  initial ? 
    field lbcom     as character  initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field mtdpg     as decimal    initial ?  decimals 2
    field mtdpg-dev as decimal    initial ?  decimals 2
    field mtfra     as integer    initial ? 
    field mtloy     as decimal    initial ?  decimals 2
    field mtloy-dev as decimal    initial ?  decimals 2
    field mtpro     as decimal    initial ?  decimals 2
    field mtpro-dev as decimal    initial ?  decimals 2
    field mtsal     as decimal    initial ?  decimals 2
    field mtsal-dev as decimal    initial ?  decimals 2
    field mttax     as decimal    initial ?  decimals 2
    field mttax-dev as decimal    initial ?  decimals 2
    field noact     as integer    initial ? 
    field noapp     as integer    initial ? 
    field nocom     as character  initial ? 
    field nomdt     as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
