/*------------------------------------------------------------------------
File        : arib.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttArib
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cpt-cd    as character  initial ? 
    field domicil   as character  initial ? extent 2 
    field etab-cd   as integer    initial ? 
    field nodoc     as integer    initial ? 
    field ordre-num as integer    initial ? 
    field soc-cd    as integer    initial ? 
    field tprole    as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
