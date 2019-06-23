/*------------------------------------------------------------------------
File        : creport.i
Purpose     : Fichier des codes reportings
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCreport
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field etab-cd as integer    initial ? 
    field lib     as character  initial ? 
    field rub-cd  as integer    initial ? 
    field soc-cd  as integer    initial ? 
    field type    as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
