/*------------------------------------------------------------------------
File        : tacheGarantieLoyer.i
Purpose     :
Author(s)   : PL  -  06/03/2018
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheGarantieLoyer
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroTache    as int64     initial ? label "noita"
    field cTypeContrat    as character initial ? label "tpcon"
    field iNumeroContrat  as int64     initial ? label "nocon"
    field cTypeTache      as character initial ? label "tptac"
    field iChronoTache    as integer   initial ? label "notac"
    field daActivation    as date      label "dtdeb"  // HwDtaDtd
    field iNumeroGarantie as integer   initial ? label "cdreg"  // HwDtaGlo
    field iNumeroBareme   as integer   initial ? label "duree"  // HwDtaBar
    field daApplication   as date      label "dtreg"  // HwDtaDap
    field cIdAssureur     as character initial ? label "lbdiv2"  // HwDatIDA
    field cCategoriebail  as character initial ?   // Catégorie du bail (HAB/COM)
    field lModifAutorise  as logical   initial ?
    field lSupprAutorise  as logical   initial ?

    field dtTimestamp     as datetime
    field CRUD            as character
    field rRowid          as rowid
    .

&if defined(nomTableEchangesGLO)   = 0 &then &scoped-define nomTableEchangesGLO ttEchangesGLO
&endif
&if defined(serialNameEchangesGLO) = 0 &then &scoped-define serialNameEchangesGLO {&nomTableEchangesGLO}
&endif
define temp-table {&nomTableEchangesGLO} no-undo serialize-name '{&serialNameEchangesGLO}'
    field cCode   as character initial ?
    field cValeur as character initial ?
    .
