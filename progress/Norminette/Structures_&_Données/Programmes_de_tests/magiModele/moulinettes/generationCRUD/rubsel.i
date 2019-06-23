/*------------------------------------------------------------------------
File        : rubsel.i
Purpose     : Sélection des rubriques pour les calculs honoraires, rubriques calculées ou autres (0511/0025)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRubsel
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy  as character  initial ? 
    field cdlib  as character  initial ? 
    field cdmsy  as character  initial ? 
    field cdrub  as character  initial ? 
    field dtcsy  as date       initial ? 
    field dtmsy  as date       initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field ixd01  as character  initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field noct2  as int64      initial ? 
    field nomdt  as integer    initial ? 
    field notri  as integer    initial ? 
    field Tpct2  as character  initial ? 
    field tpmdt  as character  initial ? 
    field tprub  as character  initial ? 
    field tptac  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
