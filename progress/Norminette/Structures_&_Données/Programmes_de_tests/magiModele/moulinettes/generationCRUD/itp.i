/*------------------------------------------------------------------------
File        : itp.i
Purpose     : Liste des differents taux de taxes paraf.
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttItp
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field etab-cd   as integer    initial ? 
    field lib       as character  initial ? 
    field libass-cd as integer    initial ? 
    field soc-cd    as integer    initial ? 
    field taux      as decimal    initial ?  decimals 8
    field tp-cd     as integer    initial ? 
    field type      as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
