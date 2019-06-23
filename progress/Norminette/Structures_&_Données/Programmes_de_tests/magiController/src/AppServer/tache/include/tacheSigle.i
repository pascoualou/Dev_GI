/*------------------------------------------------------------------------
File        : tacheSigle.i
Purpose     : Définition dataset pour tache Sigle (Cabinet/Mandant/Mandat/Service)
Author(s)   : OFA  -  2017/10/05
Notes       : 
derneire revue: 2018/05/16 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheSigle
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroTache      as int64     initial ?
    field cTypeContrat      as character initial ?
    field iNumeroContrat    as int64     initial ?
    field cTypeTache        as character initial ?
    field iChronoTache      as integer   initial ?
    field cCodeTypeSigle    as character initial ?   // HwCmbSig
    field cLibelleTypeSigle as character initial ?
    field cCodeTypeRole     as character initial ?
    field iNumeroRole       as integer   initial ?
    field cLigneSigle       as character initial ? extent 9 //HwDtaSi1 à HwDtaSi9
    field cCodePied2Page    as character initial ?
    field cLibellePied2Page as character initial ?
    field cCodeEntete       as character initial ?
    field cLibelleEntete    as character initial ?
    field cCodeLogo         as character initial ?
    field cLibelleLogo      as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
&if defined(nomTable2)   = 0 &then &scoped-define nomTable2 ttSigle
&endif
&if defined(serialName2) = 0 &then &scoped-define serialName2 {&nomTable2}
&endif
define temp-table {&nomTable2} no-undo serialize-name '{&serialName2}'
    field cCodeTypeSigle    as character initial ?
    field cLibelleTypeSigle as character initial ?
    field cCodeTypeRole     as character initial ?
    field iNumeroRole       as integer   initial ?
    field cLigneSigle       as character initial ? extent 9

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
