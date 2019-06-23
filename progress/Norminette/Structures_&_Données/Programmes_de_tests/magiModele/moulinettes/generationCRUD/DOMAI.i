/*------------------------------------------------------------------------
File        : DOMAI.i
Purpose     : Domaine
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttDomai
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy  as character  initial ? 
    field cddev  as character  initial ? 
    field cddom  as character  initial ? 
    field cdmsy  as character  initial ? 
    field dtcsy  as date       initial ? 
    field dtmsy  as date       initial ? 
    field dtsup  as date       initial ? 
    field fgdes  as logical    initial ? 
    field fgsup  as logical    initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field lbcom  as character  initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field lbdom  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
