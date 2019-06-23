/*------------------------------------------------------------------------
File        : objetMandat.i
Purpose     : gestion des informations complementaires descriptif general (specifique allianz)
Author(s)   : GGA - 2017/10/23
Notes       : 
derniere revue: 2018/05/17 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttObjetMandatDescriptifGeneral 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cEtatConstrucRestruc        as character initial ? 
    field cLibelleEtatConstrucRestruc as character initial ? 
    field lEnConstrucRestruc          as logical   initial ? 
    field cClassification             as character initial ? 
    field cLibelleClassification      as character initial ? 
    field cNature                     as character initial ? 
    field cLibelleNature              as character initial ? 
    field cUsagePrincipal             as character initial ? 
    field cLibelleUsagePrincipal      as character initial ? 
    field cUsageSecondaire            as character initial ? 
    field cLibelleUsageSecondaire     as character initial ? 
    field cStatut                     as character initial ? 
    field cLibelleStatut              as character initial ? 
    field daEffetStatut               as date
    field cTypeGerance                as character initial ?
    field cLibelleTypeGerance         as character initial ?
.
