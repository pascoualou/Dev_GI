/*------------------------------------------------------------------------
File        : signalement.i
Description : dataset signalement/lot 
Author(s)   : kantena - 2016/02/09
Notes       :
derniere revue: 2018/05/24 - phm: OK
----------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttSignalement 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroIntervention      as integer
    field iNumeroSignalement       as integer
    field cCodeTraitement          as character   // signalement, demande de devis, reponse four....
    field cTypeMandat              as character
    field iNumeroImmeuble          as integer 
    field cLibelleImmeuble         as character
    field iNumeroMandat            as int64
    field cLibelleMandat           as character
    field cCodeTheme               as character
    field cCodeRoleSignalant       as character 
    field cLibelleRoleSignalant    as character
    field iNumeroSignalant         as int64
    field cLibelleSignalant        as character
    field cAdresseSignalant        as character
    field cCodeMode                as character
    field cCommentaireIntervention as character
    field cLibelleIntervention     as character
    field lCloture                 as logical
    field daSysDateCreate          as date
    field cSysUser                 as character

    field dtTimestampSigna as datetime
    field dtTimestampInter as datetime
    field rRowidSigna      as rowid
    field rRowidInter      as rowid
    field CRUD             as character
.
