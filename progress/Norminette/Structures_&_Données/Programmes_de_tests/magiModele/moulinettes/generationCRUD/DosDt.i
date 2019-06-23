/*------------------------------------------------------------------------
File        : DosDt.i
Purpose     : Chaine Travaux : Detail appel de fond travaux
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttDosdt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field CdApp  as character  initial ? 
    field CdCsy  as character  initial ? 
    field CdMsy  as character  initial ? 
    field DtCsy  as date       initial ? 
    field DtMsy  as date       initial ? 
    field HeCsy  as integer    initial ? 
    field HeMsy  as integer    initial ? 
    field LbApp  as character  initial ? 
    field LbCom  as character  initial ? 
    field LbDiv1 as character  initial ? 
    field LbDiv2 as character  initial ? 
    field LbDiv3 as character  initial ? 
    field MtApp  as decimal    initial ?  decimals 3
    field NoApp  as integer    initial ? 
    field NoIdt  as integer    initial ? 
    field NoRef  as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
