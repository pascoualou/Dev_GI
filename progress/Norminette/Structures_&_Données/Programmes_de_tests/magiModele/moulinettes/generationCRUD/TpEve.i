/*------------------------------------------------------------------------
File        : TpEve.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTpeve
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field catbx  as character  initial ? 
    field CdCsy  as character  initial ? 
    field CdMsy  as character  initial ? 
    field CdSdo  as character  initial ? 
    field DtCsy  as date       initial ? 
    field DtMsy  as date       initial ? 
    field dtsup  as date       initial ? 
    field FgAut  as logical    initial ? 
    field FgObl  as logical    initial ? 
    field fgsup  as logical    initial ? 
    field HeCsy  as integer    initial ? 
    field HeMsy  as integer    initial ? 
    field LbAct  as character  initial ? 
    field LbCom  as character  initial ? 
    field LbDiv1 as character  initial ? 
    field LbDiv2 as character  initial ? 
    field LbDiv3 as character  initial ? 
    field NbDel  as integer    initial ? 
    field NoAct  as integer    initial ? 
    field NoOrd  as integer    initial ? 
    field NoTac  as integer    initial ? 
    field TpAct  as character  initial ? 
    field UtDel  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
