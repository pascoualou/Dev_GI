/*------------------------------------------------------------------------
File        : ibquope.i
Purpose     : Fichier codes operation par banque
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIbquope
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field coll-cle   as character  initial ? 
    field cpt-cd     as character  initial ? 
    field etab-cd    as integer    initial ? 
    field flag-piece as logical    initial ? 
    field lib        as character  initial ? 
    field libope-cd  as character  initial ? 
    field libsens-cd as integer    initial ? 
    field soc-cd     as integer    initial ? 
    field type-cle   as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
