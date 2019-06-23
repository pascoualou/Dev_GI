/*------------------------------------------------------------------------
File        : adecla.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAdecla
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field date_deb   as date       initial ? 
    field date_decla as date       initial ? 
    field gest-cle   as character  initial ? 
    field periode-cd as integer    initial ? 
    field soc-cd     as integer    initial ? 
    field valid      as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
