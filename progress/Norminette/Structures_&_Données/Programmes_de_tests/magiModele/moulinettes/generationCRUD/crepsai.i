/*------------------------------------------------------------------------
File        : crepsai.i
Purpose     : Fichier entetes des cles de
repartition
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCrepsai
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana1-cd     as character  initial ? 
    field ana2-cd     as character  initial ? 
    field ana3-cd     as character  initial ? 
    field ana4-cd     as character  initial ? 
    field anacor-cle  as character  initial ? 
    field cpt-cd      as character  initial ? 
    field cptdeb-cd   as character  initial ? 
    field cptfin-cd   as character  initial ? 
    field etab-cd     as integer    initial ? 
    field fg-lst      as logical    initial ? 
    field fg-repart   as logical    initial ? 
    field lib         as character  initial ? 
    field lstcpt      as character  initial ? 
    field period      as integer    initial ? 
    field repart-cle  as character  initial ? 
    field repart-cpt  as logical    initial ? 
    field soc-cd      as integer    initial ? 
    field sscoll-cle  as character  initial ? 
    field type-repart as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
