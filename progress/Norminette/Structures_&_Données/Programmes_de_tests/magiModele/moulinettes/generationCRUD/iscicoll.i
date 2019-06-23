/*------------------------------------------------------------------------
File        : iscicoll.i
Purpose     : Table des correspondances collectifs SCI
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIscicoll
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field soc-cd     as integer    initial ? 
    field sscoll-cle as character  initial ? 
    field sscoll-sci as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
