/*------------------------------------------------------------------------
File        : apointe.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttApointe
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field dacrea        as date       initial ? 
    field daplafond     as date       initial ? 
    field dapointe      as date       initial ? 
    field fg-type       as logical    initial ? 
    field ihcrea        as integer    initial ? 
    field mt-copro      as decimal    initial ?  decimals 2
    field mt-copro-EURO as decimal    initial ?  decimals 2
    field mt-ger        as decimal    initial ?  decimals 2
    field mt-ger-EURO   as decimal    initial ?  decimals 2
    field soc-cd        as integer    initial ? 
    field usrid         as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
