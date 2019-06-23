/*------------------------------------------------------------------------
File        : difheu.i
Purpose     : Salariés : DIF - crédit d'heures
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttDifheu
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy    as character  initial ? 
    field cdmsy    as character  initial ? 
    field dtcsy    as date       initial ? 
    field dtmsy    as date       initial ? 
    field fgmod    as logical    initial ? 
    field hecsy    as integer    initial ? 
    field hemsy    as integer    initial ? 
    field lbdiv    as character  initial ? 
    field lbdiv2   as character  initial ? 
    field lbdiv3   as character  initial ? 
    field mspai    as integer    initial ? 
    field nbheudif as decimal    initial ?  decimals 2
    field nbheumoi as decimal    initial ?  decimals 2
    field nbheusai as decimal    initial ?  decimals 2
    field norol    as int64      initial ? 
    field tprol    as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
