/*------------------------------------------------------------------------
File        : cexilnana.i
Purpose     : Analytique charges locatives immeuble
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCexilnana
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field affair-num as integer    initial ? 
    field ana1-cd    as character  initial ? 
    field ana2-cd    as character  initial ? 
    field ana3-cd    as character  initial ? 
    field ana4-cd    as character  initial ? 
    field annee      as integer    initial ? 
    field cdunite    as character  initial ? 
    field cptgen     as character  initial ? 
    field dev-cd     as character  initial ? 
    field devetr-cd  as character  initial ? 
    field divers-cd  as integer    initial ? 
    field jou-cd     as character  initial ? 
    field lib        as character  initial ? 
    field lib-ecr    as character  initial ? 
    field lig        as integer    initial ? 
    field mois       as integer    initial ? 
    field mt         as decimal    initial ?  decimals 2
    field mt-EURO    as decimal    initial ?  decimals 2
    field mtdev      as decimal    initial ?  decimals 2
    field mttva      as decimal    initial ?  decimals 2
    field mttva-dev  as decimal    initial ?  decimals 2
    field mttva-EURO as decimal    initial ?  decimals 2
    field noimm      as integer    initial ? 
    field order-num  as integer    initial ? 
    field pos        as integer    initial ? 
    field pourc      as decimal    initial ?  decimals 2
    field ptlivr     as character  initial ? 
    field qte        as decimal    initial ?  decimals 2
    field sens       as logical    initial ? 
    field soc-cd     as integer    initial ? 
    field tantieme   as integer    initial ? 
    field taux-cle   as decimal    initial ?  decimals 2
    field taxe-cd    as integer    initial ? 
    field tva-cd     as integer    initial ? 
    field typeventil as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
