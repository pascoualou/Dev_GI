/*------------------------------------------------------------------------
File        : unite.i
Purpose     : unite  - Unite de location (Appartement)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttUnite
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcmp      as character  initial ? 
    field cdcsy      as character  initial ? 
    field cddev      as character  initial ? 
    field cdmotindis as character  initial ? 
    field cdmsy      as character  initial ? 
    field cdocc      as character  initial ? 
    field cdusa      as character  initial ? 
    field dtcsy      as date       initial ? 
    field dtdeb      as date       initial ? 
    field dtdebindis as date       initial ? 
    field dtent      as date       initial ? 
    field dtfin      as date       initial ? 
    field dtfinindis as date       initial ? 
    field dtmsy      as date       initial ? 
    field dtsor      as date       initial ? 
    field hecsy      as integer    initial ? 
    field hemsy      as integer    initial ? 
    field lbdiv      as character  initial ? 
    field lbdiv2     as character  initial ? 
    field lbdiv3     as character  initial ? 
    field mtloy      as decimal    initial ?  decimals 2
    field mtloy-dev  as decimal    initial ?  decimals 2
    field mtpro      as decimal    initial ?  decimals 2
    field mtpro-dev  as decimal    initial ?  decimals 2
    field noact      as integer    initial ? 
    field noapp      as integer    initial ? 
    field nocmp      as integer    initial ? 
    field noimm      as integer    initial ? 
    field nolie      as int64      initial ? 
    field nolot      as integer    initial ? 
    field noman      as integer    initial ? 
    field nomdt      as integer    initial ? 
    field norol      as int64      initial ? 
    field norol-dec  as decimal    initial ?  decimals 0
    field tpfin      as character  initial ? 
    field tprol      as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
