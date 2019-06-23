/*------------------------------------------------------------------------
File        : irelniv.i
Purpose     : Niveaux de relance par groupe
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIrelniv
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field act-cle    as character  initial ? 
    field etab-cd    as integer    initial ? 
    field fg-max     as logical    initial ? 
    field ind-cle    as character  initial ? 
    field ind2-cle   as character  initial ? 
    field lib        as character  initial ? 
    field nb-jour    as integer    initial ? 
    field ori-cle    as character  initial ? 
    field relan-niv  as integer    initial ? 
    field retard-deb as integer    initial ? 
    field retard-fin as integer    initial ? 
    field rgt-cd     as character  initial ? 
    field soc-cd     as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
