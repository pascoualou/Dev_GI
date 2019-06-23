/*------------------------------------------------------------------------
File        : tva.i
Description : dataset pour les taux de tva
Author(s)   : kantena - 2016/02/04
Notes       :
derniere revue: 2018/05/03 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTVA
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iCodeTVA    as integer
    field dTauxTVA    as decimal
    field cLibelleTVA as character
    field lDefaut     as logical
    field lReduit     as logical
    field cCodeTva    as character
.
