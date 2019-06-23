/*------------------------------------------------------------------------
File        : amor1.i
Purpose     : Amortissement locataires (1)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAmor1
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdass     as character  initial ? 
    field cdcal     as character  initial ? 
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdevo     as character  initial ? 
    field cdmat     as character  initial ? 
    field cdmsy     as character  initial ? 
    field dtclo     as date       initial ? 
    field dtcsy     as date       initial ? 
    field dtdeb     as date       initial ? 
    field dtfin     as date       initial ? 
    field dtmsy     as date       initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field lbfin     as character  initial ? 
    field nocon     as int64      initial ? 
    field nocon-dec as decimal    initial ?  decimals 0
    field nofic     as integer    initial ? 
    field tbtau     as decimal    initial ?  decimals 2
    field tpcon     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
