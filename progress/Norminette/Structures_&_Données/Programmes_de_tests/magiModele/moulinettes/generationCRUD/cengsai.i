/*------------------------------------------------------------------------
File        : cengsai.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCengsai
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana-cd     as character  initial ? 
    field coll-cle   as character  initial ? 
    field comment    as character  initial ? 
    field cpt-cd     as character  initial ? 
    field daeng      as date       initial ? 
    field engag-num  as character  initial ? 
    field etab-cd    as integer    initial ? 
    field four-cle   as character  initial ? 
    field lib        as character  initial ? 
    field niv-num    as integer    initial ? 
    field num-int    as integer    initial ? 
    field soc-cd     as integer    initial ? 
    field sscoll-cle as character  initial ? 
    field statut     as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
