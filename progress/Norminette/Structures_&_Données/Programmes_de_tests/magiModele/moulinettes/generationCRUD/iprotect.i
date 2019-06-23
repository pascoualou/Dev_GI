/*------------------------------------------------------------------------
File        : iprotect.i
Purpose     : Fichier protection acces en Insertion, Modification, Effacement pour l'ensemble des modules selon l'utilisateur.
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIprotect
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field eff     as character  initial ? 
    field fic-nom as character  initial ? 
    field ins     as character  initial ? 
    field modif   as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
