/*------------------------------------------------------------------------
File        : TrInt.i
Purpose     : Chaine Travaux : Traitement des Interventions
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTrint
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field CdCsy  as character  initial ? 
    field CdMsy  as character  initial ? 
    field CdSta  as character  initial ? 
    field CdTrt  as character  initial ? 
    field DtCsy  as date       initial ? 
    field DtMsy  as date       initial ? 
    field DuTrt  as integer    initial ? 
    field HeCsy  as integer    initial ? 
    field HeMsy  as integer    initial ? 
    field LbCom  as character  initial ? 
    field LbDiv1 as character  initial ? 
    field LbDiv2 as character  initial ? 
    field LbDiv3 as character  initial ? 
    field NoIdt  as int64      initial ? 
    field NoInt  as int64      initial ? 
    field NoRef  as integer    initial ? 
    field NoTrt  as int64      initial ? 
    field RgTrt  as integer    initial ? 
    field TpTrt  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
