/*------------------------------------------------------------------------
File        : bascule.i
Purpose     : Informations relatives à la bascule
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttBascule
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field blocage-ecran  as logical    initial ? 
    field date-bascule   as date       initial ? 
    field date-ctrl      as date       initial ? 
    field date-depart    as date       initial ? 
    field date-envoie    as date       initial ? 
    field date-reception as date       initial ? 
    field fg-bascule     as logical    initial ? 
    field fg-DPS-e       as logical    initial ? 
    field fg-DPS-r       as logical    initial ? 
    field fg-preparation as logical    initial ? 
    field lib-err        as character  initial ? 
    field liste-soc      as character  initial ? 
    field soc-cd         as integer    initial ? 
    field time-bascule   as character  initial ? 
    field time-ctrl      as character  initial ? 
    field time-envoie    as character  initial ? 
    field time-reception as character  initial ? 
    field type-err       as character  initial ? 
    field zone1          as character  initial ? 
    field zone2          as character  initial ? 
    field zone3          as character  initial ? 
    field zone4          as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
