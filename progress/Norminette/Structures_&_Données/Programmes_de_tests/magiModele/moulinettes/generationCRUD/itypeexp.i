/*------------------------------------------------------------------------
File        : itypeexp.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttItypeexp
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field div1       as character  initial ? 
    field div2       as character  initial ? 
    field div3       as character  initial ? 
    field expe-cd    as character  initial ? 
    field mandat-cd  as integer    initial ? 
    field mregl-cd   as character  initial ? 
    field soc-cd     as integer    initial ? 
    field tri-cd     as character  initial ? 
    field trt-cd     as integer    initial ? 
    field typedoc-cd as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
