/*------------------------------------------------------------------------
File        : cbilrub.i
Purpose     : Rubrique pour les bilans
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCbilrub
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field bilan-cd   as character  initial ? 
    field col1       as integer    initial ? 
    field col2       as integer    initial ? 
    field etab-cd    as integer    initial ? 
    field lib        as character  initial ? 
    field lib2       as character  initial ? 
    field libpays-cd as character  initial ? 
    field num-int    as integer    initial ? 
    field ordre-cle  as character  initial ? 
    field soc-cd     as integer    initial ? 
    field type-rub   as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
