/*------------------------------------------------------------------------
File        : paramIrf.i
Purpose     : 
Author(s)   : GGA  -  2017/10/27
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttParamIrf
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeTache                     as character initial ?
    field lParametrageActif              as logical   initial ?
    field lActivation                    as logical   initial ?
    field lAutomatique                   as logical   initial ?
    field cCodeDeclaration               as character initial ?
    field cLibelleDeclaration            as character initial ?
    field lDeclaration2072               as logical   initial ?
    field lMicroFoncier                  as logical   initial ?
    field lCalculTvaProratee             as logical   initial ?
    field lCalculAutoProrataMandant      as logical   initial ?
    field cCodeHonoraire                 as character initial ?
    field dDeductForfaitaireFraisGestion as decimal   initial ?
    field dTauxDeductionMicrofoncier     as decimal   initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
