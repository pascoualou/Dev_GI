/*------------------------------------------------------------------------
File        : dossierTravaux.i
Purpose     : 
Author(s)   : kantena  -  2016/10/19
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
define temp-table ttDossierTravaux no-undo
    field iNumeroDossierTravaux  as integer   initial ? label 'nodos'
    field cLibelleDossierTravaux as character initial ? label 'lbdos'
    field cCodeTypeMandat        as character initial ? label 'tpcon'
    field iNumeroMandat          as integer   initial ? label 'nocon'
    field cLibelleMandat         as character
    field iNumeroImmeuble        as character initial ? label 'intnt.noidt'
    field cLibelleImmeuble       as character
    field daDateVote             as date                label 'dtsig'
    field daDateDebut            as date                label 'dtdeb'
    field daDateDebutChantier    as date                label 'dtdebCha'
    field daDateFin              as date                label 'dtfin'
    field lUrgent                as logical   initial ? label 'tpurg'
    field cVille                 as character initial ? label 'adres.lbvil'
    field iDuree                 as integer   initial ? label 'nbdur'
    field iNombreEcheance        as integer   initial ? label 'nbech'
    field iCodeBaremeHonoraire   as integer   initial ? label 'nohon'
    field cCodeDuree             as character initial ? label 'cddur'
    field cLibelleDuree          as character
    field cLibelleStatut         as character
    field cCodePresentation      as character initial ? label 'cdpre'
    field lAppelDeFond           as logical   initial ? label 'cdnat'
    field dRetenueGarantie       as decimal   initial ? label 'txdgr'
    field cCodeBatiment          as character initial ? label 'lbdiv1'
    field cLibelleBatiment       as character
    field lAApprouverEnAg        as logical   initial ? label 'nocon-dec'
    field cTypePrevisionnel      as character initial ? label 'tpPrevis'
    field dMontantPrevisionnel   as decimal   initial ? label 'mtPrevis'
    field daDateCloture          as date                label 'dtRee'
    field cUtilisateurCloture    as character initial ? label 'cdcsy'
    field lMandatResilie         as logical
    field daDateApprobationAG    as date                label 'nocon-dec'
    field cCdNat                 as character
    field iLoRep                 as integer  
    field cTpArr                 as character
    field cCdArr                 as character

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid 
.  
define temp-table ttListeDossierTravaux no-undo
    field iNumeroDossierTravaux as integer   initial ? label 'nodos'
    field iNumeroImmeuble       as integer   initial ? label 'intnt.noidt'
    field iNumeroMandat         as integer   initial ? label 'nocon'
    field cCodeTypeMandat       as character initial ? label 'tpcon'
    field cLibelleDossier       as character initial ? label 'lbdos'
    field lVote                 as logical   initial ? label 'dtsig'
    field daDateVote            as date                label 'dtsig'
    field daDateCreation        as date                label 'dtcsy'
    field daDateDebut           as date                label 'dtdeb'
    field daDateFin             as date                label 'dtfin'
    field daDateCloture         as date                label 'dtRee'
    field lUrgent               as logical   initial ? label 'tpurg'
    field cCodeStatut           as character
    field cLibelleStatut        as character

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
define temp-table ttRecapDossierTravaux no-undo
    field iNumeroDossierTravaux       as integer     
    field iNumeroImmeuble             as integer     
    field iNumeroMandat               as integer     
    field dRepDev                     as decimal    
    field dOrdServ                    as decimal
    field dfac                        as decimal 
    field dTotHon                     as decimal
    field dHonAuto                    as decimal
    field dHonAutoResteAComptabiliser as decimal
    field dHonAutoFacturer            as decimal
    field dHonAutoResteAFacturer      as decimal
    field dHonManu                    as decimal
    field dHonManuFacturer            as decimal
    field dDepReg                     as decimal     
    field dAppApp                     as decimal
    field dAppFTA                     as decimal
    field dAppEnc                     as decimal
    field dSldDos                     as decimal
    field dSldTre                     as decimal

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
