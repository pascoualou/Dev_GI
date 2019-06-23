/*------------------------------------------------------------------------
File        : paramTexteCrg.i
Purpose     : 
Author(s)   : GGA  -  2017/11/06
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttParamTexteCrg
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cVille           as character initial ?
    field cObjet           as character initial ?
    field cTitreSignataire as character initial ?
    field cNomSignataire   as character initial ?
    field cCourrier        as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
