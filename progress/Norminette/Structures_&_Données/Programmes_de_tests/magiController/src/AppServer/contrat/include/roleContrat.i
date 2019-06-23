/*------------------------------------------------------------------------
File        : roleContrat.i
Purpose     :
Author(s)   : gga - 2017/08/31
Notes       :
derniere revue: 2018/05/16 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRoleMandat 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeContrat   as character initial ?
    field iNumeroContrat as int64     initial ?
    field cTypeRole      as character initial ?
    field cLibTypeRole   as character initial ?
    field iNumeroRole    as int64     initial ?
    field cNom           as character initial ?   
    field cAdresse       as character initial ?   
    field lRolePrincipal as logical   initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid 
.
