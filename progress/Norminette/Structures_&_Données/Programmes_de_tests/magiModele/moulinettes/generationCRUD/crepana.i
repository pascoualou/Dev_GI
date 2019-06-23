/*------------------------------------------------------------------------
File        : crepana.i
Purpose     : Fichier des repartitions
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCrepana
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana1-cd    as character  initial ? 
    field ana2-cd    as character  initial ? 
    field ana3-cd    as character  initial ? 
    field ana4-cd    as character  initial ? 
    field cpt-cd     as character  initial ? 
    field etab-cd    as integer    initial ? 
    field lig        as integer    initial ? 
    field pourc      as decimal    initial ?  decimals 2
    field repart-cle as character  initial ? 
    field soc-cd     as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
