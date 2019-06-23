/*-----------------------------------------------------------------------------
File        : reponseFournisseur.i
Purpose     :
Author(s)   : KANTENA - 2016/08/11
Notes       : Pas d'index dans les temp-table, cela pose des problèmes si update dans un for each !!!
derniere revue: 2018/05/24 - phm: OK
-----------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttReponseFournisseur 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroIntervention        as integer
    field iNumeroDemandeDeDevis      as integer
    field cCodeTraitement            as character   // signalement, demande de devis, reponse four....
    field cReferenceDevisFournisseur as character 
    field iNumeroMandat              as int64
    field iNumeroDossier             as integer
    field cTypeMandat                as character
    field cLibelleMandat             as character
    field iNumeroImmeuble            as integer
    field cLibelleImmeuble           as character
    field cCodeFournisseur           as character
    field iCodeSociete               as integer
    field cLibelleFournisseur        as character
    field cCodeRoleSignalant         as character
    field iNumeroSignalant           as int64
    field cLibelleSignalant          as character
    field cAdresseSignalant          as character
    field cCodeMode                  as character
    field cCodeTheme                 as character
    field cCodeFacturableA           as character
    field iNumeroTiersFacturableA    as integer
    field cRoleFacturable            as character
    field cTypeVote                  as character
    field cCommentaire               as character
    field iNumeroGestionnaire        as integer
    field cCodeDelai                 as character
    field cCodeStatut                as character
    field lCloture                   as logical
    field daSysDateCreate            as date
    field cSysUser                   as character

    field dtTimestampDevis as datetime
    field CRUD             as character
    field rRowid           as rowid
.
