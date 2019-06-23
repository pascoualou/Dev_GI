/*------------------------------------------------------------------------
File        : icmc7.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIcmc7
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field coll-cle  as character  initial ? 
    field etab-cd   as integer    initial ? 
    field nodoc     as integer    initial ? 
    field num-zib   as character  initial ? 
    field num-zin   as character  initial ? 
    field ordre-num as integer    initial ? 
    field soc-cd    as integer    initial ? 
    field tiers-cle as character  initial ? 
    field tprole    as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
