/*------------------------------------------------------------------------
File        : surface.i
Description : temp table surface 
Author(s)   : kantena - 2017/01/18
Notes       :
derniere revue: 2018/05/25 - phm: OK
----------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttSurface
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeBien           as character initial ?
    field iNumeroBien         as integer   initial ?
    field cCodeTypeSurface    as character initial ?
    field cLibelleTypeSurface as character initial ?
    field dValeur             as decimal   initial ?
    field dSurface1           as decimal   initial ?
    field dSurface2           as decimal   initial ?
    field cCodeUnite          as character initial ?
    field cLibelleUnite       as character initial ?
    field iZone               as integer   initial ?
    field cNoInstance         as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
index primaire cTypeBien iNumeroBien
.
