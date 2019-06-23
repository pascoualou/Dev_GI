/*------------------------------------------------------------------------
File        : correspondanceUsageNatureUL.i
Purpose     : 
Author(s)   : GGA  -  2017/08/17
Notes       :
derniere revue: 2018/05/17 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCorrespondanceUsageNatureUL
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cCodeUsage       as character initial ? label "cdusa"
    field cCodeNatureUL    as character initial ? label "ntapp"
    field cLibelleNatureUL as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
