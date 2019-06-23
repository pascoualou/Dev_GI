/*------------------------------------------------------------------------
File        : apbco.i
Purpose     : répartition d'un appel de fonds par copropriétaire/clé/lot
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttApbco
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcle       as character  initial ? 
    field cdcsy       as character  initial ? 
    field cddev       as character  initial ? 
    field cdmsy       as character  initial ? 
    field dtapp       as date       initial ? 
    field dtcsy       as date       initial ? 
    field dtems       as date       initial ? 
    field dtmsy       as date       initial ? 
    field fgsim       as logical    initial ? 
    field hecsy       as integer    initial ? 
    field hemsy       as integer    initial ? 
    field lbdiv       as character  initial ? 
    field lbdiv2      as character  initial ? 
    field lbdiv3      as character  initial ? 
    field lbdiv4      as character  initial ? 
    field lbdiv5      as character  initial ? 
    field Mdges       as character  initial ? 
    field mtLoRecLoc  as decimal    initial ?  decimals 2
    field mtlot       as decimal    initial ?  decimals 2
    field mtlot-dev   as decimal    initial ?  decimals 2
    field mtsim       as decimal    initial ?  decimals 2
    field mttot       as decimal    initial ?  decimals 2
    field mttotrecloc as decimal    initial ?  decimals 2
    field mttvRecLoc  as decimal    initial ?  decimals 2
    field noapp       as integer    initial ? 
    field nobud       as int64      initial ? 
    field nobud-dec   as decimal    initial ?  decimals 0
    field nocop       as integer    initial ? 
    field noimm       as integer    initial ? 
    field nolot       as integer    initial ? 
    field noman       as integer    initial ? 
    field nomdt       as integer    initial ? 
    field noord       as integer    initial ? 
    field tpapp       as character  initial ? 
    field tpbud       as character  initial ? 
    field tpmic       as character  initial ? 
    field tvlot       as decimal    initial ?  decimals 2
    field tvlot-dev   as decimal    initial ?  decimals 2
    field tvsim       as decimal    initial ?  decimals 2
    field typapptrx   as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
