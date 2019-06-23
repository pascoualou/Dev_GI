/*------------------------------------------------------------------------
File        : lot.i
Purpose     :
Author(s)   : KANTENA - 2016/09/07
Notes       :
derniere revue: 2018/05/25 - phm: OK
------------------------------------------------------------------------*/
define temp-table ttLot no-undo
    field iNumeroImmeuble              as integer   initial ? label 'noimm'
    field cNomImmeuble                 as character initial ?                              /* limbl                */
    field iNumeroLot                   as integer   initial ? label 'nolot'
    field iNumeroBien                  as integer   initial ? label 'noloc'
    field iNumeroUL                    as integer   initial ?          
    field cCodeNature                  as character initial ? label 'ntlot'
    field cLibelleNature               as character initial ?                              /* lbnat                */
    field cDesignation                 as character initial ? label 'lbgrp'
    field cCodeBatiment                as character initial ? label 'cdbat'
    field cCodeEntree                  as character initial ? label 'lbdiv'
    field cCodeEscalier                as character initial ? label 'cdesc'
    field cCodeEtage                   as character initial ? label 'cdeta'
    field cCodePorte                   as character initial ? label 'cdpte'
    field cNomOccupant                 as character initial ?                              /* NmOcc                */
    field daDateAchat                  as date
    field lIsPrincipal                 as logical   initial ?                              /* Lot principal        */
    field cEtiquetteClimat             as character initial ? label 'etqclimat'
    field iValeurEtiquetteClimat       as integer   initial ? label 'valetqclimat'         /* npo #7589 */
    field cEtiquetteEnergie            as character initial ? label 'etqEnergie'
    field iValeurEtiquetteEnergie      as integer   initial ? label 'valetqenergie'        /* npo #7589 */
    field cCodeModeChauffage           as character initial ? label 'mdcha'
    field cLibelleModeChauffage        as character initial ?                              /* table sys_pr MDCHA   */
    field cCodeTypeChauffage           as character initial ? label 'tpcha'
    field cLibelleTypeChauffage        as character initial ?                              /* table sys_pr TPCHA   */
    field iNombreDependance            as integer   initial ? label 'nbdep'
    field iNombreNiveaux               as integer   initial ? label 'nbniv'
    field iNombrePiece                 as integer   initial ? label 'nbprf'
    field iNombreChambreService        as integer   initial ? label 'nbser'
    field cCodeTerrasse                as character initial ? label 'cdtlb'
    field cUsage                       as character initial ?                              /* cdusage AGF          */
    field lHasAirConditionne           as logical   initial ? label 'fgair'
    field lIsMeuble                    as logical   initial ? label 'fgmbl'
    field lHasWCIndependant            as logical   initial ? label 'fgwci'
    field iNumeroBail                  as int64     initial ?
    field cEUTypeGestion               as character initial ? label 'euGes'
    field cEUTypeContrat               as character initial ? label 'euCtt'
    field iNumeroLienAdresseImmeuble   as character initial ?                              /* noladrim             */
    field iNumeroLienAdresseLot        as character initial ?                              /* noladrlo             */
    field daDateAchevement             as date                label 'dtach'
    field daDateFinApplication         as date                label 'dtflo'
    field daDateDebutValidite          as date                label 'dtdeb-validite' 
    field daDateFinValidite            as date                label 'dtfin-validite' 
    field lIsDivisible                 as logical   initial ? label 'fgdiv' 
    field lTravauxEntretien            as logical   initial ?                              /* cdTrxEntretient      */
    field CdTrxEntretien               as character initial ? label 'CdTrxEntretien'
    field daDateTravauxEntretien       as date                label 'DtTrxEntretien'
    field lTravauxMiseAuxNormes        as logical   initial ?                              /* cdTrxMiseAuxNormes   */
    field CdTrxMiseAuxNormes           as character initial ? label 'CdTrxMiseAuxNormes'
    field daDateTravauxMiseAuxNormes   as date                label 'DtTrxMiseAuxNormes'
    field lTravauxRestructuration      as logical   initial ?                              /* cdTrxRestructuration */
    field CdTrxRestructuration         as character initial ? label 'CdTrxRestructuration'
    field daDateTravauxRestructuration as date                label 'DtTrxRestructuration'
    field iNumeroProprietaire          as integer   initial ?                              /* nocop                */
    field cNomProprietaire             as character initial ?                              /* nmcop                */
    field cCodeTypeProprietaire        as character initial ?                              /* lbocc                */
    field cCodeLotCopropriete          as character initial ? label 'cdlot-cop'
    field cLibelleTypeProprietaire     as character initial ?
    field cListeLotVente               as character initial ? label 'lbdiv2'               /* nslotv               */
    field daDateMiseEnVente            as date                label 'dtmvt'
    field dMontantMiseEnVente          as decimal   initial ? label 'mtmvt'
    field cCodeTypeAcquisition         as character initial ?                              /* tpacq                */
    field iNumeroNotaire               as integer   initial ? label 'nonot'
    field cNomNotaire                  as character initial ?                              /* frmtie1              */
    field cAdresseNotaire              as character initial ?                              /* frmadr4              */
    field cLieuActeNotarie             as character initial ?                              /* lisig                */
    field daDateVente                  as date                                             /* dtVente              */
    field daDateEntreeOccupant         as date                                             /* dtEnt                */
    field iPhotoLotEnCours             as integer   initial ?                              /* nopho                */
    field iNumeroBlocNote              as integer   initial ? label 'noblc'
    field cTypeOccupant                as character initial ? label 'lbdiv3'
    field cCodeExterneManpower         as character initial ?                              /* cdext                */
    field cCodeUsage                   as character initial ? label 'cdUsage'
    field cLibelleUsage                as character initial ?
    field cCodeOrientation             as character initial ? label 'orien'
    field cLibelleOrientation          as character initial ?
    field dLoyerMandat                 as decimal   initial ?                /* montantFamille[1] */
    field iNumeroRubanNoteEnCoours     as integer   initial ?         
    field dProvisionChargeMandat       as decimal   initial ?                /* montantFamille[2] */
    field montantFamille               as decimal   extent 2 initial ? label 'montantFamille'
    field lSelected                    as logical   initial ?          /* fgsel  */
    field laffsel                      as logical   initial ?          /* affsel */
    field cTypeBien                    as character initial ?
    field cCodeTypeLot                 as character initial ? label 'tplot'
    field cLibelleTypeLot              as character initial ?
    /* THK : Les champs surfaces sont volontairement définis avec leur nom d'origine. 
             Il ne sont pas utilisés par le client (Angular) mais uniquement côté progress pour la mise à jour. */
    field sfRee                        as decimal   initial ?
    field usRee                        as character initial ?
    field sfNon                        as decimal   initial ?
    field usNon                        as character initial ?
    field sfArc                        as decimal   initial ?
    field usArc                        as character initial ?
    field sfAxe                        as decimal   initial ?
    field usAxe                        as character initial ?
    field sfPde                        as decimal   initial ?
    field usPde                        as character initial ?
    field sfcor                        as decimal   initial ?
    field usCor                        as character initial ?
    field sfExp                        as decimal   initial ?
    field usExp                        as character initial ?
    field sfTer                        as decimal   initial ?
    field usTer                        as character initial ?
    field sfBur                        as decimal   initial ?
    field usBur                        as character initial ?
    field sfPkg                        as decimal   initial ?
    field usPkg                        as character initial ?
    field sfCom                        as decimal   initial ?
    field usCom                        as character initial ?
    field sfStk                        as decimal   initial ?
    field usStk                        as character initial ?
    field sfPlancher                   as decimal   initial ?
    field usPlancher                   as character initial ?
    field sfEmprisesol                 as decimal   initial ?
    field usEmprisesol                 as character initial ?
    field sfscu                        as decimal   initial ?
    field usscu                        as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
