/*------------------------------------------------------------------------
File        : paramHonoraireGestion.i
Purpose     : 
Author(s)   : GGA  -  2017/10/27
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttParamHonoraireGestion
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeTache            as character initial ?
    field lParametrageActif     as logical   initial ?
    field lActivation           as logical   initial ?
    field lAutomatique          as logical   initial ?
    field cCodePeriodeCalcul    as character initial ?
    field cLibellePeriodeCalcul as character initial ?
    field cCodeHonoraire        as character initial ?
    field cCodeFrais            as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
