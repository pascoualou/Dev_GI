/*------------------------------------------------------------------------
File        : gardienLoge.i
Description : 
Author(s)   : KANTENA  -  2016/12/20
Notes       :
derniere revue: 2018/05/25 - phm: OK
------------------------------------------------------------------------*/
define temp-table ttGardien no-undo
    field iNumeroTache        as int64     initial ? /* noita */
    field cTypeContrat        as character initial ? /* tpcon */
    field iNumeroContrat      as int64     initial ? /* nocon */
    field cCodeTypeTache      as character initial ? /* tptac */
    field iChronoTache        as integer   initial ? /* notac */
    field iNumeroImmeuble     as integer   initial ?
    field cNomGardien         as character initial ? /* tpges */
    field cCoordonneeContact1 as character initial ? /* Coordonnées de la personne à contacter               */
    field cCoordonneeContact2 as character initial ? /* Coordonnées de la personne à contacter               */
    field lPrincipal          as logical   initial ?
    field cCodeBatiment       as character initial ?
    field cCodeEntree         as character initial ?
    field cCodeEscalier       as character initial ?
    field cCommentaire        as character initial ?

    field CRUD        as character
    field dtTimestamp as datetime
    field rRowid      as rowid
.
define temp-table ttLoge no-undo
    field iNumeroLoge         as integer   initial ?
    field iNumeroTache        as integer   initial ?      /* 1 : tâche unique                                     */
    field iNumeroImmeuble     as integer   initial ?
    field cTypeContrat        as character initial ?      /* '01036'                                              */
    field iNumeroContrat      as int64     initial ?      /* N° Contrat construction                              */
    field cTypeTache          as character initial ?      /* "04257"                                              */
    field cNomContact         as character initial ?      /* Nom de la personne à contacter                       */
    field cCoordonneeContact1 as character initial ?      /* Coordonnées de la personne à contacter               */
    field cCoordonneeContact2 as character initial ?      /* Coordonnées de la personne à contacter               */
    field cNomTiersDepannage  as character initial ?      /* Depannage sonner chez                                */
    field cCodeTiersDepannage as character initial ?      /* Depannage sonner chez : Tiers : TpRol + "," + NoRol  */
    field cCommentaire        as character initial ?

    field CRUD        as character
    field dtTimestamp as datetime
    field rRowid      as rowid
.
