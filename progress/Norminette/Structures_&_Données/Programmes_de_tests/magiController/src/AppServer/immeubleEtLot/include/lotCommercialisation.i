/*------------------------------------------------------------------------
File        : lotCommercialisation.i
Purpose     :
Author(s)   : KANTENA - 2016/08/16
Notes       :
derniere revue: 2018/05/25 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttLotCommercialisation 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroTraitement       as integer   initial ? /* numeroSignalement, numeroDemandeDevis, numeroOrdreService */
    field iNumeroImmeuble         as integer   initial ? /* noimm        */
    field iNumeroLot              as integer   initial ? /* nolot        */
    field iNumeroInterneLot       as integer   initial ? /* noloc        */
    field cCodeNature             as character initial ? /* ntlot        */
    field cLibelleNature          as character initial ? /* sys_pr NTLOT */
    field cLibelleLot             as character initial ? /* LbLot        */
    field cCodeBatiment           as character initial ? /* cdbat        */
    field cCodeEntree             as character initial ? /* CdEnt        */
    field cCodeEscalier           as character initial ? /* cdesc        */
    field cCodeEtage              as character initial ? /* CdEta        */
    field cCodePorte              as character initial ? /* cdpte        */
    field cNomOccupant            as character initial ? /* NmOcc        */
    field daAchat                 as date                /* DtAch        */
    field lSelected               as logical   initial ? /* fgsel        */
    field laffsel                 as logical   initial ? /* affsel       */
    field cEtiquetteClimat        as character initial ? /* etqClimat    */
    field iValeurEtiquetteClimat  as integer   initial ? /* valetqclimat */         /* npo #7589 */
    field cEtiquetteEnergie       as character initial ? /* etqEnergie   */
    field iValeurEtiquetteEnergie as integer   initial ? /* valetqenergie */        /* npo #7589 */
    field cCodeModeChauffage      as character initial ? /* mdcha        */
    field cLibelleModeChauffage   as character initial ? /* sys_pr MDCHA */
    field cCodeTypeChauffage      as character initial ? /* tpcha        */
    field cLibelleTypeChauffage   as character initial ? /* sys_pr TPCHA */
    field iNombreDependances      as integer   initial ? /* nbdep        */
    field iNombreNiveaux          as integer   initial ? /* nbniv        */
    field iNombrePieces           as integer   initial ? /* nbpie        */
    field iNombrePiecesProf       as integer   initial ? /* nbprf        */
    field iNombreChambresService  as integer   initial ? /* nbser        */
    field cTerraseLoggiaBalcon    as character initial ? /* cdtlb        */
    field cUsage                  as character initial ? /* cdusage  AGF */
    field lAirConditionne         as logical   initial ? /* fgair        */
    field lChauffageIndividuel    as logical   initial ? /* fgcha        */
    field lEauFroideIndividuelle  as logical   initial ? /* fgfra        */
    field lMeuble                 as logical   initial ? /* fgmbl        */
    field lWCIndependant          as logical   initial ? /* fgwci        */
    field dSurfaceReelle          as decimal   initial ? /* sfree        */
    field dSurfacePonderee        as decimal   initial ? /* sfpde        */
    field dSurfaceAnnexes         as decimal   initial ? /* sfaxe        */
    field dSurfaceBureau          as decimal   initial ? /* sfbur        */
    field dSurfaceCommercial      as decimal   initial ? /* sfcom        */
    field dSurfaceNonUtilisee     as decimal   initial ? /* sfnon        */
    field dSurfaceArchives        as decimal   initial ? /* sfarc        */
    field dSurfaceHorsOeuvreNet   as decimal   initial ? /* sfhon        */
    field dSurfaceLocauxStockage  as decimal   initial ? /* sfstk        */
    field dSurfaceTerrasse        as decimal   initial ? /* sfter        */
    field dSurfaceCorrigee        as decimal   initial ? /* sfcor        */

    field dtTimestamp as datetime
    field CRUD        as character
.
