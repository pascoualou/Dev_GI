/*------------------------------------------------------------------------
File        : ilibtexte.i
Purpose     : Fichier libelle texte
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIlibtexte
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field etab-cd     as integer    initial ? 
    field libelle     as character  initial ? 
    field libtexte-cd as integer    initial ? 
    field soc-cd      as integer    initial ? 
    field type        as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
