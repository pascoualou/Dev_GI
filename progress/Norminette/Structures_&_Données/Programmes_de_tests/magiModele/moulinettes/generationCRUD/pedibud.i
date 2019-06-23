/*------------------------------------------------------------------------
File        : pedibud.i
Purpose     : Edition des budgets (fichier de travail)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPedibud
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana1-cd  as character  initial ? 
    field ana2-cd  as character  initial ? 
    field ana3-cd  as character  initial ? 
    field ana4-cd  as character  initial ? 
    field gi-ttyid as character  initial ? 
    field type     as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
