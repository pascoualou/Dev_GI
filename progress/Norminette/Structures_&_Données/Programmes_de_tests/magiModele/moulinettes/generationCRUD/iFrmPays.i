/*------------------------------------------------------------------------
File        : iFrmPays.i
Purpose     : Table des formats bancaires par pays
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIfrmpays
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdfrm  as character  initial ? 
    field cdiso2 as character  initial ? 
    field cdtrt  as character  initial ? 
    field fgEtr  as logical    initial ? 
    field fgIban as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
