/*------------------------------------------------------------------------
File        : cclass.i
Purpose     : Parametre des classes (ne concerne que les comptes generaux).
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCclass
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field centra     as logical    initial ? 
    field cpt-cd     as character  initial ? 
    field etab-cd    as integer    initial ? 
    field fg-mandat  as logical    initial ? 
    field libcat-cd  as integer    initial ? 
    field libclasse  as character  initial ? 
    field libimp-cd  as integer    initial ? 
    field libnat-cd  as integer    initial ? 
    field libsens-cd as integer    initial ? 
    field libtype-cd as integer    initial ? 
    field reciproq   as logical    initial ? 
    field sens-oblig as logical    initial ? 
    field soc-cd     as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
