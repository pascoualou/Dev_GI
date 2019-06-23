/*------------------------------------------------------------------------
File        : plan.i
Description : 
Author(s)   : kantena  -  2017/06/01 
Notes       :
derniere revue: 2018/05/25 - phm: OK
------------------------------------------------------------------------*/
define temp-table ttPlan no-undo
    field iNumeroImmeuble as integer   initial ?
    field iNumeroLot      as integer   initial ?
    field iNumeroPlan     as integer   initial ?
    field cTypeContrat    as character initial ? /* tpcon */
    field iNumeroContrat  as int64     initial ? /* nocon */
    field cCodeTypeTache  as character initial ? /* tptac */
    field iChronoTache    as integer   initial ? /* notac */
    field cTypePlan       as character initial ?
    field cLibellePlan    as character initial ?
    field cCodeBatiment   as character initial ?
    field lPrivatif       as logical   initial ?
    field cCommentaire    as character initial ?
    field daDatePlan      as date
    field cNomOrganisme   as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
