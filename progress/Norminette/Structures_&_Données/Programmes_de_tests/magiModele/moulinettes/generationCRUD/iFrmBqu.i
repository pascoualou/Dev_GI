/*------------------------------------------------------------------------
File        : iFrmBqu.i
Purpose     : Liste des formats bancaires
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIfrmbqu
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdfrm    as character  initial ? 
    field devise   as character  initial ? 
    field libfrm   as character  initial ? 
    field remarque as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
