/*------------------------------------------------------------------------
File        : digicode.i
Description : 
Author(s)   : kantena  -  20176/05
Notes       :
derniere revue: 2018/05/25 - phm: OK
------------------------------------------------------------------------*/
define temp-table ttDigicodeImmeuble no-undo                      // LIEN DIGICODE IMMEUBLE
    field iNumeroImmeuble as integer   initial ?
    field iNumeroDigicode as int64     initial ? /* noita */
    field cTypeContrat    as character initial ? /* tpcon */
    field iNumeroContrat  as int64     initial ? /* nocon */
    field cCodeTypeTache  as character initial ? /* tptac */
    field iChronoTache    as integer   initial ? /* notac */
    field cCodeBatiment   as character initial ?
    field cCodeEntree     as character initial ?
    field cCodeEscalier   as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
define temp-table ttDigicode no-undo                              // DIGICODE
    field iNumeroImmeuble  as integer   initial ?
    field iNumeroDigicode  as int64     initial ? /* noita */
    field cTypeContrat     as character initial ? /* tpcon */
    field iNumeroContrat   as int64     initial ? /* nocon */
    field cCodeTypeTache   as character initial ? /* tptac */
    field iChronoTache     as integer   initial ? /* notac */
    field iExtent          as integer   initial ? /* 1 ou 2 digicode possible */
    field cLibelleDigicode as character initial ?
    field cAncienDigicode  as character initial ?
    field cNouveauDigicode as character initial ?
    field daDateDebut      as date
    field daDateFin        as date

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
