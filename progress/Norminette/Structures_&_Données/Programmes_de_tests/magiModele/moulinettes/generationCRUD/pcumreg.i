/*------------------------------------------------------------------------
File        : pcumreg.i
Purpose     : cumul des cheques et des effets
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPcumreg
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ante     as logical    initial ? 
    field bqjou-cd as character  initial ? 
    field ctype    as character  initial ? 
    field daan     as integer    initial ? 
    field damois   as integer    initial ? 
    field etab-cd  as integer    initial ? 
    field jou-cd   as character  initial ? 
    field mt       as decimal    initial ?  decimals 5
    field mt-EURO  as decimal    initial ?  decimals 5
    field nb       as integer    initial ? 
    field soc-cd   as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
