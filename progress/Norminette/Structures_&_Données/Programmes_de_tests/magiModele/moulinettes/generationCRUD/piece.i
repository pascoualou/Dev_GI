/*------------------------------------------------------------------------
File        : piece.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPiece
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy  as character  initial ? 
    field cddev  as character  initial ? 
    field cdmsy  as character  initial ? 
    field cdniv  as character  initial ? 
    field copie  as character  initial ? 
    field dtcsy  as date       initial ? 
    field dtmsy  as date       initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field noblc  as integer    initial ? 
    field noloc  as int64      initial ? 
    field nopie  as integer    initial ? 
    field ntpie  as character  initial ? 
    field sfpie  as decimal    initial ?  decimals 2
    field uspie  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
