/*------------------------------------------------------------------------
File        : isecurite.i
Purpose     : Fichier descriptif des securites suivant les utilisateurs.
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIsecurite
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field code           as character  initial ? 
    field descriptif     as character  initial ? 
    field gi             as logical    initial ? 
    field libel-cd       as integer    initial ? 
    field menu-nom       as character  initial ? 
    field menu-titre     as character  initial ? 
    field niveau-menu    as character  initial ? 
    field prognom        as character  initial ? 
    field specifique     as logical    initial ? 
    field specifique-cle as character  initial ? 
    field utilisateur    as character  initial ? 
    field valid          as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
