/*------------------------------------------------------------------------
File        : parts.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttParts
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy        as character  initial ? 
    field cdmsy        as character  initial ? 
    field crrent       as integer    initial ? 
    field dbrent       as integer    initial ? 
    field dtcsy        as date       initial ? 
    field dtfin        as date       initial ? 
    field dtmsy        as date       initial ? 
    field dtmvt        as date       initial ? 
    field fgind-crrent as logical    initial ? 
    field fgind-dbrent as logical    initial ? 
    field fgind-nuprop as logical    initial ? 
    field fgind-prop   as logical    initial ? 
    field fgind-usuf   as logical    initial ? 
    field hecsy        as integer    initial ? 
    field hemsy        as integer    initial ? 
    field lbdiv        as character  initial ? 
    field lbdiv2       as character  initial ? 
    field lbdiv3       as character  initial ? 
    field lbmvt        as character  initial ? 
    field nbpar-nuprop as integer    initial ? 
    field nbpar-prop   as integer    initial ? 
    field nbpar-usuf   as integer    initial ? 
    field noben        as integer    initial ? 
    field nocon        as int64      initial ? 
    field nodeb        as integer    initial ? 
    field nofin        as integer    initial ? 
    field noidt        as int64      initial ? 
    field nomvt        as integer    initial ? 
    field tpben        as character  initial ? 
    field tpcon        as character  initial ? 
    field tpidt        as character  initial ? 
    field tpmvt        as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
