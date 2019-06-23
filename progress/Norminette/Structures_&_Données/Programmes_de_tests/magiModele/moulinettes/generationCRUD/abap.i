/*------------------------------------------------------------------------
File        : abap.i
Purpose     : Paiements fournisseurs venant du DPS
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAbap
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field coll-cle    as character  initial ? 
    field cpt-cd      as character  initial ? 
    field daech       as date       initial ? 
    field date        as date       initial ? 
    field devetr-cd   as character  initial ? 
    field divers      as character  initial ? 
    field etab-cd     as integer    initial ? 
    field fg-valid    as logical    initial ? 
    field gest-cle    as character  initial ? 
    field mandat-cd   as integer    initial ? 
    field mode-paie   as character  initial ? 
    field mt          as decimal    initial ?  decimals 2
    field mt-EURO     as decimal    initial ?  decimals 2
    field mtdev       as decimal    initial ?  decimals 2
    field regl-cd     as integer    initial ? 
    field Sens        as logical    initial ? 
    field sens-solde  as logical    initial ? 
    field soc-cd      as integer    initial ? 
    field solde       as decimal    initial ?  decimals 2
    field solde-EURO  as decimal    initial ?  decimals 2
    field sscoll-cle  as character  initial ? 
    field typefac-cle as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
