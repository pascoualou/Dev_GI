/*------------------------------------------------------------------------
File        : iengparc.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIengparc
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana-cd     as character  initial ? 
    field etab-cd    as integer    initial ? 
    field jou-cd     as character  initial ? 
    field niv-num    as integer    initial ? 
    field soc-cd     as integer    initial ? 
    field sscoll-cle as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
