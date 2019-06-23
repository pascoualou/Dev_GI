/*------------------------------------------------------------------------
File        : imailcli.i
Purpose     : Liste des mailings.
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttImailcli
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field adr-cd    as integer    initial ? 
    field cli-cle   as character  initial ? 
    field damail    as date       initial ? 
    field etab-cd   as integer    initial ? 
    field libadr-cd as integer    initial ? 
    field mail-cle  as character  initial ? 
    field soc-cd    as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
