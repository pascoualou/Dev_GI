/*------------------------------------------------------------------------
File        : imsg.i
Purpose     : Fichier des messages
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttImsg
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field file-name   as character  initial ? 
    field language-cd as integer    initial ? 
    field ln-num      as integer    initial ? 
    field msg         as character  initial ? 
    field num         as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
