/*------------------------------------------------------------------------
File        : iscrl1.i
Purpose     : avis d'office
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIscrl1
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field adr         as character  initial ? 
    field adr1        as character  initial ? 
    field civilite    as character  initial ? 
    field cp          as character  initial ? 
    field cp1         as character  initial ? 
    field dat-eff     as character  initial ? 
    field dat-pbilan  as character  initial ? 
    field date-juge   as character  initial ? 
    field duree       as character  initial ? 
    field ext-nom     as character  initial ? 
    field ext-nom1    as character  initial ? 
    field libpays-cd  as character  initial ? 
    field libpays-cd1 as character  initial ? 
    field nat-jugemt  as character  initial ? 
    field nic         as character  initial ? 
    field nic-num     as integer    initial ? 
    field nom         as character  initial ? 
    field prenom      as character  initial ? 
    field rs          as character  initial ? 
    field rs1         as character  initial ? 
    field scrl-num    as integer    initial ? 
    field siren-num   as integer    initial ? 
    field siret       as character  initial ? 
    field soc-cd      as integer    initial ? 
    field tel         as character  initial ? 
    field tel1        as character  initial ? 
    field type-perte  as character  initial ? 
    field ville       as character  initial ? 
    field ville1      as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
