/*------------------------------------------------------------------------
File        : echeancier.i
Purpose     : Table de stockage d'échéanciers divers
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttEcheancier
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy  as character  initial ? 
    field cdmsy  as character  initial ? 
    field dtcsy  as date       initial ? 
    field dtdeb  as date       initial ? 
    field dtfin  as date       initial ? 
    field dtmsy  as date       initial ? 
    field FgEch  as logical    initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field LbEch  as character  initial ? 
    field mtech  as decimal    initial ?  decimals 2
    field nbrech as integer    initial ? 
    field Noct1  as int64      initial ? 
    field noct2  as int64      initial ? 
    field noord  as integer    initial ? 
    field Tpct1  as character  initial ? 
    field Tpct2  as character  initial ? 
    field TpEch  as character  initial ? 
    field tptac  as character  initial ? 
    field Txech  as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
