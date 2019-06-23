/*------------------------------------------------------------------------
File        : dtval.i
Purpose     : Date de validité des comptes
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttDtval
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field coll-cle   as character  initial ? 
    field cpt-cd     as character  initial ? 
    field dadeb      as date       initial ? 
    field dafin      as date       initial ? 
    field divers     as character  initial ? 
    field etab-cd    as integer    initial ? 
    field soc-cd     as integer    initial ? 
    field sscoll-cle as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
