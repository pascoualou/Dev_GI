/*------------------------------------------------------------------------
File        : pscenana.i
Purpose     : Fichier scenario analytique
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPscenana
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field affair-num as decimal    initial ?  decimals 0
    field ana-cd     as character  initial ? 
    field ana1-cd    as character  initial ? 
    field ana2-cd    as character  initial ? 
    field ana3-cd    as character  initial ? 
    field ana4-cd    as character  initial ? 
    field analytique as logical    initial ? 
    field coll-cle   as character  initial ? 
    field cpt-cd     as character  initial ? 
    field dev-cd     as character  initial ? 
    field etab-cd    as integer    initial ? 
    field jou-cd     as character  initial ? 
    field lib        as character  initial ? 
    field lib-ecr    as character  initial ? 
    field mt         as decimal    initial ?  decimals 2
    field mt-EURO    as decimal    initial ?  decimals 2
    field mttva      as decimal    initial ?  decimals 2
    field mttva-EURO as decimal    initial ?  decimals 2
    field natjou-cd  as integer    initial ? 
    field ordre-num  as integer    initial ? 
    field pos        as integer    initial ? 
    field pourc      as decimal    initial ?  decimals 2
    field repart-ana as character  initial ? 
    field scen-cle   as character  initial ? 
    field sens       as logical    initial ? 
    field soc-cd     as integer    initial ? 
    field sscoll-cle as character  initial ? 
    field tantieme   as integer    initial ? 
    field taux-cle   as decimal    initial ?  decimals 2
    field taxe-cd    as integer    initial ? 
    field type-cle   as character  initial ? 
    field typeventil as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
