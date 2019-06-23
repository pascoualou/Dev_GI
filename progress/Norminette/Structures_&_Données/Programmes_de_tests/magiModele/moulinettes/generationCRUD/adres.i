/*------------------------------------------------------------------------
File        : adres.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAdres
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy              as character  initial ? 
    field cddev              as character  initial ? 
    field cdins              as character  initial ? 
    field cdmsy              as character  initial ? 
    field cdpay              as character  initial ? 
    field cdpos              as character  initial ? 
    field cpad2              as character  initial ? 
    field cpad3              as character  initial ? 
    field CplLocConstruction as character  initial ? 
    field CplLocVoie         as character  initial ? 
    field cpvoi              as character  initial ? 
    field dtcsy              as date       initial ? 
    field dtmsy              as date       initial ? 
    field hecsy              as integer    initial ? 
    field hemsy              as integer    initial ? 
    field lbbur              as character  initial ? 
    field lbdiv              as character  initial ? 
    field lbdiv2             as character  initial ? 
    field lbdiv3             as character  initial ? 
    field lbvil              as character  initial ? 
    field lbvoi              as character  initial ? 
    field noadr              as int64      initial ? 
    field ntvoi              as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
