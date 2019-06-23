/*------------------------------------------------------------------------
File        : periodeChargesCopro.i
Purpose     : 
Author(s)   : OFA  -  2019/01/07
Notes       :
derniere revue:
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPeriodeChargesCopro
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeContrat           as character initial ? label "tpctt"
    field iNumeroMandat          as int64     initial ? label "nomdt"
    field iNumeroExercice        as integer   initial ? label "noexo"
    field iNumeroPeriode         as integer   initial ? label "noper"
    field daDebut                as date                label "dtdeb"
    field daFin                  as date                label "dtfin"
    field cLibellePeriode        as character initial ? label "lbper"
    field iNombreMois            as integer   initial ? label "nbmoi"
    field cCodePeriodicite       as character initial ? label "cdper"
    field cCodeTraitement        as character initial ? label "cdtrt"
    field cLibelleCodeTraitement as character initial ?
    field lIsModifiable          as logical

    field dtTimestamp as datetime 
    field CRUD        as character 
    field rRowid      as rowid
.
