/*------------------------------------------------------------------------
File        : familleRubrique.i
Purpose     :
Author(s)   : Kantena  -  2017/11/20
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttFamilleRubrique 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iCodeFamille    as integer
    field cLibelleFamille as character
    field dMontant        as decimal
.
