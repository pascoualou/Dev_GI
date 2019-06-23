/*------------------------------------------------------------------------
File        : issfama.i
Purpose     : fichier des sous-sous-familles d'affaires
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIssfama
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field etab-cd  as integer    initial ? 
    field fam-cd   as integer    initial ? 
    field lib      as character  initial ? 
    field sfam-cd  as integer    initial ? 
    field soc-cd   as integer    initial ? 
    field ssfam-cd as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
