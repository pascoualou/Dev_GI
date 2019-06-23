/*-----------------------------------------------------------------------------
File        : paramTypeArrondiLoyerRevision.i
Description : 
Author(s)   : npo - 2017/11/28
Notes       :
derniere revue: 2018/05/24 - phm: OK
-----------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttParamTypeArrondiLoyerRevision
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeTache                   as character initial ?
    field lParametrageActif            as logical   initial ?
    field lActivation                  as logical   initial ?
    field lAutomatique                 as logical   initial ?
    field cCodeTypeArrondiLoyer        as character initial ?
    field cLibelleTypeArrondiLoyer     as character initial ?
    field cCodeDigitArrondiLoyer       as character initial ?
    field cLibelleDigitArrondiLoyer    as character initial ?
    field cCodeTypeArrondiRevision     as character initial ?
    field cLibelleTypeArrondiRevision  as character initial ?
    field cCodeDigitArrondiRevision    as character initial ?
    field cLibelleDigitArrondiRevision as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
