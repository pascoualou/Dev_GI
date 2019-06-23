/*------------------------------------------------------------------------
File        : ordreDeService.i
Purpose     : 
Author(s)   : KANTENA - 2016/08/10
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttOrdreDeService 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo
    field iNumeroOrdreDeService    as int64      // serialize-name "numeroOrdService"
    field cLibelleOrdreDeService   as character  // serialize-name "libelleOrdService"
    field cCodeTraitement          as character  // signalement, demande de devis, reponse four....
    field iNumeroMandat            as int64
    field iNumeroIntervention      as int64
    field cLibelleIntervention     as character
    field cTypeMandat              as character
    field cLibelleMandat           as character
    field iNumeroImmeuble          as integer
    field cLibelleImmeuble         as character 
    field cCodeFournisseur         as character
    field cLibelleFournisseur      as character
    field cCodeTheme               as character
    field cCodeRoleSignalant       as character
    field cLibelleRolesignalant    as character
    field iNumeroSignalant         as int64
    field cLibelleSignalant        as character 
    field cAdresseSignalant        as character
    field cCodeMode                as character
    field cCodeFacturableA         as character 
    field iNumeroTiersFacturableA  as integer
    field cLibelleTiersFacturableA as character
    field iNumeroGestionnaire      as integer
    field cLibelleGestionnaire     as character
    field cCodeDelai               as character
    field cCommentaireIntervention as character
    field lCloture                 as logical
    field lBonAPayer               as logical   initial ? label 'FgBap'
    field cSysUser                 as character
    field daSysDateCreate          as date

    field dtTimestampOrdre as datetime
    field rRowid           as rowid
    field CRUD             as character
.
