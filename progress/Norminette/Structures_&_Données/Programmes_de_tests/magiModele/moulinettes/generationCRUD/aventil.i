/*------------------------------------------------------------------------
File        : aventil.i
Purpose     : Table de ventilation des dépenses de nu propriété
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAventil
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cleadb       as character  initial ? 
    field cpt-cd       as character  initial ? 
    field denominateur as integer    initial ? 
    field dtdeb        as date       initial ? 
    field dtfin        as date       initial ? 
    field etab-cd      as integer    initial ? 
    field fisc-cle     as character  initial ? 
    field Nolot        as integer    initial ? 
    field numerateur   as integer    initial ? 
    field rub-cd       as character  initial ? 
    field soc-cd       as integer    initial ? 
    field ssrub-cd     as character  initial ? 
    field type         as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
