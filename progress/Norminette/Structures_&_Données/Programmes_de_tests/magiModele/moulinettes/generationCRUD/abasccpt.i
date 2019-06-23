/*------------------------------------------------------------------------
File        : abasccpt.i
Purpose     : Table de correspondance compte de banque
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAbasccpt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cpt-anc    as character  initial ? 
    field cpt-cd     as character  initial ? 
    field divers     as character  initial ? 
    field etab-cd    as integer    initial ? 
    field scoll-cle  as character  initial ? 
    field soc-cd     as integer    initial ? 
    field sscoll-anc as character  initial ? 
    field type       as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
