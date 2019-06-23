/*------------------------------------------------------------------------
File        : comptabilisationReliquat.i
Purpose     : table pour gestion ecran comptabilisation des reliquats en cloture travaux
Author(s)   : gga  -  2017/05/15
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttComptabilisationReliquat 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeOd             as character
    field cJournal            as character
    field cTypeMouvement      as character
    field daDateComptable     as date
    field iNumDossier         as integer
    field cDevise             as character
    field cCodCollectif01     as character
    field cCodCollectif02     as character
    field cLibelle            as character
    field lLimitePlafond      as logical
    field dConfirmPlafond     as decimal
    field lCoproDebUniquement as logical

    field CRUD as character
.
