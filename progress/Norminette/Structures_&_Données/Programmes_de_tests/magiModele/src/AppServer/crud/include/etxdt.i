/*------------------------------------------------------------------------
File        : etxdt.i
Purpose     : 
Author(s)   : GGA - 2018/01/12
Notes       :
derniere revue: 2018/08/08 - phm: 
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttEtxdt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field notrx       as integer   initial ?
    field tpapp       as character initial ?
    field noapp       as integer   initial ?
    field nolot       as integer   initial ?
    field norol       as integer   initial ?
    field vltan       as integer   initial ?
    field mtlot       as decimal   initial ? decimals 2
    field ttlot       as decimal   initial ? decimals 2
    field ttlot-dev   as decimal   initial ? decimals 2
    field mtlot-dev   as decimal   initial ? decimals 2
    field cddev       as character initial ?
    field lbdiv       as character initial ?
    field lbdiv2      as character initial ?
    field lbdiv3      as character initial ?
    field cdcle       as character initial ?
    field cdbat       as character initial ?
    field tpmut       as character initial ?
    field dtmut       as date
    field fgsou       as logical   initial ?
    field txsou       as decimal   initial ? decimals 2
    field mttva       as decimal   initial ? decimals 2
    field mttva-dev   as decimal   initial ? decimals 2
    field norol-dec   as decimal   initial ? decimals 0

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
