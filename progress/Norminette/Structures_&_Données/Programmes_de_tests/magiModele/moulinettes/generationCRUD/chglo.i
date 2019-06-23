/*------------------------------------------------------------------------
File        : chglo.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttChglo
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcle  as character  initial ? 
    field cdcsy  as character  initial ? 
    field cdmsy  as character  initial ? 
    field dtcsy  as date       initial ? 
    field dtent  as date       initial ? 
    field dtmsy  as date       initial ? 
    field dtsor  as date       initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field mtchg  as decimal    initial ?  decimals 2
    field mttva  as decimal    initial ?  decimals 2
    field nbden  as integer    initial ? 
    field nbnum  as integer    initial ? 
    field noapp  as integer    initial ? 
    field noctt  as decimal    initial ?  decimals 0
    field noexo  as integer    initial ? 
    field nolig  as integer    initial ? 
    field nomdt  as integer    initial ? 
    field noord  as integer    initial ? 
    field tpctt  as character  initial ? 
    field tpmdt  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
