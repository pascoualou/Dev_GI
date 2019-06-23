/*------------------------------------------------------------------------
File        : uniteComposition.i
Purpose     :
Author(s)   : KANTENA - 2016/08/11
Notes       :
derniere revue: 2018/05/17 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCompositionUnite 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroContrat     as int64     initial ? label "nomdt"
    field iNumeroAppartement as integer   initial ? label "noapp"
    field iNumeroComposition as integer   initial ? label "nocmp"
    field iNumeroOrdreLot    as integer   initial ? label "noord"
    field iNumeroLot         as integer   initial ? label "nolot"
    field lDivisible         as logical   initial ?
    field dSurface           as decimal   initial ?
    field dSurfaceCarrez     as decimal   initial ?
    field cBatiment          as character initial ?
    field cEscalier          as character initial ?
    field cPorte             as character initial ?
    field cEtage             as character initial ?
    field cNature            as character initial ?
    field cLibNature         as character initial ?
    field cLibUsageLot       as character initial ?
    field daDisponible       as date
    field lLotPrincipal      as logical   initial ?
    field dLoyerMandat       as decimal   initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid     
.
