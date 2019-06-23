/*------------------------------------------------------------------------
File        : autoComplete.i
Description : dataset pour les champs auto-complete
Author(s)   : kantena - 2016/02/04
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAutoCompleteGeneric 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iSeqId     as integer
    field cCode      as character
    field cLibelle1  as character
    field cLibelle2  as character
    field cLibelle3  as character
    field cLibelle4  as character
    field cLibelle5  as character
    field cLibelle6  as character
    field cLibelle7  as character
    field cLibelle8  as character
    field cLibelle9  as character
    field cLibelle10 as character
    field cLibelle11 as character
    field cLibelle12 as character
    field cLibelle13 as character
index primaire is primary iSeqId cCode.
