/*------------------------------------------------------------------------
File        : tmenu.i
Purpose     : Menu de l'application nouvelle ergonomie
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTmenu
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdlng    as integer    initial ? 
    field divers   as character  initial ? 
    field FicXml   as blob       initial ? 
    field profil_u as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
