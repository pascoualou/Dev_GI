/*------------------------------------------------------------------------
File        : aspno.i
Purpose     : assurance propriétaire non occupant
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAspno
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcmp       as character  initial ? 
    field cdcsy       as character  initial ? 
    field cdmsy       as character  initial ? 
    field cmotif      as character  initial ? 
    field dtcotis1    as date       initial ? 
    field dtcsy       as date       initial ? 
    field dtdebass    as date       initial ? 
    field dtfinass    as date       initial ? 
    field dtmsy       as date       initial ? 
    field dttrtcotis1 as date       initial ? 
    field Fgtrtcotis1 as logical    initial ? 
    field hecsy       as integer    initial ? 
    field hemsy       as integer    initial ? 
    field lbdiv       as character  initial ? 
    field lbdiv2      as character  initial ? 
    field lbdiv3      as character  initial ? 
    field mtcotis1    as decimal    initial ?  decimals 2
    field noapp       as integer    initial ? 
    field nobar       as integer    initial ? 
    field nocon       as int64      initial ? 
    field nogar       as integer    initial ? 
    field nolot       as integer    initial ? 
    field noord       as integer    initial ? 
    field numcontrat  as character  initial ? 
    field tpcon       as character  initial ? 
    field tpgar       as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