define temp-table ttListeLot no-undo serialize-name "ttLot"
    field iNumeroTraitement        as integer   /* numeroSignalement, numeroDemandeDevis, numeroOrdreService */
    field iNumeroImmeuble          as integer   /* noimm */
    field cNomImmeuble             as character /* limbl  */
    field iNumeroLot               as integer   /* nolot */
    field iNumeroBien              as integer   /* noloc */
    field iNumeroUL                as integer   /* noapp */
    field iNumeroBail              as int64
    field cCodeNature              as character /* ntlot */
    field cLibelleNature           as character /* lbnat */
    field cDesignation             as character /* LbLot */
    field cCodeBatiment            as character /* cdbat */
    field cCodeEntree              as character /* CdEnt */
    field cCodeEscalier            as character /* cdesc */
    field cCodeRegroupement        as character /* cdreg */
    field cCodeEtage               as character /* CdEta */
    field cCodePorte               as character /* cdpte */
    field cTypeOccupant            as character /* tpOcc */
    field cNomOccupant             as character /* NmOcc */
    field dSurfaceReelle           as decimal   /* sfree */
    field cCodeOrientation         as character
    field iNombrePiece             as integer
    field daDateEntree             as date
    field iNumeroProprietaire      as integer
    field cNomProprietaire         as character
    field cCodeTypeProprietaire    as character
    field cLibelleTypeProprietaire as character
    field lIsPrincipal             as logical   /* Lot principal */
    field daDateAchat              as date      /* DtAch  */ 
    field lSelected                as logical   /* fgsel  */
    field laffsel                  as logical   /* affsel */

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
define temp-table ttContratLot no-undo
    field cTypeContrat         as character initial ?
    field cNatureContrat       as character initial ?
    field iNumeroContrat       as integer   initial ?
    field iNumeroImmeuble      as integer   initial ?
    field iNumeroLot           as integer   initial ?
    field cLibelleContrat      as character initial ?
    field daDateDebut          as date
    field daDateFin            as date
    field daDateResiliation    as date
    field cDivers              as character initial ?
    field lPresent             as logical   initial ?
    field lProvisoire          as logical   initial ?
    field cInfoComplementaire  as character initial ?
    field lHasPJ               as logical   initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    index idxContrat is unique cTypeContrat iNumeroContrat iNumeroImmeuble
.
