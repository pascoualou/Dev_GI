/*------------------------------------------------------------------------
File        : preference.i
Description :
Author(s)   : kantena - 2018/09/10
Notes       : 
derniere revue:
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPreference
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define {&classProp} temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cType       as character
    field cSousType   as character
    field cUser       as character
    field cReference  as character
    field jSessionId  as character
    field dtHorodate  as datetime
    field cJson       as clob
.
