/*------------------------------------------------------------------------
File        : paramMutation.i
Purpose     :
Author(s)   : GGA 2018/02/07
Notes       : parametrage mutation (gestion immo)
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttParamMutation
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field lMutationGeranceCopro  as logical 

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
