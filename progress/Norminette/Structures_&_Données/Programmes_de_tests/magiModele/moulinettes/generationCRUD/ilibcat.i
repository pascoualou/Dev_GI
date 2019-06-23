/*------------------------------------------------------------------------
File        : ilibcat.i
Purpose     : Liste des libelles de categorie de compte.
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIlibcat
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field lib         as character  initial ? 
    field libcat-cd   as integer    initial ? 
    field tier-compte as logical    initial ? 
    field tva-compte  as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
