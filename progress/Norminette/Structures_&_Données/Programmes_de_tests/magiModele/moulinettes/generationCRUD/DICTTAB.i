/*------------------------------------------------------------------------
File        : DICTTAB.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttDicttab
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field FGTRIG     as logical    initial ? 
    field IDENTREF   as character  initial ? 
    field NMCHAMPREF as character  initial ? 
    field NMLOG      as character  initial ? 
    field NMTAB      as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
