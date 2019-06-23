/*-----------------------------------------------------------------------------
File        : roleVersement.i
Description : 
Author(s)   :   - 2017/05/15 
Notes       :
derniere revue: 2018/05/24 - phm: OK
-----------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRoleVersement
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomtable} no-undo serialize-name '{&serialName}'
    field id-fich          as int64
    field iNumeroTiers     as int64     initial ?
    field cTypeRole        as character initial ?
    field iNumeroRole      as int64     initial ?
    field cNumeroRole      as character initial ?
    field cTypeContrat     as character initial ?
    field iNumeroContrat   as int64     initial ?
    field cLibelleTypeRole as character initial ?
    field cLibelleContrat  as character initial ?
    field cAdresseContrat  as character initial ?
    field cLibelleTiers    as character initial ?
    field cAdresseTiers    as character initial ?
    field iNumeroMandat    as integer   initial ?
    field lCabinet         as logical   initial ?

    field rRowid as rowid
    index primaire rRowid cTypeContrat iNumeroContrat   // attention, pas unique !!!
.
