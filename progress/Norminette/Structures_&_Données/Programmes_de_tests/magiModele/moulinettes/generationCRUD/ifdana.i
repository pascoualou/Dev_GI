/*------------------------------------------------------------------------
File        : ifdana.i
Purpose     : Table de correspondance des codes analytiques
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIfdana
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana-cd    as character  initial ? 
    field cdgen-cle as character  initial ? 
    field divers    as character  initial ? 
    field etab-cd   as integer    initial ? 
    field soc-cd    as integer    initial ? 
    field type-cle  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
