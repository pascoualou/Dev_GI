/*------------------------------------------------------------------------
File        : version.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttVersion
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field date_version        as date       initial ? 
    field heure_version       as integer    initial ? 
    field lib1_version        as character  initial ? 
    field lib2_version        as character  initial ? 
    field lib3_version        as character  initial ? 
    field machine_version     as character  initial ? 
    field numero_version      as character  initial ? 
    field utilisateur_version as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
