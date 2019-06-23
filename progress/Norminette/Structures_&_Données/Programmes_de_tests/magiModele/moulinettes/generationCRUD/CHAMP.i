/*------------------------------------------------------------------------
File        : CHAMP.i
Purpose     : Champ
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttChamp
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcrt             as character  initial ? 
    field cdcsy             as character  initial ? 
    field cddev             as character  initial ? 
    field cdmsy             as character  initial ? 
    field cdpar             as character  initial ? 
    field chval             as character  initial ? 
    field cTypeValorisation as character  initial ? 
    field dtcsy             as date       initial ? 
    field dtmsy             as date       initial ? 
    field hecsy             as integer    initial ? 
    field hemsy             as integer    initial ? 
    field lbchp             as character  initial ? 
    field lbcom             as character  initial ? 
    field lbdiv             as character  initial ? 
    field lbdiv2            as character  initial ? 
    field lbdiv3            as character  initial ? 
    field lbprl             as character  initial ? 
    field lbprv             as character  initial ? 
    field nbcar             as integer    initial ? 
    field nbdec             as integer    initial ? 
    field nochp             as integer    initial ? 
    field pglis             as character  initial ? 
    field pgval             as character  initial ? 
    field tbpar             as character  initial ? 
    field tbval             as character  initial ? 
    field tpchp             as character  initial ? 
    field tpcnt             as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
