/*------------------------------------------------------------------------
File        : EmpEt.i
Purpose     : Emprunts : Entete appel de fond Emprunt
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttEmpet
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field CdCsy  as character  initial ? 
    field CdMsy  as character  initial ? 
    field DtCsy  as date       initial ? 
    field DtMsy  as date       initial ? 
    field HeCsy  as integer    initial ? 
    field HeMsy  as integer    initial ? 
    field LbCom  as character  initial ? 
    field LbDiv1 as character  initial ? 
    field LbDiv2 as character  initial ? 
    field LbDiv3 as character  initial ? 
    field MtTot  as decimal    initial ?  decimals 3
    field NbApp  as integer    initial ? 
    field NoCon  as integer    initial ? 
    field NoEmp  as integer    initial ? 
    field nolie  as integer    initial ? 
    field NoOrd  as integer    initial ? 
    field NoRef  as integer    initial ? 
    field TpApp  as character  initial ? 
    field TpCon  as character  initial ? 
    field TpEmp  as character  initial ? 
    field TpSur  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
