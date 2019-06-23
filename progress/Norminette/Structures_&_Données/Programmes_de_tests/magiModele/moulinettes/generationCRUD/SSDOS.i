/*------------------------------------------------------------------------
File        : SSDOS.i
Purpose     : Sous-dossier
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttSsdos
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdmsy     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtmsy     as date       initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbcom     as character  initial ? 
    field lbcor     as character  initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field lbssd     as character  initial ? 
    field noact     as integer    initial ? 
    field nobls     as integer    initial ? 
    field noidt     as integer    initial ? 
    field noidt-dec as decimal    initial ?  decimals 0
    field nomod     as integer    initial ? 
    field nossd     as integer    initial ? 
    field tbdat     as date       initial ? 
    field tpidt     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
