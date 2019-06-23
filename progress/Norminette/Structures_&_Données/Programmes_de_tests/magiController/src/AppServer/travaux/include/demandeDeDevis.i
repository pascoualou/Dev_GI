/*------------------------------------------------------------------------
File        : demandeDeDevis.i
Description :
Author(s)   : kantena - 2016/08/02
Notes       :
derniere revue: 2018/05/24 - phm: OK
----------------------------------------------------------------------*/
define temp-table ttDemandeDeDevis no-undo serialize-name 'ttDemandeDeDevis'
	field iNumeroDemandeDeDevis    as integer
	field cCodeTraitement          as character   // signalement, demande de devis, reponse four....
	field iNumeroMandat            as int64
	field cTypeMandat              as character
	field cLibelleMandat           as character
	field iNumeroImmeuble          as integer
	field cLibelleImmeuble         as character
	field cCodeFournisseur         as character
	field cLibelleFournisseur      as character
	field cCodeTheme               as character
	field cLibelleIntervention     as character 
	field cCodeArticle             as character   // intervention
	field cLibelleArticle          as character
	field cCommentaireIntervention as character
	field cCodeFacturableA         as character
	field iNumeroTiersFacturableA  as integer
	field cLibelleTiersFacturableA as character
	field iNumeroGestionnaire      as integer
	field cLibelleGestionnaire     as character
	field cCodeCle                 as character
	field iNumeroSignalant         as integer
	field cLibelleSignalant        as character
	field cCodeRoleSignalant       as character
	field cLibelleRoleSignalant    as character
	field cCodeMode                as character
	field iNumeroIntervention      as integer
	field cCodeStatut              as character
	field cCodeDelai               as character
	field lCloture                 as logical
	field cSysUser                 as character
	field daSysDateCreate          as date

    field dtTimestampDevis as datetime
    field dtTimestampInter as datetime
    field dtTimestampDtdev as datetime
    field rRowid           as rowid    
    field CRUD             as character
.
/*Ajouté pour la creation de lien lot dans le cas de duplication de devis sur  plusieurs fournisseur*/
define temp-table ttDemandeDeDevis2 no-undo
    field cCodeTraitement       as character
    field iNumeroDemandeDeDevis as int64
 .
