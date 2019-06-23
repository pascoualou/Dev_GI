/*------------------------------------------------------------------------
File        : paramGeneraux.i
Purpose     : 
Author(s)   : GGA  -  2017/10/27
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttParamGeneraux
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iDureeMandat             as integer   initial ?
    field cCodeDureeMandat         as character initial ?
    field cLibelleDureeMandat      as character initial ?
    field iDelaiPreavis            as integer   initial ?
    field cCodeDelaiPreavis        as character initial ?
    field cLibelleDelaiPreavis     as character initial ?
    field cCodeRepartitionTerme    as character initial ?
    field cLibelleRepartitionTerme as character initial ?
    field lEtionFicheFinPec        as logical   initial ?
    field lModifAutoReglementProp  as logical   initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
