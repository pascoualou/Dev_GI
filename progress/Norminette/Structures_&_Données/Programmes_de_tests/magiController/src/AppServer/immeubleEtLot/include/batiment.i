/*------------------------------------------------------------------------
File        : batiment.i
Description : 
Author(s)   : KANTENA - 2016/09/07
Notes       :
derniere revue: 2018/05/25 - phm: OK
------------------------------------------------------------------------*/
define temp-table ttBatiment no-undo
    field iNumeroBatiment           as integer   initial ? label 'NoBat'
    field iNumeroImmeuble           as integer   initial ? label 'noimm'
    field iNumeroLienAdresse        as integer   initial ?                  // ladrs.nolie
    field cCodeBatiment             as character initial ? label 'CdBat'
    field cLibelleBatiment          as character initial ? label 'LbBat'
    field cLibelleAdresse           as character initial ?
    field iNombreEtage              as integer   initial ? label 'nbeta'
    field iNombreLoge               as integer   initial ? label 'nblog'
    field iNombreSousSol            as integer   initial ? label 'nbsss'
    field iNombreEscalier           as integer   initial ? label 'nbesc'
    field lParkingSousSol           as logical   initial ? label 'nbpss'
    field cCodeTypeConstruction     as character initial ? label 'TpCst'
    field cLibelleTypeConstruction  as character initial ?
    field cCodeTypeToiture          as character initial ? label 'TpTot'
    field cLibelleTypeToiture       as character initial ?
    field lVentilationMecanique     as logical   initial ? label 'FgVen'
    field cCodeTypeChauffage        as character initial ? label 'TpCha'
    field cLibelleTypeChauffage     as character initial ?
    field cCodeModeChauffage        as character initial ? label 'MdCha'
    field cLibelleModeChauffage     as character initial ?
    field cCodeModeClimatisation    as character initial ? label 'MdCli'
    field cLibelleModeClimatisation as character initial ?
    field cCodeModeEauChaude        as character initial ? label 'MdChd'
    field cLibelleModeEauChaude     as character initial ?
    field cCodeModeEauFroide        as character initial ? label 'MdFra'
    field cLibelleModeEauFroide     as character initial ?
    field lTeleReleve               as logical   initial ? label 'FgRel'
    field cDebutPeriodeChauffe      as character initial ? label 'dtdch'
    field cFinPeriodeChauffe        as character initial ? label 'dtfch'
    field cTypeBien                 as character initial ?
    /* THK : Les champs surfaces sont volontairement définis avec leur nom d'origine. 
             Il ne sont pas utilisés par le client (Angular) mais uniquement côté progress pour la mise à jour. */ 
    field sfHab                     as decimal   initial ? label "sfHab"
    field AfHab                     as integer   initial ? label "AfHab"
    field UsHab                     as character initial ? label "UsHab"
    field sfDev                     as decimal   initial ? label "sfDev"
    field AfDev                     as integer   initial ? label "AfDev"
    field UsDev                     as character initial ? label "UsDev"
    field sfter                     as decimal   initial ? label "sfter"
    field AfTer                     as integer   initial ? label "AfTer"
    field UsTer                     as character initial ? label "UsTer"
    field sfVet                     as decimal   initial ? label "sfVet"
    field AfVet                     as integer   initial ? label "AfVet"
    field UsVet                     as character initial ? label "UsVet"

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
index idxBatiment is unique primary iNumeroImmeuble cCodeBatiment
.