/*------------------------------------------------------------------------
File        : DEMTRAIT.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttDemtrait
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdretour   as character  initial ? 
    field CDTRAIT    as character  initial ? 
    field CDTYPDEM   as character  initial ? 
    field cdtypdis   as character  initial ? 
    field chknotrt   as logical    initial ? 
    field FGMOISCPT  as logical    initial ? 
    field LBTRAIT    as character  initial ? 
    field NOITE      as integer    initial ? 
    field PREFNMFICH as character  initial ? 
    field sens       as character  initial ? 
    field SUPPORT    as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
