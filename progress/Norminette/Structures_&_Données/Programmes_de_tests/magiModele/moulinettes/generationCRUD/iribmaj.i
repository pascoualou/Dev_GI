/*------------------------------------------------------------------------
File        : iribmaj.i
Purpose     : Liste des rib en attente de validation
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIribmaj
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field adr         as character  initial ? 
    field bic         as character  initial ? 
    field bque        as character  initial ? 
    field bque-nom    as character  initial ? 
    field code_action as character  initial ? 
    field cpt         as character  initial ? 
    field cptetr      as character  initial ? 
    field da_action   as date       initial ? 
    field domicil     as character  initial ? 
    field edition     as logical    initial ? 
    field etab-cd     as integer    initial ? 
    field etr         as logical    initial ? 
    field guichet     as character  initial ? 
    field iban        as character  initial ? 
    field ih_action   as integer    initial ? 
    field ordre-num   as integer    initial ? 
    field rib         as character  initial ? 
    field sel         as logical    initial ? 
    field soc-cd      as integer    initial ? 
    field tiers-cle   as character  initial ? 
    field type        as character  initial ? 
    field usrid       as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
