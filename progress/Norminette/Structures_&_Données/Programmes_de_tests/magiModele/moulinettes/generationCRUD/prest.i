/*------------------------------------------------------------------------
File        : prest.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPrest
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdmsy     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtdc1     as date       initial ? 
    field dtdc2     as date       initial ? 
    field dtdc3     as date       initial ? 
    field dtdeb     as date       initial ? 
    field dtfc1     as date       initial ? 
    field dtfc2     as date       initial ? 
    field dtfc3     as date       initial ? 
    field dtfin     as date       initial ? 
    field dtmsy     as date       initial ? 
    field dttir     as date       initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field mtchg     as decimal    initial ?  decimals 2
    field mtchg-dev as decimal    initial ?  decimals 2
    field mtpap     as decimal    initial ?  decimals 2
    field mtpap-dev as decimal    initial ?  decimals 2
    field mtpro     as decimal    initial ?  decimals 2
    field mtpro-dev as decimal    initial ?  decimals 2
    field noarr     as integer    initial ? 
    field noman     as integer    initial ? 
    field nomdt     as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
