/*------------------------------------------------------------------------
File        : intervention.i
Description : dataset intervention
Author(s)   : kantena - 2016/05/13
Notes       :
derniere revue: 2018/05/24 - phm: OK
----------------------------------------------------------------------*/
define temp-table ttIntervention no-undo
    field iNumeroIntervention  as int64
    field cCodeTraitement      as character   // signalement, demande de devis, reponse four....
    field iNumeroTraitement    as integer /*NoTrt*/
    field lSelected            as logical
    field iNumeroImmeuble      as integer
    field cLibelleImmeuble     as character    
    field iNumeroMandat        as int64
    field cTypeMandat          as character
    field cLibelleTraitement   as character /*LbInt*/
    field daDateCreation       as date      /*DtCsy*/
    field cLibelleIntervention as character
    field daDateRealisation    as date      /*DtRea*/
    field cCodeStatut          as character
    field cLibelleStatut       as character /*LbSta*/
    field cCodeFournisseur     as character
    field cLibelleFournisseur  as character /*NmFou*/
    field lFacture             as logical   /*FgFac*/
    field lBAP                 as logical   /*FgBap*/
    field lPJ                  as logical
    field iNumeroServGestion   as integer
    field cLibelleServGestion  as character
    field cAdresseImmeuble     as character
    field iNumeroDosTravaux    as integer
    field cLibelleDosTravaux   as character
    field dMontantfactureTTC   as decimal
    field dMontantfactureHT    as decimal
    field dMontantRegle        as decimal
    field dMontantTotalTTC     as decimal
    field cCodeCloture         as character
    field cLibelleCloture      as character
    field cUserModification    as character

    field dtTimestampInter as datetime
    field CRUD             as character
    index idxIntervention is unique primary iNumeroIntervention cCodeTraitement iNumeroTraitement
.
define temp-table ttHistoriqueIntervention no-undo serialize-name "ttIntervention"
    field iNumeroIntervention  as integer
    field cCodeTraitement      as character // signalement, demande de devis, reponse four....
    field iNumeroTraitement    as integer   /* NoTrt */
    field cLibelleTraitement   as character  
    field iDureeTraitement     as integer   /* DuTrt */
    field iNumeroMandat        as int64
    field cTypeMandat          as character
    field cCodeArticle         as character /* cdart */
    field cCodeStatut          as character
    field cLibelleStatut       as character /* LbSta */
    field cCodeFournisseur     as character /* noFou */
    field cLibelleFournisseur  as character /* NmFou */
    field cLibelleIntervention as character
    field daDateCreation       as date
    field cUserModification    as character 
    field cCommentaire         as character

    field CRUD as character
.
define temp-table ttListeIntervention no-undo 
    field iNumeroIntervention    as int64       //NoInt
    field cCodeTraitement        as character   // TpTrt: signalement, demande de devis, reponse four....
    field iNumeroTraitement      as integer     // NoTrt  
    field cCodeTypeTraitement    as character
    field cLibelleTypeTraitement as character
    field cLibelleIntervention   as character /*LbInt*/
    field daDateCreation         as date      /*DtCsy*/
    field cCodeStatut            as character
    field cLibelleStatus         as character /*LbSta*/     
    field iNumeroDosTravaux      as integer
    field cLibelleDosTravaux     as character
    field cCodeFournisseur       as character
    field daDatePrevu            as date
    field cLibelleFournisseur    as character
    field cLibelleSignalant      as character
    field cCodeArticle           as character
    field cCodeTypeTravaux       as character

    field dtTimestamp as datetime
    field CRUD        as character
    index idxIntervention is unique primary iNumeroIntervention cCodeTraitement iNumeroTraitement
. 
