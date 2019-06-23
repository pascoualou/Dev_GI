/*------------------------------------------------------------------------
File        : etdad.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttEtdad
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy  as character  initial ? 
    field cdmsy  as character  initial ? 
    field dtcsy  as date       initial ? 
    field dtgen  as date       initial ? 
    field dtmsy  as date       initial ? 
    field dtrev  as date       initial ? 
    field dtval  as date       initial ? 
    field fgtst  as logical    initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field lbcom  as character  initial ? 
    field lbdiv1 as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field lbent  as character  initial ? 
    field nmgen  as character  initial ? 
    field nmval  as character  initial ? 
    field nodec  as integer    initial ? 
    field noent  as integer    initial ? 
    field noexo  as integer    initial ? 
    field norev  as integer    initial ? 
    field tprev  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
