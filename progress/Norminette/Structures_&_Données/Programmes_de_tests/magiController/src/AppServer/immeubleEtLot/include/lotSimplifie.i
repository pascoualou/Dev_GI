/*------------------------------------------------------------------------
File        : lotSimplifie.i
Purpose     :
Author(s)   : KANTENA - 2016/09/07
Notes       :
------------------------------------------------------------------------*/
define temp-table ttListeLot no-undo serialize-name "ttLot"
    field iNumeroLigne             as integer   
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

