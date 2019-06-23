/*------------------------------------------------------------------------
File        : airf.i
Purpose     : Recap IRF
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAirf
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field annee   as integer    initial ? 
    field divers  as character  initial ? 
    field etab-cd as integer    initial ? 
    field irf-cd  as character  initial ? 
    field lib     as character  initial ? 
    field mt      as decimal    initial ?  decimals 2
    field soc-cd  as integer    initial ? 
    field type-cd as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
