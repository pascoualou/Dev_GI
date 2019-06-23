/*------------------------------------------------------------------------
File        : tacheBaux.i
Purpose     : table tache baux
Author(s)   : GGA  -  2017/08/03
Notes       : table utilisé seulement pour de l'affichage (pas de mise à jour)
derniere revue: 2018/05/19 - gga: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheBaux
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeContrat          as character initial ? label "tpcon"
    field iNumeroContrat        as int64     initial ? label "nocon"
    field cTypeTache            as character initial ? label "tptac"
    field cCodeLocataire        as character initial ?
    field cNomLocataire         as character initial ?
    field daDebut               as date                label "dtdeb"
    field daFin                 as date                label "dtfin"
    field daResil               as date                label "dtree"
    field daAnnul               as date
    field daSortie              as date
    field cCodeNatureContrat    as character initial ?
    field cLibelleNatureContrat as character initial ?
    field lResilie              as logical   initial ?
    field iNumeroLotPrinc       as integer   initial ?
    field lTaciteReconduction   as logical   initial ?
.
