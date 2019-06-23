/*------------------------------------------------------------------------
File        : ifdlnana.i
Purpose     : Table des lignes analytiques des factures
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIfdlnana
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana4-cd     as character  initial ? 
    field com-num     as integer    initial ? 
    field etab-cd     as integer    initial ? 
    field fisc-cle    as integer    initial ? 
    field lig-num     as integer    initial ? 
    field mt          as decimal    initial ?  decimals 2
    field mt-EURO     as decimal    initial ?  decimals 2
    field mttva       as decimal    initial ?  decimals 2
    field mttva-EURO  as decimal    initial ?  decimals 2
    field pos         as integer    initial ? 
    field pourc       as decimal    initial ?  decimals 2
    field rub-cd      as integer    initial ? 
    field soc-cd      as integer    initial ? 
    field ssrub-cd    as integer    initial ? 
    field taux-cle    as decimal    initial ?  decimals 2
    field tx-recuptva as decimal    initial ?  decimals 2
    field typeventil  as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
