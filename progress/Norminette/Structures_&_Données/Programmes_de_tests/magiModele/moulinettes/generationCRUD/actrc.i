/*------------------------------------------------------------------------
File        : actrc.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttActrc
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cptdeb      as character  initial ? 
    field cptfin      as character  initial ? 
    field fg-coll-cle as logical    initial ? 
    field fg-compta   as logical    initial ? 
    field fg-conf     as logical    initial ? 
    field fg-fdr      as logical    initial ? 
    field fg-libsoc   as logical    initial ? 
    field fg-sscpt    as logical    initial ? 
    field fg-tiers    as logical    initial ? 
    field libcom      as character  initial ? 
    field sscptdeb    as character  initial ? 
    field sscptfin    as character  initial ? 
    field tprole      as integer    initial ? 
    field type-cd     as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
