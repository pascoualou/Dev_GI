/*------------------------------------------------------------------------
File        : perio.i
Purpose     : 
Author(s)   : GGA - 2018/01/23
Notes       :
derniere revue: 2018/08/08 - phm: 
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPerio
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field tpctt       as character initial ?  
    field nomdt       as integer   initial ?  
    field noexo       as integer   initial ?  
    field noper       as integer   initial ?  
    field dtdeb       as date
    field dtfin       as date
    field nbmoi       as integer   initial ?
    field cdper       as character initial ?
    field cdtrt       as character initial ?
    field lbper       as character initial ?
    field lbdiv       as character initial ?
    field cddev       as character initial ?
    field lbdiv2      as character initial ?
    field lbdiv3      as character initial ?
    field dtapc       as date
    field dtage       as date

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
