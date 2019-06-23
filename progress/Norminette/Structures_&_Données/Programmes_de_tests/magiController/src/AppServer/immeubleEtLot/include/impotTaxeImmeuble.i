/*-----------------------------------------------------------------------------
File        : impotTaxeImmeuble.i
Purpose     : 
Author(s)   : KANTENA - 07/08/2017 
Notes       :
derniere revue: 2018/05/25 - phm: OK
-----------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttImpotTaxe
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroImmeuble    as integer   initial ?
    field iNumeroTache       as int64     initial ? label 'noita'
    field cTypeContrat       as character initial ? label 'tpcon'
    field iNumeroContrat     as int64     initial ? label 'nocon'
    field cCodeTypeTache     as character initial ? label 'tptac'
    field iChronoTache       as integer   initial ? label 'notac'
    field cCodeTypeOrganisme as character initial ?
    field cNumeroOrganisme   as character initial ?
    field cNomOrganisme      as character initial ?
    field cLibelleAdresse    as character initial ?
    field cTelephone         as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
