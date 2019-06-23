/*------------------------------------------------------------------------
File        : iregl.i
Purpose     : Fichier descriptif des reglements.
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIregl
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field contre-remb   as logical    initial ? 
    field etab-cd       as integer    initial ? 
    field intervalle    as integer    initial ? 
    field jou-cd        as character  initial ? 
    field jourech       as integer    initial ? 
    field lib           as character  initial ? 
    field libpaie-cd    as integer    initial ? 
    field libregl       as logical    initial ? 
    field mtmin         as decimal    initial ?  decimals 2
    field mtmin-EURO    as decimal    initial ?  decimals 2
    field mtmincli      as decimal    initial ?  decimals 2
    field mtmincli-EURO as decimal    initial ?  decimals 2
    field nbech         as integer    initial ? 
    field nbjour        as integer    initial ? 
    field regl-cd       as integer    initial ? 
    field soc-cd        as integer    initial ? 
    field subregl-cd    as integer    initial ? 
    field type          as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
