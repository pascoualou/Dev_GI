/*------------------------------------------------------------------------
File        : EmpAp.i
Purpose     : Emprunts : Table des n° d'appel de fond
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttEmpap
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field CdCsy     as character  initial ? 
    field CdMsy     as character  initial ? 
    field DtApp     as date       initial ? 
    field DtCsy     as date       initial ? 
    field dtech-deb as date       initial ? 
    field dtech-fin as date       initial ? 
    field DtMsy     as date       initial ? 
    field FgEmi     as logical    initial ? 
    field HeCsy     as integer    initial ? 
    field HeMsy     as integer    initial ? 
    field LbCom     as character  initial ? 
    field LbDiv1    as character  initial ? 
    field LbDiv2    as character  initial ? 
    field LbDiv3    as character  initial ? 
    field Mtapp     as decimal    initial ?  decimals 3
    field NoApp     as integer    initial ? 
    field NoCon     as integer    initial ? 
    field NoEmp     as integer    initial ? 
    field NoRef     as integer    initial ? 
    field TpCon     as character  initial ? 
    field TpEmp     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
