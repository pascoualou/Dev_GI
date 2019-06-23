/*------------------------------------------------------------------------
File        : mesureAdministrative.i
Purpose     : 
Author(s)   : KANTENA - 07/08/2017 
Notes       :
derniere revue: 2018/05/25 - phm: OK
------------------------------------------------------------------------*/
define temp-table ttMesureAdministrative no-undo
    field iNumeroImmeuble as integer   initial ?
    field iNumeroTache    as int64     initial ? /* noita */
    field cTypeContrat    as character initial ? /* tpcon */
    field iNumeroContrat  as int64     initial ? /* nocon */
    field cCodeTypeTache  as character initial ? /* tptac */
    field iChronoTache    as integer   initial ? /* notac */
    field cCodeReponse    as character initial ?
    field cCommentaire    as character initial ?
    field daDateDebut     as date
    field daDateFin       as date
    field lValeurReponse  as logical   initial ?
    field iCodeLibelle    as integer   initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.