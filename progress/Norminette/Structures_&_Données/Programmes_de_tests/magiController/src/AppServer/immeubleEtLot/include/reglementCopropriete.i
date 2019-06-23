/*------------------------------------------------------------------------
File        : reglementCopropriete.i
Purpose     : 
Author(s)   : KANTENA - 07/08/2017
Notes       :
derniere revue: 2018/05/25 - phm: OK
------------------------------------------------------------------------*/
define temp-table ttReglementCopropriete no-undo
    field iNumeroReglement      as int64     initial ? /* noita */
    field cTypeContrat          as character initial ? /* tpcon */
    field iNumeroContrat        as int64     initial ? /* nocon */
    field cCodeTypeTache        as character initial ? /* tptac */
    field iChronoTache          as integer   initial ? /* notac */
    field iNumeroImmeuble       as integer   initial ?
    field daDateReglement       as date
    field cLieuReglement        as character initial ?
    field daDatePublication     as date
    field cNomBureau            as character initial ?
    field iNumeroNotaire        as integer   initial ?
    field cNomNotaire           as character initial ?
    field cVolume               as character initial ? /* pdges */
    field cNumero               as character initial ? /* pdreg */
    field iTotalLot             as integer   initial ?
    field iNombreLotsPrincipaux as integer   initial ?
    field cCommentaire          as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.