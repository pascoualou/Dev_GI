/*------------------------------------------------------------------------
File        : idecla.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIdecla
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field dadebprd as date       initial ? 
    field dafinprd as date       initial ? 
    field davalid  as date       initial ? 
    field etab-cd  as integer    initial ? 
    field period   as character  initial ? 
    field soc-cd   as integer    initial ? 
    field type     as character  initial ? 
    field usrid    as character  initial ? 
    field valid    as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
