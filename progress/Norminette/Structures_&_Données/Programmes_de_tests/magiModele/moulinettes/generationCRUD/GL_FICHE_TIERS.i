/*------------------------------------------------------------------------
File        : GL_FICHE_TIERS.i
Purpose     : Liaison Fiche / Tiers
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttGl_fiche_tiers
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy       as character  initial ? 
    field cdmsy       as character  initial ? 
    field dtcsy       as date       initial ? 
    field dtmsy       as date       initial ? 
    field four-cle    as character  initial ? 
    field hecsy       as integer    initial ? 
    field hemsy       as integer    initial ? 
    field nofiche     as integer    initial ? 
    field nohisto     as integer    initial ? 
    field norol       as integer    initial ? 
    field notiers     as character  initial ? 
    field soccd       as character  initial ? 
    field tprol       as character  initial ? 
    field tprolefiche as character  initial ? 
    field tptiers     as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
