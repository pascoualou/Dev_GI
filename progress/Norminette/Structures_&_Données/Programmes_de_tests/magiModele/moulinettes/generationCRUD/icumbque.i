/*------------------------------------------------------------------------
File        : icumbque.i
Purpose     : Cumuls par banque.
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIcumbque
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field bque-cd       as integer    initial ? 
    field da            as date       initial ? 
    field etab-cd       as integer    initial ? 
    field mtautres      as decimal    initial ?  decimals 2
    field mtautres-EURO as decimal    initial ?  decimals 2
    field mtchq         as decimal    initial ?  decimals 2
    field mtchq-EURO    as decimal    initial ?  decimals 2
    field mttrtenc      as decimal    initial ?  decimals 2
    field mttrtenc-EURO as decimal    initial ?  decimals 2
    field mttrtesc      as decimal    initial ?  decimals 2
    field mttrtesc-EURO as decimal    initial ?  decimals 2
    field nbchq         as integer    initial ? 
    field nbtrtenc      as integer    initial ? 
    field nbtrtesc      as integer    initial ? 
    field soc-cd        as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
