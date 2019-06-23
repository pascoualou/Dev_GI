/*------------------------------------------------------------------------
File        : pliscpt.i
Purpose     : Fichier temporaire des pieces comptabilisees
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPliscpt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field dacompta     as date       initial ? 
    field devetr-cd    as character  initial ? 
    field gi-ttyid     as character  initial ? 
    field jou-cd       as character  initial ? 
    field mt           as decimal    initial ?  decimals 2
    field mt-EURO      as decimal    initial ?  decimals 2
    field mtdev        as decimal    initial ?  decimals 2
    field piece-compta as integer    initial ? 
    field ref-num      as character  initial ? 
    field type-cle     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
