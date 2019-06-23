/*------------------------------------------------------------------------
File        : GL_CHP.i
Purpose     : Liste des champs du module. Type : 1=>Moteur de recherche, 2=>Fiche (en prévision)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttGl_chp
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy as character  initial ? 
    field cdmsy as character  initial ? 
    field dtcsy as date       initial ? 
    field dtmsy as date       initial ? 
    field hecsy as integer    initial ? 
    field hemsy as integer    initial ? 
    field nochp as integer    initial ? 
    field nomes as integer    initial ? 
    field tpchp as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
