/*------------------------------------------------------------------------
File        : caffecr.i
Purpose     : Table de consultation des affaires
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCaffecr
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cours        as decimal    initial ?  decimals 8
    field cpt-cd       as character  initial ? 
    field dacompta     as date       initial ? 
    field datecr       as date       initial ? 
    field dev-cd       as character  initial ? 
    field devetr-cd    as character  initial ? 
    field gi-ttyid     as character  initial ? 
    field jou-cd       as character  initial ? 
    field lib          as character  initial ? 
    field mtdev        as decimal    initial ?  decimals 2
    field mtprev       as decimal    initial ?  decimals 2
    field mtprev-EURO  as decimal    initial ?  decimals 2
    field mtreel       as decimal    initial ?  decimals 2
    field mtreel-EURO  as decimal    initial ?  decimals 2
    field piece-compta as integer    initial ? 
    field ref-num      as character  initial ? 
    field sscoll-cle   as character  initial ? 
    field type         as character  initial ? 
    field type-cle     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
