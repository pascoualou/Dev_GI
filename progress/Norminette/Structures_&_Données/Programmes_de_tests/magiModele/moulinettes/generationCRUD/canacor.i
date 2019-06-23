/*------------------------------------------------------------------------
File        : canacor.i
Purpose     : Fichier correspondance cptes gene. cptes ana.
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCanacor
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana1       as logical    initial ? 
    field ana1-cd    as character  initial ? 
    field ana2       as logical    initial ? 
    field ana2-cd    as character  initial ? 
    field ana3       as logical    initial ? 
    field ana3-cd    as character  initial ? 
    field ana4       as logical    initial ? 
    field ana4-cd    as character  initial ? 
    field anacor-cle as character  initial ? 
    field cpt-cd     as character  initial ? 
    field etab-cd    as integer    initial ? 
    field pourc      as decimal    initial ?  decimals 2
    field soc-cd     as integer    initial ? 
    field sscoll-cle as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
