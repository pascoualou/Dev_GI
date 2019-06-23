/*------------------------------------------------------------------------
File        : intev.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIntev
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy  as character  initial ? 
    field cdmsy  as character  initial ? 
    field chix1  as character  initial ? 
    field chix2  as character  initial ? 
    field dtcsy  as date       initial ? 
    field dtmsy  as date       initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field noact  as integer    initial ? 
    field noeve  as int64      initial ? 
    field noevi  as int64      initial ? 
    field noidt  as int64      initial ? 
    field noord  as integer    initial ? 
    field tpeve  as character  initial ? 
    field tpidt  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
