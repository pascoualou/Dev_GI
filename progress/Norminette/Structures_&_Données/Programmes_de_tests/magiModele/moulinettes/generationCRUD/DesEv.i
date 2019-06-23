/*------------------------------------------------------------------------
File        : DesEv.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttDesev
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field CdCsy  as character  initial ? 
    field CdMsy  as character  initial ? 
    field DtCsy  as date       initial ? 
    field DtMsy  as date       initial ? 
    field fgenv  as logical    initial ? 
    field HeCsy  as integer    initial ? 
    field HeMsy  as integer    initial ? 
    field LbCom  as character  initial ? 
    field LbDiv1 as character  initial ? 
    field LbDiv2 as character  initial ? 
    field LbDiv3 as character  initial ? 
    field NoAct  as integer    initial ? 
    field NoEve  as integer    initial ? 
    field NoRol  as int64      initial ? 
    field TpDes  as character  initial ? 
    field TpRol  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
