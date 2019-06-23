/*------------------------------------------------------------------------
File        : iscirub.i
Purpose     : Table de correspondances rubriques SCI
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIscirub
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cpt-att       as character  initial ? 
    field cpt-sci       as character  initial ? 
    field cpt-sci-nr    as character  initial ? 
    field rub-cd        as character  initial ? 
    field soc-cd        as integer    initial ? 
    field sscoll-sci    as character  initial ? 
    field sscoll-sci-nr as character  initial ? 
    field ssrub-cd      as character  initial ? 
    field type-rub      as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
