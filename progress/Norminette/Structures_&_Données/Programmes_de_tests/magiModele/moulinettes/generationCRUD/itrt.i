/*------------------------------------------------------------------------
File        : itrt.i
Purpose     : parametrage traitement en local
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttItrt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field div1     as character  initial ? 
    field div2     as character  initial ? 
    field div3     as character  initial ? 
    field div4     as character  initial ? 
    field div5     as character  initial ? 
    field dom-cd   as integer    initial ? 
    field fg-local as logical    initial ? 
    field fg-mdenv as logical    initial ? 
    field fg-oblig as logical    initial ? 
    field impr-cd  as character  initial ? 
    field lib      as character  initial ? 
    field soc-cd   as integer    initial ? 
    field trt-cd   as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
