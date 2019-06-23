/*------------------------------------------------------------------------
File        : cpaierep.i
Purpose     : Fichier Paiement Fournisseur (Repartition)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCpaierep
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field bqjou-cd   as character  initial ? 
    field chrono     as integer    initial ? 
    field coll-cle   as character  initial ? 
    field cpt-cd     as character  initial ? 
    field daech      as date       initial ? 
    field eapjou-cd  as character  initial ? 
    field etab-cd    as integer    initial ? 
    field gest-cle   as character  initial ? 
    field libpaie-cd as integer    initial ? 
    field mandat-cd  as integer    initial ? 
    field mt         as decimal    initial ?  decimals 2
    field mt-EURO    as decimal    initial ?  decimals 2
    field num-int    as integer    initial ? 
    field soc-cd     as integer    initial ? 
    field sscoll-cle as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
