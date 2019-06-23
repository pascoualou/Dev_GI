/*-----------------------------------------------------------------------------
File        : tacheRisqueLocatif.i
Purpose     : Tables d'échanges Controler-Modèle
Author(s)   : PL - 14/05/2018
Notes       :
derniere revue: 2018/05/24 - phm: OK
-----------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheRisqueLocatif
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroTache     as int64     initial ? label "noita"
    field cTypeContrat     as character initial ? label "tpcon"
    field iNumeroContrat   as int64     initial ? label "nocon"
    field cTypeTache       as character initial ? label "tptac"
    field iChronoTache     as integer   initial ? label "notac"
    field daActivation     as date      label "dtdeb"    // HwDtaDtd
    field iNumeroGarantie  as integer   initial ? label "cdreg"    // HwDtaGlo
    field iNumeroBareme    as integer   initial ? label "duree"    // HwDtaBar
    field daApplication    as date      label "dtreg"    // HwDtaDap
    field cNumeroPasseport as character label "dossier"  // HwDtaPass
    field cCategoriebail   as character initial ?                  // Catégorie du bail (HAB/COM)
    field lModifAutorise   as logical   initial ?
    field lSupprAutorise   as logical   initial ?

    field dtTimestamp      as datetime
    field CRUD             as character
    field rRowid           as rowid
    .
&if defined(nomTableEchangesGRL)   = 0 &then &scoped-define nomTableEchangesGRL ttEchangesGRL
&endif
&if defined(serialNameEchangesGRL) = 0 &then &scoped-define serialNameEchangesGRL {&nomTableEchangesGRL}
&endif
define temp-table {&nomTableEchangesGRL} no-undo serialize-name '{&serialNameEchangesGRL}'
    field cCode   as character initial ?
    field cValeur as character initial ?
    .
