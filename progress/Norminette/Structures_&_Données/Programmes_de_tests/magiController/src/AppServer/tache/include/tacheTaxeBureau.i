/*------------------------------------------------------------------------
File        : tacheTaxeBureau.i
Purpose     : 
Author(s)   : GGA  -  2018/01/02
Notes       : zones dtTimestamp et rRowid pas necessaire sur table ttTacheTaxeBureau (cet enregistrement represente les infos de tous les mandat pour meme immeuble meme mandat)  
derniere revue: 2018/05/18 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheTaxeBureau
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeContrat              as character
    field iNumeroImmeuble           as integer
    field cTypeTache                as character
    field iPeriode                  as integer
    field lComptabilise             as logical
    field cCentrePaiement           as character
    field cLibelleCentrePaiement    as character
    field cCentreDeclaration        as character
    field cLibelleCentreDeclaration as character
    field cZone                     as character
    field cLibelleZone              as character
    field cNoSie01                  as character
    field cNoSie02                  as character
    field cNoSie03                  as character
    field iNoDossier                as integer
    field iNoCle                    as integer
    field iCodeCdir                 as integer
    field iCodeService              as integer

    field CRUD as character
.
&if defined(nomTableUL)   = 0 &then &scoped-define nomTableUL ttULTaxeBureau
&endif
&if defined(serialNameUL) = 0 &then &scoped-define serialNameUL {&nomTableUL}
&endif
define temp-table {&nomTableUL} no-undo serialize-name '{&serialNameUL}'
    field iNumeroContrat        as int64
    field iNumeroImmeuble       as integer
    field iNumeroUL             as integer
    field iComposition          as integer
    field cOccupant             as character
    field cTypeTarif            as character
    field cLibelleTypeTarif     as character
    field dSurfaceNormale       as decimal
    field dSurfaceReduite       as decimal
    field dSurfaceCommerciale   as decimal
    field dSurfaceStockage      as decimal
    field dSurfaceStationnement as decimal
    field dSurfaceExpo          as decimal
.
&if defined(nomTableSurface)   = 0 &then &scoped-define nomTableSurface ttSurfaceTaxeBureau
&endif
&if defined(serialNameSurface) = 0 &then &scoped-define serialNameSurface {&nomTableSurface}
&endif
define temp-table {&nomTableSurface} no-undo serialize-name '{&serialNameSurface}'
    field iNumeroContrat        as int64
    field iNumeroImmeuble       as integer
    field iNumeroUL             as integer
    field iComposition          as integer
    field iNumeroLot            as integer    
    field dSurfaceBureau        as decimal
    field dSurfaceCommerciale   as decimal
    field dSurfaceStockage      as decimal
    field dSurfaceStationnement as decimal
    field dSurfaceExpo          as decimal  
    field lDivisible            as logical

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
