/*------------------------------------------------------------------------
File        : aprmcrg.i
Purpose     : Parametrage du CRG
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAprmcrg
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cfb-cd        as character  initial ? 
    field dacrea        as date       initial ? 
    field damod         as date       initial ? 
    field entete1-mes   as character  initial ? 
    field entete2-mes   as character  initial ? 
    field fisc          as character  initial ? 
    field ihcrea        as integer    initial ? 
    field ihmod         as integer    initial ? 
    field lib           as character  initial ? 
    field num-section   as integer    initial ? 
    field ordre-lig     as integer    initial ? 
    field ordre-sstitre as integer    initial ? 
    field ordre-titre   as integer    initial ? 
    field rub-cd        as character  initial ? 
    field scen-cle      as character  initial ? 
    field soc-cd        as integer    initial ? 
    field ssrub-cd      as character  initial ? 
    field type-ligne    as character  initial ? 
    field type-present  as character  initial ? 
    field usrid         as character  initial ? 
    field usridmod      as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
