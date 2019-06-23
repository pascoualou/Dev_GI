/*------------------------------------------------------------------------
File        : scind.i
Purpose     : Liste des indivisions
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttScind
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy      as character  initial ? 
    field cdmsy      as character  initial ? 
    field cdope      as character  initial ? 
    field dtcsy      as date       initial ? 
    field dtdeb      as date       initial ? 
    field dtmsy      as date       initial ? 
    field hecsy      as integer    initial ? 
    field hemsy      as integer    initial ? 
    field lbdiv      as character  initial ? 
    field lbdiv2     as character  initial ? 
    field lbdiv3     as character  initial ? 
    field noind      as integer    initial ? 
    field tot-nuprop as integer    initial ? 
    field tot-tant   as integer    initial ? 
    field tot-usuf   as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
