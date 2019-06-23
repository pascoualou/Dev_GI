/*------------------------------------------------------------------------
File        : attra.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAttra
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field adfo1     as character  initial ? 
    field adfo2     as character  initial ? 
    field adfo3     as character  initial ? 
    field cdcle     as character  initial ? 
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdfou     as character  initial ? 
    field cdmsy     as character  initial ? 
    field cptfo     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtmsy     as date       initial ? 
    field dttra     as date       initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field lbtra     as character  initial ? 
    field mtmod     as decimal    initial ?  decimals 2
    field mtmod-dev as decimal    initial ?  decimals 2
    field mtree     as decimal    initial ?  decimals 2
    field mtree-dev as decimal    initial ?  decimals 2
    field nmfou     as character  initial ? 
    field nocon     as int64      initial ? 
    field nocon-dec as decimal    initial ?  decimals 0
    field nodoc     as character  initial ? 
    field noexo     as integer    initial ? 
    field nolig     as integer    initial ? 
    field tpcon     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
