/*------------------------------------------------------------------------
File        : immeubleAutre.i
Purpose     : différents liens immeuble
Author(s)   : KANTENA - 2016/09/07
Notes       : Attention, ne pas enlever la valeur initiale ? et le label, automatisme sur assign.
derniere revue: 2018/05/25 - phm: OK
------------------------------------------------------------------------*/
define temp-table ttTravaux no-undo
    field iNumeroTache        as int64     initial ? /* noita */
    field cTypeContrat        as character initial ? /* tpcon */
    field iNumeroContrat      as int64     initial ? /* nocon */
    field cCodeTypeTache      as character initial ? /* tptac */
    field iChronoTache        as integer   initial ? /* notac */
    field iNumeroDossier      as integer   initial ?
    field iNumeroImmeuble     as integer   initial ?
    field daDateDebut         as date
    field daDateFin           as date
    field daDateAG            as date
    field cMotifFin           as character initial ?
    field iDuree              as integer   initial ?
    field cLibelleTravaux     as character initial ?
    field cCodeTypeTravaux    as character initial ?
    field cLibelleTypeTravaux as character initial ?
    field dMontantVote        as decimal   initial ?
    field dMontantRealise     as decimal   initial ?
    field cCodeBatiment       as character initial ?
    field iNumeroLien         as integer   initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
define temp-table ttFournisseur no-undo
    field iNumeroFournisseur  as integer   initial ?
    field iNumeroTache        as int64     initial ? /* noita */
    field cTypeContrat        as character initial ? /* tpcon */
    field iNumeroContrat      as int64     initial ? /* nocon */
    field cCodeTypeTache      as character initial ? /* tptac */
    field iChronoTache        as integer   initial ? /* notac */
    field cNomFournisseur     as character initial ?
    field iNumeroDossier      as integer   initial ?
    field cAdresseFournisseur as character initial ?
    field dMontantVote        as decimal   initial ?
    field dMontantRealise     as decimal   initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
define temp-table ttContratImmeuble no-undo
    field cTypeContrat         as character initial ? label "tpcon"
    field cNatureContrat       as character initial ? label "ntcon"
    field iNumeroContrat       as integer   initial ? label "nocon"
    field cReferenceContrat    as character initial ? label "noree"
    field iNumeroImmeuble      as integer   initial ?
    field cLibelleContrat      as character initial ?
    field daDateDebut          as date
    field daDateFin            as date
    field daResiliation        as date
    field cDivers              as character initial ?
    field lPresent             as logical   initial ?
    field lProvisoire          as logical   initial ?
    field cInfoComplementaire  as character initial ?
    field lHasPJ               as logical   initial ?
    field iNumeroFournisseur   as integer   initial ?
    field cNomFournisseur      as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
/*** MANDAT LIE AU CONTRAT DE l'IMMEUBLE ***/
define temp-table ttMandatImmeuble no-undo serialize-name "ttMandat"
    field iNumeroImmeuble      as integer   initial ?
    field iNumeroContrat       as integer   initial ?
    field cTypeContrat         as character initial ?
    field cTypeMandat          as character initial ?
    field iNumeroMandat        as int64     initial ?
    field cCodeNatureMandat    as character initial ?
    field cLibelleNatureMandat as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
/*** MANDAT LIE AU TANTIEME ***/
define temp-table ttMandatTantieme no-undo serialize-name "ttMandat"
    field iNumeroImmeuble      as integer   initial ?
    field iNumeroContrat       as integer   initial ?
    field cTypeContrat         as character initial ?
    field cTypeMandat          as character initial ?
    field iNumeroMandat        as int64     initial ?
    field cCodeNatureMandat    as character initial ?
    field cLibelleNatureMandat as character initial ?
    field iNombreTantieme      as integer   initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
