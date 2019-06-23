/*------------------------------------------------------------------------
File        : cd2cor.i
Purpose     : Correspondance DAS2
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCd2cor
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cpt-cd    as character  initial ? 
    field d2ven-cle as character  initial ? 
    field soc-cd    as integer    initial ? 
    field zone-cd   as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
