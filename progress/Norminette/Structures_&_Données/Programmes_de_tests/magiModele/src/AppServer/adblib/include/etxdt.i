/*------------------------------------------------------------------------
File        : etxdt.i
Purpose     : 
Author(s)   : GGA - 2018/01/12
Notes       :
------------------------------------------------------------------------*/

&if defined(nomTable)   = 0 &then &scoped-define nomTable ttEtxdt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif

define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field dtcsy       as date               initial ?
    field hecsy       as integer            initial ?
    field cdcsy       as character          initial ?
    field dtmsy       as date               initial ?
    field hemsy       as integer            initial ?
    field cdmsy       as character          initial ?
    field notrx       as integer            initial ?
    field tpapp       as character          initial ?
    field noapp       as integer            initial ?
    field nolot       as integer            initial ?
    field norol       as integer            initial ?
    field vltan       as integer            initial ?
    field mtlot       as decimal decimals 2 initial ?
    field ttlot       as decimal decimals 2 initial ?
    field ttlot-dev   as decimal decimals 2 initial ?
    field mtlot-dev   as decimal decimals 2 initial ?
    field cddev       as character          initial ?
    field lbdiv       as character          initial ?
    field lbdiv2      as character          initial ?
    field lbdiv3      as character          initial ?
    field cdcle       as character          initial ?
    field cdbat       as character          initial ?
    field tpmut       as character          initial ?
    field dtmut       as date               initial ?
    field fgsou       as logical            initial ?
    field txsou       as decimal decimals 2 initial ?
    field mttva       as decimal decimals 2 initial ?
    field mttva-dev   as decimal decimals 2 initial ?
    field norol-dec   as decimal decimals 0 initial ?
    field dtTimestamp as datetime           initial ?
    field CRUD        as character          initial ?
    field rRowid      as rowid
.
