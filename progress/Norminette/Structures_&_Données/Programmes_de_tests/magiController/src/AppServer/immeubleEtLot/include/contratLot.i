/*------------------------------------------------------------------------
File        : contratlot.i
Purpose     :
Author(s)   : KANTENA - 2018/09/13
Notes       :

------------------------------------------------------------------------*/
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