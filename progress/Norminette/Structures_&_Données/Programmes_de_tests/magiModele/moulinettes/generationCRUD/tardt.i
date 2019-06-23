/*------------------------------------------------------------------------
File        : tardt.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTardt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field CdArt  as character  initial ? 
    field cdcle  as character  initial ? 
    field CdCsy  as character  initial ? 
    field CdMsy  as character  initial ? 
    field DtCsy  as date       initial ? 
    field DtMsy  as date       initial ? 
    field FgInt  as logical    initial ? 
    field HeCsy  as integer    initial ? 
    field HeMsy  as integer    initial ? 
    field LbCom  as character  initial ? 
    field LbDiv1 as character  initial ? 
    field LbDiv2 as character  initial ? 
    field LbDiv3 as character  initial ? 
    field LbInt  as character  initial ? 
    field NoFou  as integer    initial ? 
    field NoImm  as integer    initial ? 
    field nomdt  as integer    initial ? 
    field NoRef  as integer    initial ? 
    field PxUni  as decimal    initial ?  decimals 4
    field TxRem  as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
