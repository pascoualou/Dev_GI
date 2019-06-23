/*------------------------------------------------------------------------
File        : local.i
Purpose     : 
Author(s)   : GGA - 2018/01/04
Notes       :
derniere revue: 2018/08/08
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttLocal
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroLigne                 as integer   initial ?
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
    field cTypeContrat                 as character initial ? label '' 
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
    field sfpex                        as decimal   initial ?
    field uspex                        as character initial ?
    field cCodeDevise                  as character initial ? label 'cddev'
    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
