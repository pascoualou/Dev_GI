/*------------------------------------------------------------------------
File        : ifdparam.i
Purpose     : Table des parametres facturation
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIfdparam
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field etab-cd    as integer    initial ? 
    field fg-facture as logical    initial ? 
    field fg-od      as logical    initial ? 
    field fpiece     as character  initial ? 
    field fpiecefac  as character  initial ? 
    field par1       as character  initial ? 
    field soc-cd     as integer    initial ? 
    field soc-dest   as integer    initial ? 
    field type-cle-a as character  initial ? 
    field type-cle-f as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
