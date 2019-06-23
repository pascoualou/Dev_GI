/*------------------------------------------------------------------------
File        : GL_CALCUL_BAREME.i
Purpose     : Liste des calculs des barèmes honoraires ALUR
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttGl_calcul_bareme
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field baremeht        as character  initial ? 
    field baremeht_max    as character  initial ? 
    field baremeht_min    as character  initial ? 
    field baremettc       as character  initial ? 
    field baremettc_max   as character  initial ? 
    field baremettc_min   as character  initial ? 
    field cdcsy           as character  initial ? 
    field cdmsy           as character  initial ? 
    field dtcsy           as date       initial ? 
    field dtmsy           as date       initial ? 
    field fgmeuble        as logical    initial ? 
    field hecsy           as integer    initial ? 
    field hemsy           as integer    initial ? 
    field nobareme        as integer    initial ? 
    field nocalcul_bareme as integer    initial ? 
    field nochpfinance    as integer    initial ? 
    field notaxe          as integer    initial ? 
    field nozonealur      as integer    initial ? 
    field typcalcul       as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
