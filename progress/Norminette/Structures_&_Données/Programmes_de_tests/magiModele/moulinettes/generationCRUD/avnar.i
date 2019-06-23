/*------------------------------------------------------------------------
File        : avnar.i
Purpose     : Avantages en nature (entete)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAvnar
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy  as character  initial ? 
    field cdmsy  as character  initial ? 
    field dtcsy  as date       initial ? 
    field dtmsy  as date       initial ? 
    field dtval  as date       initial ? 
    field fgval  as logical    initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field mspai  as integer    initial ? 
    field noann  as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
