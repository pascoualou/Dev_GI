/*------------------------------------------------------------------------
File        : detailsIntervention.i
Description :
Author(s)   : kantena - 2016/08/02
Notes       :
derniere revue: 2018/05/24 - phm: OK
----------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttDetailsIntervention 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field CRUD                     as character
    field iNumeroTraitement        as integer
    field iNumeroIntervention      as integer
    field cCodeArticle             as character
    field cLibelleIntervention     as character
    field daFinPrevue              as date
    field daDateDebut              as date
    field cCommentaireIntervention as character
    field cCodeCle                 as character
    field iNombreJours             as integer
    field dQuantite                as decimal
    field dPrixUnitaire            as decimal
    field dMontantHT               as decimal
    field dMontantTTC              as decimal
    field dTauxRemise              as decimal
    field cCodeStatut              as character
    field cLibelleStatut           as character
    field iCodeTVA                 as integer
    field dTauxTVA                 as decimal
    field dMontantTVA              as decimal
    field edit                     as logical

    field dtTimestampInter as datetime
    field dtTimestampsvdev as datetime
    field dtTimestampdtdev as datetime
    field dtTimestampdtord as datetime
    field rRowidInter      as rowid
    field rRowidSvDev      as rowid
    field rRowiddtDev      as rowid
    field rRowiddtOrd      as rowid
 .
 