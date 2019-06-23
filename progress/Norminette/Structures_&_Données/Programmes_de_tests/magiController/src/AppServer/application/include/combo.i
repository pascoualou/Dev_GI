/*------------------------------------------------------------------------
File        : combo.i
Description : 
Author(s)   : KANTENA  -  2016/11/09
Notes       :
derniere revue: 2018/05/03 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCombo 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iSeqId    as integer
    field cNomCombo as character
    field cCode     as character
    field cParent   as character   /* pour des combos liés, permet d'avoir le lien du parent */
    field cLibelle  as character
    field cLibelle2 as character
    field cLibelle3 as character
index ix_ttcombo01 is primary unique iSeqId cNomCombo.
