/*------------------------------------------------------------------------
File        : LSTTRAIT.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttLsttrait
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field CDTRAIT    as character  initial ? 
    field ihdebtrait as integer    initial ? 
    field ihfintrait as integer    initial ? 
    field JDEBTRAIT  as date       initial ? 
    field JFINTRAIT  as date       initial ? 
    field soc-cd     as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
