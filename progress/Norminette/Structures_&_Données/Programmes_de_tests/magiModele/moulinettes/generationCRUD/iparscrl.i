/*------------------------------------------------------------------------
File        : iparscrl.i
Purpose     : parametres integration scrl
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIparscrl
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field daderint   as date       initial ? 
    field etab-cd    as integer    initial ? 
    field floppy-cle as character  initial ? 
    field nom-fic    as character  initial ? 
    field soc-cd     as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
