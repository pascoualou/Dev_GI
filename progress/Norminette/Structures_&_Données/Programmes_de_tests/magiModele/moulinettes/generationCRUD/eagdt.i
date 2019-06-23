/*------------------------------------------------------------------------
File        : eagdt.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttEagdt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcle                  as character  initial ? 
    field cdcsy                  as character  initial ? 
    field cddev                  as character  initial ? 
    field cdmsy                  as character  initial ? 
    field cLibelleSousResolution as character  initial ? 
    field dtcsy                  as date       initial ? 
    field dtmsy                  as date       initial ? 
    field hecsy                  as integer    initial ? 
    field hemsy                  as integer    initial ? 
    field iResolutionParam       as integer    initial ? 
    field iSousResolution        as integer    initial ? 
    field iSousResolutionParam   as integer    initial ? 
    field lbdiv                  as character  initial ? 
    field lbdiv2                 as character  initial ? 
    field lbdiv3                 as character  initial ? 
    field lbres                  as character  initial ? 
    field noadd                  as integer    initial ? 
    field noint                  as integer    initial ? 
    field nores                  as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
