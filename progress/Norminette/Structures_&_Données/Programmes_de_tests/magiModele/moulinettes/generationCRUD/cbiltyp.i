/*------------------------------------------------------------------------
File        : cbiltyp.i
Purpose     : Type de bilan
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCbiltyp
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field etab-cd    as integer    initial ? 
    field lib        as character  initial ? 
    field libpays-cd as character  initial ? 
    field soc-cd     as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
