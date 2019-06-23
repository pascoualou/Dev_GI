/*------------------------------------------------------------------------
File        : echlo.i
Purpose     : Echelle des loyers
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttEchlo
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdmsy     as character  initial ? 
    field debtc     as decimal    initial ?  decimals 2
    field debtc-dev as decimal    initial ?  decimals 2
    field dtcsy     as date       initial ? 
    field dtdeb     as date       initial ? 
    field dtfin     as date       initial ? 
    field dtmsy     as date       initial ? 
    field fintc     as decimal    initial ?  decimals 2
    field fintc-dev as decimal    initial ?  decimals 2
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field idxfx     as logical    initial ? 
    field idxmg     as logical    initial ? 
    field idxpl     as logical    initial ? 
    field idxtc     as logical    initial ? 
    field jrcom     as integer    initial ? 
    field lbact     as character  initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field loyfx     as decimal    initial ?  decimals 2
    field loyfx-dev as decimal    initial ?  decimals 2
    field loymg     as decimal    initial ?  decimals 2
    field loymg-dev as decimal    initial ?  decimals 2
    field loypl     as decimal    initial ?  decimals 2
    field loypl-dev as decimal    initial ?  decimals 2
    field mscom     as integer    initial ? 
    field noact     as integer    initial ? 
    field nocal     as integer    initial ? 
    field nocon     as int64      initial ? 
    field nocon-dec as decimal    initial ?  decimals 0
    field noper     as integer    initial ? 
    field norub     as character  initial ? 
    field penal     as decimal    initial ?  decimals 2
    field penal-dev as decimal    initial ?  decimals 2
    field prcpl     as decimal    initial ?  decimals 2
    field prctc     as decimal    initial ?  decimals 2
    field tpcon     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
