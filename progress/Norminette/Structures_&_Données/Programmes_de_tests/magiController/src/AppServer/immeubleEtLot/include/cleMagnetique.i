/*------------------------------------------------------------------------
File        : cleMagnetique.i
Description : 
Author(s)   : kantena  -  2017/06/08
Notes       :
derniere revue: 2018/05/25 - phm: OK
------------------------------------------------------------------------*/
define temp-table ttCleMagnetique no-undo
    field iNumeroImmeuble     as integer   initial ?
    field iNumeroCle          as int64     initial 0 /* noita */
    field cTypeContrat        as character initial ? /* tpcon */
    field iNumeroContrat      as int64     initial ? /* nocon */
    field cCodeTypeTache      as character initial ? /* tptac */
    field iChronoTache        as integer   initial ? /* notac */
    field cLibelle1           as character initial ?
    field cLibelle2           as character initial ?
    field iNombreCle          as integer   initial ?
    field iNombreCleRemise    as integer   initial ?
    field iNombreCleDispo     as integer   initial ?
    field cCodeBatiment       as character initial ?
    field cCodeEntree         as character initial ?
    field cCodeEscalier       as character initial ?
    field cCodeFournisseur    as character initial ?
    field cLibelleFournisseur as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
    index primaire is primary unique iNumeroCle
.
define temp-table ttCleMagnetiqueDetail no-undo
    field iNumeroImmeuble    as integer   initial ?
    field iNumeroTemporaire  as integer   initial ?
    field iNumeroCle         as int64     initial ? /* N° clé parent */
    field iNumeroDetail      as int64     initial ? /* noita */
    field cTypeContrat       as character initial ? /* tpcon */
    field iNumeroContrat     as int64     initial ? /* nocon */
    field cCodeTypeTache     as character initial ? /* tptac */
    field iChronoTache       as integer   initial ? /* notac */
    field iNumeroLot         as integer   initial ?
    field cNumeroCompte      as character initial ?
    field cCodeTypeRole      as character initial ?
    field cLibelleTypeRole   as character initial ?    
    field iNumeroTiers       as character initial ?
    field cNomTiers          as character initial ?
    field iNombrePieceRemise as integer   initial ?
    field iNombrePieceTotal  as integer   initial ?
    field cNumeroSerie       as character initial ?
    field dMontantTotal      as decimal   initial ?
    field dMontantCaution    as decimal   initial ?
    field daDateRemise       as date
    field daDateRestitution  as date
    field cCommentaire       as character initial ?

    field dtTimestamp as datetime 
    field CRUD        as character 
    field rRowid      as rowid
.
