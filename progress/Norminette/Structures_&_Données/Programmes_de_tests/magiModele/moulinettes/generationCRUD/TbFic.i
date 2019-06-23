/*------------------------------------------------------------------------
File        : TbFic.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTbfic
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cCodeTheme as character  initial ? 
    field cdcat      as character  initial ? 
    field cdcsy      as character  initial ? 
    field cdmsy      as character  initial ? 
    field dadeb      as date       initial ? 
    field dafin      as date       initial ? 
    field dtcsy      as date       initial ? 
    field dtmsy      as date       initial ? 
    field hecsy      as integer    initial ? 
    field hemsy      as integer    initial ? 
    field id-fich    as int64      initial ? 
    field LbCom      as character  initial ? 
    field lbdiv      as character  initial ? 
    field lbdiv2     as character  initial ? 
    field lbdiv3     as character  initial ? 
    field lbdoc      as character  initial ? 
    field LbFic      as character  initial ? 
    field noidt      as int64      initial ? 
    field noidt-dec  as decimal    initial ?  decimals 0
    field tpidt      as character  initial ? 
    field typdoc-cd  as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
