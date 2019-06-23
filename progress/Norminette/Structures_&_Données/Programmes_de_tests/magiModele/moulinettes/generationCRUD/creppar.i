/*------------------------------------------------------------------------
File        : creppar.i
Purpose     : Parametres divers pour la comptabilisation
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCreppar
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field etab-cd     as integer    initial ? 
    field flag-compta as logical    initial ? 
    field jou-cd      as character  initial ? 
    field scen-cle    as character  initial ? 
    field soc-cd      as integer    initial ? 
    field type-cle    as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
