/*------------------------------------------------------------------------
File        : aligtvah.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAligtvah
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cat-cd     as integer    initial ? 
    field cdlib      as integer    initial ? 
    field cdrub      as integer    initial ? 
    field chrono     as integer    initial ? 
    field cmthono    as character  initial ? 
    field dahist     as date       initial ? 
    field etab-cd    as integer    initial ? 
    field mtht       as decimal    initial ?  decimals 2
    field mttva      as decimal    initial ?  decimals 2
    field num-int    as integer    initial ? 
    field periode-cd as integer    initial ? 
    field soc-cd     as integer    initial ? 
    field taux       as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
