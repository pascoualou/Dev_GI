/*------------------------------------------------------------------------
File        : tacheged.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheged
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field anomalie    as character  initial ? 
    field datesoumis  as date       initial ? 
    field datetraite  as date       initial ? 
    field etat        as character  initial ? 
    field heuresoumis as character  initial ? 
    field heuretraite as character  initial ? 
    field nodoc       as integer    initial ? 
    field nodot       as integer    initial ? 
    field tache       as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
