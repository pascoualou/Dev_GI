/*------------------------------------------------------------------------
File        : indln.i
Purpose     : Ligne d'indice
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIndln
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field dadeb     as date       initial ? 
    field dafin     as date       initial ? 
    field etab-cd   as integer    initial ? 
    field indbase   as decimal    initial ?  decimals 2
    field indice-cd as character  initial ? 
    field majo      as decimal    initial ?  decimals 2
    field signe     as character  initial ? 
    field soc-cd    as integer    initial ? 
    field taux      as decimal    initial ?  decimals 2
    field tppar     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
