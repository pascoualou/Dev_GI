/*------------------------------------------------------------------------
File        : cbaplnana.i
Purpose     : Lignes analytiqyes des saisie de paiement rapide
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCbaplnana
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana-cd      as character  initial ? 
    field ana1-cd     as character  initial ? 
    field ana2-cd     as character  initial ? 
    field ana3-cd     as character  initial ? 
    field ana4-cd     as character  initial ? 
    field lib-ecr     as character  initial ? 
    field lig         as integer    initial ? 
    field mt          as decimal    initial ?  decimals 2
    field mt-EURO     as decimal    initial ?  decimals 2
    field mtdev       as decimal    initial ?  decimals 2
    field mttva       as decimal    initial ?  decimals 2
    field mttva-dev   as decimal    initial ?  decimals 2
    field mttva-EURO  as decimal    initial ?  decimals 2
    field num-int     as integer    initial ? 
    field pos         as integer    initial ? 
    field pourc       as decimal    initial ?  decimals 2
    field repart-ana  as character  initial ? 
    field sens        as logical    initial ? 
    field soc-cd      as integer    initial ? 
    field taux-cle    as decimal    initial ?  decimals 2
    field taxe-cd     as integer    initial ? 
    field tx-recuptva as decimal    initial ?  decimals 2
    field typeventil  as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
