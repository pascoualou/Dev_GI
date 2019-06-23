/*------------------------------------------------------------------------
File        : iPays.i
Purpose     : Code ISO du pays
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIpays
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdiso2   as character  initial ? 
    field cdiso3   as character  initial ? 
    field cdiso4   as character  initial ? 
    field cdiso5   as character  initial ? 
    field cdisonum as integer    initial ? 
    field fg-rib   as logical    initial ? 
    field fg-sepa  as logical    initial ? 
    field iban1    as character  initial ? 
    field iban2    as character  initial ? 
    field lbnatio  as character  initial ? 
    field lgiban   as integer    initial ? 
    field lib      as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
