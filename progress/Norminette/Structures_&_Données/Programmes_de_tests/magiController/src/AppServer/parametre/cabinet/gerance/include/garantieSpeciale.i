/*------------------------------------------------------------------------
File        : garantieSpeciale.i
Purpose     :
Author(s)   : RF  -  09/11/2017
Notes       : Paramétrage des assurances garanties - 01020 à 1023 - Garantie Speciale
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
define temp-table ttGarantieSpeciale no-undo
    field cTypeContrat             as character initial ?   /* tpctt      */
    field cLibelleTypeContrat      as character initial ? 
    field iNumeroContrat           as integer   initial ?   /* noctt      */
    field cCodePeriodicite         as character initial ?   /* cdper      */
    field cLibellePeriodicite      as character initial ?
    field cModeComptabilisation    as character initial ?   /* lbdiv2     */
    field cLibelleComptabilisation as character initial ?
    field cEntiteComptabilisation  as character initial ?
    field cCodeModeleEdition       as character initial ?   /* lbdiv      */
    field cLibelleModeleEdition    as character initial ?
    field cNumeroCompte            as character initial ?
    field cCodeFournisseur         as character initial ?
    field cLibelleFournisseur      as character initial ?
    field iNombreMoisMax           as integer   initial ?   /* nbmca      */

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
define temp-table ttBaremeGarantieSpeciale no-undo
    field cTypeContrat    as character initial ?
    field iNumeroContrat  as integer   initial ?
    field INumeroBareme   as integer   initial ?
    field dTauxCotisation as decimal   initial ?
    field dTauxHonoraire  as decimal   initial ?
    field dTauxResultat   as decimal   initial ?
.
define temp-table ttRubriqueGarantieSpeciale no-undo
    field cTypeContrat       as character initial ?
    field iNumeroContrat     as integer   initial ?
    field iCodeRubrique      as integer   initial ?
    field cLibelleRubrique   as character initial ?
    field lSelectionRubrique as logical   initial ?
.
