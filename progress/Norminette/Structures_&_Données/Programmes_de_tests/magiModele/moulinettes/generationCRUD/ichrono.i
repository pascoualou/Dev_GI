/*------------------------------------------------------------------------
File        : ichrono.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIchrono
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field bord-cd    as character  initial ? 
    field bque       as character  initial ? 
    field chrono-num as integer    initial ? 
    field cpt        as character  initial ? 
    field etab-cd    as integer    initial ? 
    field fg-A4      as logical    initial ? 
    field fg-active  as logical    initial ? 
    field guichet    as character  initial ? 
    field numdeb     as integer    initial ? 
    field numfin     as integer    initial ? 
    field rib        as character  initial ? 
    field soc-cd     as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
