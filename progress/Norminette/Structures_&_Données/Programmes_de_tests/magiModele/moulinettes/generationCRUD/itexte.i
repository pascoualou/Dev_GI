/*------------------------------------------------------------------------
File        : itexte.i
Purpose     : Fichier de lettre
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttItexte
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field etab-cd     as integer    initial ? 
    field libtexte-cd as integer    initial ? 
    field ligne       as character  initial ? 
    field soc-cd      as integer    initial ? 
    field texte-cd    as integer    initial ? 
    field titre       as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
