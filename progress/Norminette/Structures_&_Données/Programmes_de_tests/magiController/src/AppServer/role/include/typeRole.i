/*------------------------------------------------------------------------
File        : typeRole.i
Description : 
Created     :   - 2017/05/10
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTypeRole
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'   
    field cTypeRole        as character initial ?
    field cLibelleTypeRole as character initial ?
    field lAutorise        as logical   initial true
    field cCodeCollectif   as character initial ?
    index idx1 cTypeRole 
.
