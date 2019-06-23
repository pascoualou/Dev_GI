/*------------------------------------------------------------------------
File        : Equipements.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttEquipements
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cChampFusion    as character  initial ? 
    field cCodeEquipement as character  initial ? 
    field cdcsy           as character  initial ? 
    field cDesignation    as character  initial ? 
    field cdmsy           as character  initial ? 
    field cListeValeurs   as character  initial ? 
    field dtcsy           as date       initial ? 
    field dtmsy           as date       initial ? 
    field fgImmeuble      as logical    initial ? 
    field fgLot           as logical    initial ? 
    field fgNombre        as logical    initial ? 
    field fgOuiNon        as logical    initial ? 
    field fgValeur        as logical    initial ? 
    field hecsy           as integer    initial ? 
    field hemsy           as integer    initial ? 
    field lbdiv           as character  initial ? 
    field lbdiv2          as character  initial ? 
    field lbdiv3          as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
