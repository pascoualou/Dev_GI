/*------------------------------------------------------------------------
File        : ifpcomp.i
Purpose     : Table des designations complementaires
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIfpcomp
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field art-cle as character  initial ? 
    field cdlng   as integer    initial ? 
    field desig   as character  initial ? 
    field lig     as integer    initial ? 
    field soc-cd  as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
