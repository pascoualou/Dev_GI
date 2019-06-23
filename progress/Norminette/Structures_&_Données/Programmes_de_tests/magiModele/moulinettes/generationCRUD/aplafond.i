/*------------------------------------------------------------------------
File        : aplafond.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAplafond
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field daplafond       as date       initial ? 
    field mt-plafond      as decimal    initial ?  decimals 2
    field mt-plafond-EURO as decimal    initial ?  decimals 2
    field soc-cd          as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
