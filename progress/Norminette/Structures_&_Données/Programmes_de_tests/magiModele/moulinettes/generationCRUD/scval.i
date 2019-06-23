/*------------------------------------------------------------------------
File        : scval.i
Purpose     : 0110/0169 : Mémoriser la valeur des parts par date
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttScval
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy  as character  initial ? 
    field cdmsy  as character  initial ? 
    field divers as character  initial ? 
    field dtcsy  as date       initial ? 
    field dthist as date       initial ? 
    field dtmsy  as date       initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field nbprt  as integer    initial ? 
    field nomax  as integer    initial ? 
    field nomin  as integer    initial ? 
    field nosoc  as integer    initial ? 
    field pxprt  as decimal    initial ?  decimals 2
    field pxtot  as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
