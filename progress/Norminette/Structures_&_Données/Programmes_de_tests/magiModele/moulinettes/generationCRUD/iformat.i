/*------------------------------------------------------------------------
File        : iformat.i
Purpose     : Fichier format des champs standard
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIformat
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field champs    as character  initial ? 
    field fchamps   as character  initial ? 
    field gi-client as character  initial ? 
    field sauf-file as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
