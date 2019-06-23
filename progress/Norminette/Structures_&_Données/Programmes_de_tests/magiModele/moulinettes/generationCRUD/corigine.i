/*------------------------------------------------------------------------
File        : corigine.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCorigine
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field fgdef   as logical    initial ? 
    field fixe    as logical    initial ? 
    field lib     as character  initial ? 
    field nooord  as integer    initial ? 
    field order   as integer    initial ? 
    field ori-cle as character  initial ? 
    field soc-cd  as integer    initial ? 
    field zone01  as character  initial ? 
    field zone02  as character  initial ? 
    field zone03  as character  initial ? 
    field zone04  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
