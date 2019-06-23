/*------------------------------------------------------------------------
File        : EquipBien.i
Purpose     : Equipement de l'immeuble ou du lot
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttEquipbien
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cCodeEquipement     as character  initial ? 
    field cCommentaire        as character  initial ? 
    field cContratMaintenance as character  initial ? 
    field cdcsy               as character  initial ? 
    field cdmsy               as character  initial ? 
    field cEntreprise         as character  initial ? 
    field cTypeBien           as character  initial ? 
    field cValeur             as character  initial ? 
    field dtcsy               as date       initial ? 
    field dtmsy               as date       initial ? 
    field fgOuiNon            as logical    initial ? 
    field hecsy               as integer    initial ? 
    field hemsy               as integer    initial ? 
    field iNombre             as integer    initial ? 
    field iNumeroBien         as integer    initial ? 
    field lbdiv               as character  initial ? 
    field lbdiv2              as character  initial ? 
    field lbdiv3              as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
