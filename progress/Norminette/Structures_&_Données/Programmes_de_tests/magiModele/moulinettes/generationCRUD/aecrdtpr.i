/*------------------------------------------------------------------------
File        : aecrdtpr.i
Purpose     : Détails d'écritures Provisions
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAecrdtpr
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cat-cd     as integer    initial ? 
    field cdlib      as integer    initial ? 
    field cdrub      as integer    initial ? 
    field cmthono    as character  initial ? 
    field etab-cd    as integer    initial ? 
    field jou-cd     as character  initial ? 
    field lig        as integer    initial ? 
    field mt         as decimal    initial ?  decimals 2
    field mt-EURO    as decimal    initial ?  decimals 2
    field mtht       as decimal    initial ?  decimals 2
    field mtht-EURO  as decimal    initial ?  decimals 2
    field mttva      as decimal    initial ?  decimals 2
    field mttva-EURO as decimal    initial ?  decimals 2
    field piece-int  as integer    initial ? 
    field prd-cd     as integer    initial ? 
    field prd-num    as integer    initial ? 
    field sens       as logical    initial ? 
    field soc-cd     as integer    initial ? 
    field taux       as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
