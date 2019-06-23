/*------------------------------------------------------------------------
File        : crbfmt.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCrbfmt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field champs-cle as character  initial ? 
    field fchamps    as character  initial ? 
    field fg-0       as logical    initial ? 
    field fg-cadrage as logical    initial ? 
    field log-cle    as character  initial ? 
    field posdeb     as integer    initial ? 
    field posfin     as integer    initial ? 
    field separ      as character  initial ? 
    field soc-cd     as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
