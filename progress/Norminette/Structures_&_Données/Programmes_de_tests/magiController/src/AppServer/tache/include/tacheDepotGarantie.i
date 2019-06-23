/*------------------------------------------------------------------------
File        : tacheDepotGarantie.i
Purpose     : table tache depot de garantie
Author(s)   : GGA  -  28/07/2017
Notes       :
derniere revue: 2018/05/19 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheDepotGarantie
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroTache   as int64     initial ? label "noita"
    field cTypeContrat   as character initial ? label "tpcon"
    field iNumeroContrat as int64     initial ? label "nocon"
    field cTypeTache     as character initial ? label "tptac"
    field iChronoTache   as integer   initial ? label "notac"
    field daActivation   as date                label "dtdeb"
    field cTypeDepot     as character initial ? label "ntges"
    field cLibelleDepot  as character initial ?
    field daFin          as date                label "dtfin"
    field lModifAutorise as logical   initial ? 
    field lSupprAutorise as logical   initial ? 

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
