/*------------------------------------------------------------------------
File        : idepot.i
Purpose     : Fichier Depot
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIdepot
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field adr         as character  initial ? 
    field cal-reappro as character  initial ? 
    field cp          as character  initial ? 
    field dep-type    as integer    initial ? 
    field depot-cd    as integer    initial ? 
    field etab-cd     as integer    initial ? 
    field fax         as character  initial ? 
    field lib         as character  initial ? 
    field libpays-cd  as character  initial ? 
    field lieu-cle    as integer    initial ? 
    field reappro     as logical    initial ? 
    field responsable as character  initial ? 
    field serie       as logical    initial ? 
    field soc-cd      as integer    initial ? 
    field tel         as character  initial ? 
    field telex       as character  initial ? 
    field ville       as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
