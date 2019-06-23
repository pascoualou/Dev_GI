/*------------------------------------------------------------------------
File        : listeTache.i
Description : liste taches pour un mandat
Author(s)   : gga 2017/08/03
Notes       : 
Derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttListeTache
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeContrat                   as character initial ?
    field iNumeroContrat                 as int64     initial ?
    field cTypeTache                     as character initial ?
    field cLibelleTache                  as character initial ?
    field lObligatoire                   as logical   initial ?
    field iRangObligatoire               as integer   initial ?
    field lTacheContrat                  as logical   initial ? 
    field cTypeTacheMere                 as character initial ? 
    field cTypeTacheExclusive            as character initial ? 
    field lPec                           as logical   initial ?
    field iRangPec                       as integer   initial ?
    field lPecSpecifique                 as logical   initial ?
    field iRangPecSpecifique             as integer   initial ?
    field lCttacExiste                   as logical
    field lTacheExiste                   as logical
    field lParamDefautGestionCabinet     as logical   initial ?
    field lParamDefautActivation         as logical   initial ?
    field lParamDefautCreationAutoTache  as logical   initial ?
    field cInfoCodification              as character initial ?
    field lCodificationCreationAutoCttac as logical   initial ?
    field lCodificationCreationAutoTache as logical   initial ?
.
