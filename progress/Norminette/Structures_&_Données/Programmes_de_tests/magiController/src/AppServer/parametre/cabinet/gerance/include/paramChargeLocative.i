/*------------------------------------------------------------------------
File        : paramChargeLocative.i
Purpose     : 
Author(s)   : GGA  -  2017/10/27
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttParamChargeLocative
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeTache               as character initial ?
    field lParametrageActif        as logical   initial ?
    field lActivation              as logical   initial ?
    field cCodePresentation        as character initial ?
    field cLibellePresentation     as character initial ?
    field cCodeRepartition         as character initial ?
    field cLibelleRepartition      as character initial ?
    field lIntegrationDirectCompta as logical   initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
