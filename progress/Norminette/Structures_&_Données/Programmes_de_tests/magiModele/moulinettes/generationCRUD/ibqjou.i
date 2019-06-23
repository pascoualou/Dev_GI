/*------------------------------------------------------------------------
File        : ibqjou.i
Purpose     : Paramètres banque par défaut
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIbqjou
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field bqjou-cd  as character  initial ? 
    field cdregl    as character  initial ? 
    field coll-cle  as character  initial ? 
    field etab-cd   as integer    initial ? 
    field lstselect as character  initial ? 
    field soc-cd    as integer    initial ? 
    field tpregl    as character  initial ? 
    field type      as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
