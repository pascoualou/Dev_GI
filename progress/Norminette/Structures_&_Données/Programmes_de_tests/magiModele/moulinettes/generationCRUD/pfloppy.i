/*------------------------------------------------------------------------
File        : pfloppy.i
Purpose     : Fichier Floppy Disquette
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPfloppy
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field adresse-floppy as character  initial ? 
    field floppy-cle     as character  initial ? 
    field lib            as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
