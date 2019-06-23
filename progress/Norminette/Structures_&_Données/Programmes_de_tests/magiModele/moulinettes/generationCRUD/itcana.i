/*------------------------------------------------------------------------
File        : itcana.i
Purpose     : Transfert compta - parametres compta analytique
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttItcana
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field emb-ana   as character  initial ? 
    field escpt-ana as character  initial ? 
    field etab-cd   as integer    initial ? 
    field gsc-cd    as integer    initial ? 
    field nature-cd as character  initial ? 
    field niv-cd    as integer    initial ? 
    field port-ana  as character  initial ? 
    field remex-ana as character  initial ? 
    field soc-cd    as integer    initial ? 
    field type      as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
