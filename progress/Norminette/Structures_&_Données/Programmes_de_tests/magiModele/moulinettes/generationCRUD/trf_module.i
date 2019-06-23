/*------------------------------------------------------------------------
File        : trf_module.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTrf_module
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field datpris-dev as date       initial ? 
    field datpris-mq  as date       initial ? 
    field datrest-dev as date       initial ? 
    field datrest-mq  as date       initial ? 
    field lib         as character  initial ? 
    field nomprg      as character  initial ? 
    field util-dev    as character  initial ? 
    field util-mq     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
