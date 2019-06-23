/*-----------------------------------------------------------------------------
File        : tacheDepotGarantieBail.i
Description : tache Bail Depot de Garantie
Author(s)   : npo  -  14/02/2018
Notes       :
derniere revue: 2018/05/24 - phm: OK
-----------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheDepotGarantieBail
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroTache           as int64     initial ? label "noita"
    field cTypeContrat           as character initial ? label "tpcon"
    field iNumeroContrat         as int64     initial ? label "nocon"
    field cTypeTache             as character initial ? label "tptac"
    field iChronoTache           as integer   initial ? label "notac"
    field daActivation           as date                label "dtdeb"
    field cTypeDepot             as character initial ? label "ntges"         // combo : CMBTYPEDEPOT ???
    field cLibelleDepot          as character initial ?
    field daFin                  as date                label "dtfin"
    field cNombreMoisLoyer       as character initial ? label "tpges"
    field lReactualisationAuto   as logical   initial ? label "pdges" format "00001/00002"
    field cCodeModeCalcul        as character initial ? label "cdreg"         // combo : CMBMODECALCUL
    field cLibelleModeCalcul     as character initial ?
    field lReactualisationBaisse as logical   initial ? label "utreg" format "00001/00002"
    field lFacturationDG         as logical   initial ? label "tphon" format "00001/00002"
    field lLocaPass              as logical   initial ? label "ntreg" format "yes/no"
    field cNumeroFournisseur     as character initial ? label "pdreg"
    field cLibelleFournisseur    as character initial ?
    field cCodeRemboursement     as character initial ? label "dcreg"
    field cLibelleRemboursement  as character initial ?
    field lModifAutorise         as logical   initial ? 
    field lSupprAutorise         as logical   initial ? 

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
