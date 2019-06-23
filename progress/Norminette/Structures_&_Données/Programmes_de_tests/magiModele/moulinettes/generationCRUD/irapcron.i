/*------------------------------------------------------------------------
File        : irapcron.i
Purpose     : Contient rapports sur icron
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIrapcron
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field code-cron as integer    initial ? 
    field etab-cd   as integer    initial ? 
    field fg-fin    as logical    initial ? 
    field heure-deb as integer    initial ? 
    field heure-fin as integer    initial ? 
    field jour-cron as date       initial ? 
    field jour-deb  as date       initial ? 
    field jour-fin  as date       initial ? 
    field lib       as character  initial ? 
    field nolan     as integer    initial ? 
    field soc-cd    as integer    initial ? 
    field type-cron as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
