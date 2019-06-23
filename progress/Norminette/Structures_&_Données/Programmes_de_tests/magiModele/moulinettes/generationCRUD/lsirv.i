/*------------------------------------------------------------------------
File        : lsirv.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttLsirv
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy as character  initial ? 
    field cdind as character  initial ? 
    field cdirv as integer    initial ? 
    field cdmsy as character  initial ? 
    field cdper as integer    initial ? 
    field dtcsy as date       initial ? 
    field dtmsy as date       initial ? 
    field fgaut as character  initial ? 
    field fgval as integer    initial ? 
    field hecsy as integer    initial ? 
    field hemsy as integer    initial ? 
    field lbcrt as character  initial ? 
    field lblng as character  initial ? 
    field nbdec as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
