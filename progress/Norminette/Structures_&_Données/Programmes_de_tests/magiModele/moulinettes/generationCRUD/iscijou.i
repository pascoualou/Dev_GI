/*------------------------------------------------------------------------
File        : iscijou.i
Purpose     : Table correspondances journaux SCI
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIscijou
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field jou-ach      as character  initial ? 
    field jou-autres   as character  initial ? 
    field jou-od       as character  initial ? 
    field jou-quit     as character  initial ? 
    field jou-tresoloc as character  initial ? 
    field jou-tresomdt as character  initial ? 
    field soc-cd       as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
