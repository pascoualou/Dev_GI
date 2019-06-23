/*------------------------------------------------------------------------
File        : suivi.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttSuivi
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdmsy     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtedt     as date       initial ? 
    field dtmsy     as date       initial ? 
    field fgsel     as logical    initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field lbidt     as character  initial ? 
    field lbsui     as character  initial ? 
    field lbval     as character  initial ? 
    field noidt     as int64      initial ? 
    field noidt-dec as decimal    initial ?  decimals 0
    field nosui     as integer    initial ? 
    field notrt     as integer    initial ? 
    field tpidt     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
