/*------------------------------------------------------------------------
File        : tacheChargeLocative.i
Purpose     : 
Author(s)   : GGA  -  2017/12/18
Notes       : sur la table ttCleChargeLocative les zones CRUD, dtTimestamp et rRowid ne sont pas necessaires 
derniere revue: 2018/05/18 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheChargeLocative
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroTache             as int64
    field cTypeContrat             as character
    field iNumeroContrat           as int64
    field cTypeTache               as character
    field iChronoTache             as integer
    field cPresentationAu          as character           //HwCmbEdt
    field cLibellePresentationAu   as character initial ?
    field cPresentationType        as character           //HwCmbCum
    field cLibellePresentationType as character initial ?
    field cCleDefaut               as character           //HwCmbClp
    field cLibelleCleDefaut        as character
    field lIntegrationDirectCompta as logical             //HwTglReg 
    field cEtatDepense             as character           //HwCmbTVA
    field cLibelleEtatDepense      as character initial ?
    field cRepartition             as character           //HwCmbLot
    field cLibelleRepartition      as character initial ?
    field cInfoRepartition         as character initial ? //HwEdiInf
    field lReleveEauFroide         as logical             //HwTglFro
    field lReleveEauChaude         as logical             //HwTglCha
    field lReleveCalorifique       as logical             //HwTglCal
    field dPourcentageAugmentation as decimal
    field lReajustementProvision   as logical
    field lLissage                 as logical

    field dtTimestamp as datetime 
    field CRUD        as character 
    field rRowid      as rowid
.
&if defined(nomTableCle)   = 0 &then &scoped-define nomTableCle ttCleChargeLocative
&endif
&if defined(serialNameCle) = 0 &then &scoped-define serialNameCle {&nomTableCle}
&endif
define temp-table {&nomTableCle} no-undo serialize-name '{&serialNameCle}'
    field cCle          as character
    field cLibelleCle   as character
    field dBaseMandat   as decimal
    field dBaseImmeuble as decimal
index idxcCle cCle
.
&if defined(nomTableRubrique)   = 0 &then &scoped-define nomTableRubrique ttRubriqueChargeLocative
&endif
&if defined(serialNameRubrique) = 0 &then &scoped-define serialNameRubrique {&nomTableRubrique}
&endif
define temp-table {&nomTableRubrique} no-undo serialize-name '{&serialNameRubrique}'
    field iRubrique        as integer
    field cLibelleRubrique as character
    field cCle             as character
    field cLibelleCle      as character
    field dBaseMandat      as decimal
    field dBaseImmeuble    as decimal

    field dtTimestamp as datetime 
    field CRUD        as character 
    field rRowid      as rowid
index idxcRubrique iRubrique    
.
 