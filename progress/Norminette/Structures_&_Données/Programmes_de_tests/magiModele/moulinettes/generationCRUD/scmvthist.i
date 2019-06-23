/*------------------------------------------------------------------------
File        : scmvthist.i
Purpose     : Table d'historisation des mouvements de parts
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttScmvthist
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy      as character  initial ? 
    field cdmsy      as character  initial ? 
    field cdope      as character  initial ? 
    field dtcsy      as date       initial ? 
    field dtfin      as date       initial ? 
    field dthist     as date       initial ? 
    field dtmsy      as date       initial ? 
    field dtope      as date       initial ? 
    field FgCrg      as logical    initial ? 
    field hecsy      as integer    initial ? 
    field hemsy      as integer    initial ? 
    field lbdiv      as character  initial ? 
    field lbdiv2     as character  initial ? 
    field lbdiv3     as character  initial ? 
    field nb-crerent as integer    initial ? 
    field nb-dbrent  as integer    initial ? 
    field nb-nuprop  as integer    initial ? 
    field nb-prop    as integer    initial ? 
    field nb-Usuf    as integer    initial ? 
    field noact      as integer    initial ? 
    field nomax      as integer    initial ? 
    field nomin      as integer    initial ? 
    field noord      as integer    initial ? 
    field nopre      as integer    initial ? 
    field nosoc      as integer    initial ? 
    field nosui      as integer    initial ? 
    field nosui02    as integer    initial ? 
    field nosui03    as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
