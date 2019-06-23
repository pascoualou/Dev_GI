/*------------------------------------------------------------------------
File        : icron.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIcron
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field code-cron    as integer    initial ? 
    field crit-flag    as logical    initial ? 
    field damod        as date       initial ? 
    field etab-cd      as integer    initial ? 
    field flag         as logical    initial ? 
    field ihmod        as integer    initial ? 
    field lib          as character  initial ? 
    field perio1       as character  initial ? 
    field perio2       as character  initial ? 
    field perio3       as character  initial ? 
    field period       as character  initial ? 
    field printer-name as character  initial ? 
    field soc-cd       as integer    initial ? 
    field type-cron    as integer    initial ? 
    field usridmod     as character  initial ? 
    field zone1        as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
