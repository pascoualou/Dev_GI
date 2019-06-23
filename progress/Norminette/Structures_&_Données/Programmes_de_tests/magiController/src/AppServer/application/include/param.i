/*------------------------------------------------------------------------
File        : param.i
Purpose     : 
Author(s)   : kantena - 2016/10/10
Notes       :
derniere revue: 2018/05/03 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttparam 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeParam as character initial ? label "tppar"
    field cParam     as character initial ? label "zon01"
.
