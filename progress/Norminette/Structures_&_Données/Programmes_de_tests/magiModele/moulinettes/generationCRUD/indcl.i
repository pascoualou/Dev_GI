/*------------------------------------------------------------------------
File        : indcl.i
Purpose     : Indices de révision CLIENTS
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIndcl
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy  as character  initial ? 
    field cdind  as character  initial ? 
    field cdmsy  as character  initial ? 
    field cdper  as integer    initial ? 
    field dtcsy  as date       initial ? 
    field dtmsy  as date       initial ? 
    field fgaut  as logical    initial ? 
    field formu  as character  initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field lbind  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
