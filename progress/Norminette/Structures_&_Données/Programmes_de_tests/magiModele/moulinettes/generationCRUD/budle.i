/*------------------------------------------------------------------------
File        : budle.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttBudle
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy      as character  initial ? 
    field cddev      as character  initial ? 
    field cdmsy      as character  initial ? 
    field dtcsy      as date       initial ? 
    field dtdeb      as date       initial ? 
    field dtDebRea   as date       initial ? 
    field dtDupli    as date       initial ? 
    field dtfin      as date       initial ? 
    field dtFinRea   as date       initial ? 
    field dtmsy      as date       initial ? 
    field dtval      as date       initial ? 
    field fgavt      as logical    initial ? 
    field fgDupRea   as logical    initial ? 
    field fgtva      as logical    initial ? 
    field fgval      as logical    initial ? 
    field hecsy      as integer    initial ? 
    field hemsy      as integer    initial ? 
    field lbbud      as character  initial ? 
    field lbdiv      as character  initial ? 
    field lbdiv2     as character  initial ? 
    field lbdiv3     as character  initial ? 
    field mtbud      as decimal    initial ?  decimals 2
    field mtbud-dev  as decimal    initial ?  decimals 2
    field mttva      as decimal    initial ?  decimals 2
    field mttva-dev  as decimal    initial ?  decimals 2
    field nbmois     as integer    initial ? 
    field NmUsrDupli as character  initial ? 
    field noavt      as integer    initial ? 
    field nobud      as int64      initial ? 
    field nomdt      as integer    initial ? 
    field tpbud      as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
