/*------------------------------------------------------------------------
File        : cedibud.i
Purpose     : Fichier edition des budgets
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCedibud
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana1-cd         as character  initial ? 
    field ana2-cd         as character  initial ? 
    field ana3-cd         as character  initial ? 
    field ana4-cd         as character  initial ? 
    field cpt-cd          as character  initial ? 
    field cpt2-cd         as character  initial ? 
    field gi-ttyid        as character  initial ? 
    field mtprev          as decimal    initial ?  decimals 2
    field mtprev-cum      as decimal    initial ?  decimals 2
    field mtprev-cum-EURO as decimal    initial ?  decimals 2
    field mtprev-EURO     as decimal    initial ?  decimals 2
    field mtreel          as decimal    initial ?  decimals 2
    field mtreel-cum      as decimal    initial ?  decimals 2
    field mtreel-cum-EURO as decimal    initial ?  decimals 2
    field mtreel-EURO     as decimal    initial ?  decimals 2
    field rub-cd          as integer    initial ? 
    field sscoll-cle      as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
