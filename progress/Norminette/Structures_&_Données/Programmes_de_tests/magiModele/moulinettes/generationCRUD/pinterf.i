/*------------------------------------------------------------------------
File        : pinterf.i
Purpose     : Fichier interface comptabilite
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPinterf
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cpt-emb   as character  initial ? 
    field cpt-escpt as character  initial ? 
    field cpt-ht    as character  initial ? 
    field cpt-port  as character  initial ? 
    field cpt-remex as character  initial ? 
    field etab-cd   as integer    initial ? 
    field groupe    as logical    initial ? 
    field soc-cd    as integer    initial ? 
    field taxe-cd   as integer    initial ? 
    field type-int  as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
