/*------------------------------------------------------------------------
File        : magiPreference.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttMagipreference
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cJson          as clob       initial ? 
    field cRefPrincipale as character  initial ? 
    field cSousType      as character  initial ? 
    field cType          as character  initial ? 
    field cUser          as character  initial ? 
    field horodate       as datetime   initial ? 
    field jSessionId     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
