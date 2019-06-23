/*-----------------------------------------------------------------------------
File        : coloc.i
Purpose     :
Author(s)   :   -  2017/05/10
Notes       :
Derniere revue: 2018/05/23 - phm: OK
-----------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttColoc
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
&if defined(serialIdentifiant) = 0 &then &scoped-define serialIdentifiant identifiant
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field identifiant      as int64     serialize-name "{&serialIdentifiant}"
    field iNumeroTiers     as int64     initial ?
    field cTypeRole        as character initial ?
    field cNumeroRole      as character initial ?
    field cTypeContrat     as character initial ?
    field iNumeroContrat   as int64     initial ?
    field cLibelleTypeRole as character initial ?
    field cLibelleTiers    as character initial ?
    field cAdresseTiers    as character initial ?
    field lSelection       as logical   initial ?
.
