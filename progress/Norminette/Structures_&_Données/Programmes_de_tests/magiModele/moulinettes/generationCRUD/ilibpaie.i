/*------------------------------------------------------------------------
File        : ilibpaie.i
Purpose     : Liste des libelles de type de paiement.
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIlibpaie
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field lib        as character  initial ? 
    field libpaie-cd as integer    initial ? 
    field type-cle   as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
