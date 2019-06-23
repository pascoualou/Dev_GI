/*------------------------------------------------------------------------
File        : mutexo.i
Purpose     : Suivi des mutations par exercice
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttMutexo
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy          as character  initial ? 
    field cdmsy          as character  initial ? 
    field ddebexo        as date       initial ? 
    field dfinexo        as date       initial ? 
    field dtcsy          as date       initial ? 
    field dtdeb          as date       initial ? 
    field dtmsy          as date       initial ? 
    field dtrait         as date       initial ? 
    field dttrf          as date       initial ? 
    field fgannul-pchr   as logical    initial ? 
    field fgODman        as logical    initial ? 
    field fgtrait        as logical    initial ? 
    field hecsy          as integer    initial ? 
    field hemsy          as integer    initial ? 
    field hetrf          as integer    initial ? 
    field lbdiv          as character  initial ? 
    field lbdiv2         as character  initial ? 
    field lbdiv3         as character  initial ? 
    field nocon          as int64      initial ? 
    field noexo          as integer    initial ? 
    field nomdt          as integer    initial ? 
    field nomut          as integer    initial ? 
    field noper          as integer    initial ? 
    field norol          as int64      initial ? 
    field pchr-etab-cd   as integer    initial ? 
    field pchr-jou-cd    as character  initial ? 
    field pchr-piece-int as integer    initial ? 
    field pchr-prd-cd    as integer    initial ? 
    field pchr-prd-num   as integer    initial ? 
    field tpcon          as character  initial ? 
    field tpmdt          as character  initial ? 
    field tpren          as character  initial ? 
    field tprol          as character  initial ? 
    field typtrait       as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
