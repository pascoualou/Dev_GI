/*------------------------------------------------------------------------
File        : tacheDas2.i
Purpose     : 
Author(s)   : OF  -  05/10/2017
Notes       :
derneire revue: 2018/05/16 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheDas2
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroTache             as int64     initial ? label "noita"
    field cTypeContrat             as character initial ? label "tpcon"
    field iNumeroContrat           as int64     initial ? label "nocon"
    field cTypeTache               as character initial ? label "tptac"
    field iChronoTache             as integer   initial ? label "notac"
    field lDeclaration             as logical   initial ? label "tpges" format {&CODEREGLEMENT-ouiNon}
    field daActivation             as date                label "dtdeb"
    field daTransfert              as date                label "dtree"
    field daGenerationEcriturePPEC as date                label "dtreg"
    field iExerciceTransfere       as integer   initial ? label "duree"
    field cTypeBaremeHonoraires    as character initial ? label "tphon"
    field iCodeBaremeHonoraires    as integer   initial ? label "cdhon" format "99999"
    field cLibelleBaremeHonoraires as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
