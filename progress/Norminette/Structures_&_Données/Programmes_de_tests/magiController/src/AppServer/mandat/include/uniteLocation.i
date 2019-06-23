/*------------------------------------------------------------------------
File        : uniteLocation.i
Purpose     : Unite de location du mandat de gérance
Author(s)   : SPo 2017/03/09
Notes       :
derniere revue: 2018/05/17 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttUniteLocation 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cCodeTypeContrat             as character initial ?
    field iNumeroContrat               as integer   initial ? label 'nomdt'
    field iNumeroAppartement           as integer   initial ? label 'noapp'
    field iCodeActif                   as integer   initial ? label 'noact'
    field iNumeroComposition           as integer   initial ? label 'nocmp'
    field iNumeroMandant               as integer   initial ? label 'noman'
    field iNumeroImmeuble              as integer   initial ? label 'noimm'
    field iNumeroLotPrincipal          as integer   initial ? label 'nolot'
    field iIdLotPrincipal              as integer   initial ?                // local.noloc 
    field cLibelleLoiLotIRF            as character initial ?                // loi de défiscalisation du lot principal
    field cCodeNatureUL                as character initial ?                // unite.cdcmp     
    field cLibelleNatureUL             as character initial ?                // habitation,commerce,parking...
    field daDateDebutComposition       as date
    field daDateFinComposition         as date
    field cCodeMotifIndisponibilite    as character initial ?
    field cLibelleMotifIndisponibilite as character initial ?
    field daDateDebutIndisponibilite   as date
    field daDateFinIndisponibilite     as date
    field cCodeOccupation              as character initial ? label 'cdocc' 
    field cLibelleOccupation           as character initial ? label ''
    field iNumeroContratBail           as int64     initial ?                // Numero du dernier locataire (en cours ou sorti)
    field daDateEntree                 as date                               // Date d'entrée du locataire 
    field daDateSortie                 as date                               // Date de sortie du locataire 
    field cCodeUsage                   as character initial ?
    field cLibelleUsage                as character initial ?
    field iNombrePiece                 as integer   initial ?
    field dSurfaceUtileULm2            as decimal   initial ?
    field dSurfacePondereULm2          as decimal   initial ?
    field cNomMandant                  as character initial ?
    field cNomCompletMandant           as character initial ?
    field iNoWorkFlowFicheCom          as integer   initial ?
    field cLibelleWorkFlowFicheCom     as character initial ?
    field iNumeroFicheCom              as integer   initial ?                // no fiche location associée 
    field iNoModeCreation              as integer   initial ?
    field cCodePostal                  as character initial ?
    field cVille                       as character initial ?
    field cAdresse                     as character initial ?
    field cLibelleAdresse              as character initial ?
    field iNumeroLocataire             as integer   initial ?
    field cNomLocataire                as character initial ?
    field cChangementAutorise          as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
