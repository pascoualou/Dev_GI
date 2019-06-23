/*------------------------------------------------------------------------
File        : pclid.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPclid
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy as character  initial ? 
    field cdmsy as character  initial ? 
    field dtcsy as date       initial ? 
    field dtmsy as date       initial ? 
    field fgpri as logical    initial ? 
    field hecsy as integer    initial ? 
    field hemsy as integer    initial ? 
    field lbdiv as character  initial ? 
    field lslib as character  initial ? 
    field nomes as integer    initial ? 
    field tpapp as character  initial ? 
    field tppar as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
