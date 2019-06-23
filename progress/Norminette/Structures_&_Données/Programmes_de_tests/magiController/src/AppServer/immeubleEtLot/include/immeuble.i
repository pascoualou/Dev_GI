/*------------------------------------------------------------------------
File        : immeuble.i
Purpose     :
Author(s)   : KANTENA - 2016/09/07
Notes       : Attention, ne pas enlever la valeur initiale ? et le label, automatisme sur assign.
derniere revue: 2018/05/25 - phm: OK
------------------------------------------------------------------------*/
define temp-table ttImmeuble no-undo
    field iNumeroImmeuble            as integer   initial ? label 'NoImm'
    field iNumeroContratConstruction as int64     initial ?
    field cLibelleImmeuble           as character initial ? label 'LbNom'
    field cCodeTypeImmeuble          as character initial ? label 'TpImm'
    field cLibelleTypeImmeuble       as character initial ?
    field cCodeTypePropriete         as character initial ? label 'TpPropriete'
    field cLibelleTypePropriete      as character initial ?
    field cCodeSecteur               as character initial ? label 'CdSec'
    field cLibelleSecteur            as character initial ?
    field cCodeLocalisation          as character initial ? label 'CdLocalisation'
    field cLibelleLocalisation       as character initial ?
    field cCodeNatureBien            as character initial ? label 'NtBie'
    field cLibelleNatureBien         as character initial ?
    field cCodeCategorieImmeuble     as character initial ?
    field cLibelleCategorieImmeuble  as character initial ?
    field cNumeroPermisConstruire    as character initial ? label 'permis'
    field daDateConstruction         as date
    field daDateFinContrat           as date
    field daDateRenovation           as date                label 'dtRenov'
    field cCodeQualite               as character initial ? label 'CdQualite'
    field cLibelleQualite            as character initial ?
    field cNumeroCadastre            as character initial ? label 'cdCad'
    field cNumeroPlan                as character initial ? label 'cdpln'
    field iNumeroPromoteur           as integer   initial ?
    field cNomPromoteur              as character initial ?
    field iNumeroArchitecte          as integer   initial ?
    field cNomArchitecte             as character initial ?
    field iNombreBatiment            as integer   initial ? label 'nbbat'
    field iNombreAscenseur           as integer   initial ? label 'nbasc'
    field iNombreEscalier            as integer   initial ? label 'nbEsc'
    field iNombreEtage               as integer   initial ? label 'nbEta'
    field iNombreLoge                as integer   initial ? label 'nbLog'
    field iNombreSousSol             as integer   initial ? label 'nbSss'
    field lParkingSousSol            as logical   initial ? label 'lParkingSousSol/lbdiv'
    field cCodeTypeConstruction      as character initial ? label 'TpCst'
    field cLibelleTypeConstruction   as character initial ?
    field cCodeTypeToiture           as character initial ? label 'TpTot'
    field cLibelleTypeToiture        as character initial ?
    field lVentilationMecanique      as logical   initial ? label 'FgVen'
    field cCodeTypeChauffage         as character initial ? label 'TpCha'
    field cLibelleTypeChauffage      as character initial ?
    field cCodeModeChauffage         as character initial ? label 'MdCha'
    field cLibelleModeChauffage      as character initial ?
    field cDebutPeriodeChauffe       as character initial ?
    field cFinPeriodeChauffe         as character initial ?
    field cCodeModeClimatisation     as character initial ? label 'MdCli'
    field cLibelleModeClimatisation  as character initial ?
    field lTeleReleve                as logical   initial ?
    field cCodeModeEauChaude         as character initial ? label 'MdChd'
    field cLibelleModeEauChaude      as character initial ?
    field cCodeModeEauFroide         as character initial ? label 'MdFra'
    field cLibelleModeEauFroide      as character initial ?
    field cCodeTypeSyndicat          as character initial ?
    field cLibelleTypeSyndicat       as character initial ?
    field lSyndicatProfessionnel     as logical   initial ?
    field lSRU                       as logical   initial ?
    field cCodeExterneManPower       as character initial ? label 'CdExt'
    field lCopropriete               as logical   initial ?
    field lGerance                   as logical   initial ?
    field cCodeSousSecteur           as character initial ? label 'cdsse'
    field cLibelleSousSecteur        as character initial ?
    field iNombreLot                 as integer   initial ?
    field iNumeroBlocNote            as integer   initial ? label 'noblc'
    field lbdiv                      as character initial ? label 'lbdiv'
    field iNumeroRoleSyndic          as integer   initial ?               /* N° Syndic Externe            */
    field cCodeTypeRoleSyndic        as character initial ?               /* Type Syndic Externe          */
    field cLibelleTypeRoleSyndic     as character initial ?
    field cContact                   as character initial ?
    field cTypeBien                  as character initial ?
    /* THK : Les champs surfaces et roles sont volontairement définis avec leur nom d'origine. 
             Il ne sont pas utilisés par le client (Angular) mais uniquement côté progress pour la mise à jour. */
    field tprol                      as character initial ? label "tprol"
    field norol                      as integer   initial ? label "norol"
    field sfHab                      as decimal   initial ? label "sfHab"
    field AfHab                      as integer   initial ? label "AfHab"
    field UsHab                      as character initial ? label "UsHab"
    field sfDev                      as decimal   initial ? label "sfDev"
    field AfDev                      as integer   initial ? label "AfDev"
    field UsDev                      as character initial ? label "UsDev"
    field sfter                      as decimal   initial ? label "sfter"
    field AfTer                      as integer   initial ? label "AfTer"
    field UsTer                      as character initial ? label "UsTer"
    field sfVet                      as decimal   initial ? label "sfVet"
    field AfVet                      as integer   initial ? label "AfVet"
    field UsVet                      as character initial ? label "UsVet"

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
define temp-table ttListeImmeuble no-undo
    field iNumeroImmeuble  as integer
    field cLibelleImmeuble as character
    field cAdresse         as character
    field cCodePostal      as character
    field cVille           as character

    field dtTimestampImble as datetime
    field dtTimestampAdres as datetime
    field CRUD             as character
index primaire iNumeroImmeuble.
