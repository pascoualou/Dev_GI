/*------------------------------------------------------------------------
File        : ttRubriqueAnalytique.i
Description :
Author(s)   : DMI 20180330
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRubriqueAnalytique
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cCode    as character initial ? label "rub-cd"
    field cLibelle as character initial ? label "lib"
.
