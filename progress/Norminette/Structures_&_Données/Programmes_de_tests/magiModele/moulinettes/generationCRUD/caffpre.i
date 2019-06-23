/*------------------------------------------------------------------------
File        : caffpre.i
Purpose     : Saisie affaires previsionnelles
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCaffpre
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field affair-num  as integer    initial ? 
    field cpt-cd      as character  initial ? 
    field dadeb       as date       initial ? 
    field dafin       as date       initial ? 
    field daprev      as character  initial ? 
    field etab-cd     as integer    initial ? 
    field mtprev      as decimal    initial ?  decimals 2
    field mtprev-EURO as decimal    initial ?  decimals 2
    field soc-cd      as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
