/*------------------------------------------------------------------------
File        : salhis.i
Purpose     : Salariés : historique rémunérations 
0108/0109 - DIF
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttSalhis
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy    as character  initial ? 
    field cdmsy    as character  initial ? 
    field cdori    as character  initial ? 
    field dtcsy    as date       initial ? 
    field dtmsy    as date       initial ? 
    field hecsy    as integer    initial ? 
    field hemsy    as integer    initial ? 
    field lbdiv    as character  initial ? 
    field lbdiv2   as character  initial ? 
    field lbdiv3   as character  initial ? 
    field modulnet as character  initial ? 
    field modultps as character  initial ? 
    field mspai    as integer    initial ? 
    field nbheu    as decimal    initial ?  decimals 2
    field norol    as int64      initial ? 
    field tprol    as character  initial ? 
    field vlmodnet as decimal    initial ?  decimals 2
    field vlmodtps as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
