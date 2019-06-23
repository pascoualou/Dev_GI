/*------------------------------------------------------------------------
File        : tdroit-it.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTdroit-it
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field acces     as logical    initial ? 
    field affichage as logical    initial ? 
    field cdapp     as character  initial ? 
    field noite     as integer    initial ? 
    field profil_u  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
