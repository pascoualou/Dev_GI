/*------------------------------------------------------------------------
File        : ttlienRubriqueAnalytique.i
Description :
Author(s)   : DMI 20180330
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttlienRubriqueAnalytique
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iCodeRubrique        as integer   initial ? label "rub-cd"
    field cLibelleRubrique     as character initial ? label "librub"
    field iCodeSousRubrique    as integer   initial ? label "ssrub-cd"
    field cLibelleSousRubrique as character initial ? label "libssrub"
    field lSelection           as logical   initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
