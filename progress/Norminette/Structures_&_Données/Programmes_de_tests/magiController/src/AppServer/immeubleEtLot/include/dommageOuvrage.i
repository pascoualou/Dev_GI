/*------------------------------------------------------------------------
File        : dommageOuvrage.i
Description : 
Author(s)   : KANTENA - 2017/08/07
Notes       :
derniere revue: 2018/05/25 - phm: OK
------------------------------------------------------------------------*/
define temp-table ttDommageOuvrage no-undo
    field iNumeroImmeuble     as integer   initial ?
    field iNumeroTache        as int64     initial ? /* noita */
    field cTypeContrat        as character initial ? /* tpcon */
    field iNumeroContrat      as int64     initial ? /* nocon */
    field cCodeTypeTache      as character initial ? /* tptac */
    field iChronoTache        as integer   initial ? /* notac */
    field cPolice             as character initial ?
    field cGarantie           as character initial ?
    field iNumeroCompagnie    as integer   initial ?
    field cNomCompagnie       as character initial ?
    field iNumeroCourtier     as integer   initial ?
    field cNomCourtier        as character initial ?
    field cCodeFournisseur    as character initial ?
    field cLibelleFournisseur as character initial ?
    field daDateReception     as date
    field daDateDebut         as date
    field daDateFin           as date
    field cCommentaireTravaux as character initial ?
    field cCodeBatiment       as character initial ?
    field cLibelleBatiment    as character initial ?
    field cCodeTypeOuvrage    as character initial ?
    field cLibelleTypeOuvrage as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
