/*------------------------------------------------------------------------
File        : usageUL.i
Purpose     : 
Author(s)   : GGA  -  2017/08/17
Notes       :
derniere revue: 2018/05/17 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttUsageUL
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cCodeUsage    as character initial ? label "cdusa"
    field cLibelleUsage as character initial ? label "lbusa"

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
