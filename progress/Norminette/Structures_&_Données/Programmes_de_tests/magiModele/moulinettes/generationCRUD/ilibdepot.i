/*------------------------------------------------------------------------
File        : ilibdepot.i
Purpose     : libelle depot
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIlibdepot
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field conso    as logical    initial ? 
    field dep-type as integer    initial ? 
    field etab-cd  as integer    initial ? 
    field lib-type as character  initial ? 
    field nature   as logical    initial ? 
    field neuf     as logical    initial ? 
    field soc-cd   as integer    initial ? 
    field vente    as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
