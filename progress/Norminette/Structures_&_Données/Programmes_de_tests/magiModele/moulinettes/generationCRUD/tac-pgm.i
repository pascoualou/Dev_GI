/*------------------------------------------------------------------------
File        : tac-pgm.i
Purpose     : Lien entre tache et menu
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTac-pgm
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field acces as character  initial ? 
    field args  as character  initial ? 
    field cdcsy as character  initial ? 
    field cdmsy as character  initial ? 
    field cdTbl as character  initial ? 
    field dtcsy as date       initial ? 
    field dtmsy as date       initial ? 
    field evt   as character  initial ? 
    field hecsy as integer    initial ? 
    field hemsy as integer    initial ? 
    field NoAct as integer    initial ? 
    field noite as integer    initial ? 
    field NoOrd as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
