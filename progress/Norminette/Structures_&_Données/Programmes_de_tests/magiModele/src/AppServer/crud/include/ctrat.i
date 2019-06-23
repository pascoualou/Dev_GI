/*------------------------------------------------------------------------
File        : ctrat.i
Purpose     : 
Author(s)   : GGA - 2017/09/20
Notes       : champs techniques utiles pour cette table
derniere revue: 2018/08/07 - phm: 
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCtrat 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field nodoc             as integer   initial ?
    field tpcon             as character initial ?
    field nocon             as int64     initial ?
    field dtdeb             as date
    field ntcon             as character initial ?
    field dtfin             as date
    field tpfin             as character initial ?
    field nbdur             as integer   initial ?
    field cddur             as character initial ?
    field dtsig             as date
    field lisig             as character initial ?
    field dtree             as date
    field noree             as character initial ?
    field tpren             as character initial ?
    field noren             as integer   initial ?
    field nbres             as integer   initial ?
    field utres             as character initial ?
    field tpact             as character initial ?
    field noref             as integer   initial ?
    field pcpte             as integer   initial ?
    field scpte             as integer   initial ?
    field tprol             as character initial ?
    field norol             as integer   initial ?
    field lbnom             as character initial ?
    field lnom2             as character initial ?
    field noave             as integer   initial ?
    field noblc             as integer   initial ?
    field lbdiv             as character initial ?
    field cdext             as character initial ?
    field dtini             as date
    field cdori             as character initial ?
    field cddev             as character initial ?
    field lbdiv2            as character initial ?
    field lbdiv3            as character initial ?
    field dtodf             as date
    field dtarc             as date
    field nocon-dec         as decimal   initial ?
    field norol-dec         as decimal   initial ?
    field fgdurmax          as logical   initial ?
    field nbannmax          as integer   initial ?
    field cddurmax          as character initial ?
    field dtmax             as date
    field nbrenmax          as integer   initial ?
    field lbdiv4            as character initial ?
    field lbdiv5            as character initial ?
    field lbdiv6            as character initial ?
    field fgprov            as logical   initial ?
    field dtvaldef          as date
    field tprol-ach         as character initial ?
    field norol-ach         as integer   initial ?
    field nomdt-ach         as integer   initial ?
    field fgfloy            as logical   initial ?
    field lbsig1            as character initial ?
    field lbsig2            as character initial ?
    field lbsig3            as character initial ?
    field tprolnego         as character initial ?
    field norolnego         as integer   initial ?
    field lbnomnego         as character initial ?
    field cdstatut          as character initial ?
    field nbjou1bail        as integer   initial ?
    field nbmois1Bai        as integer   initial ?
    field nbAnn1Bai         as integer   initial ?
    field cdetat            as character initial ?
    field FgResTrien        as logical   initial ?
    field cdConst-Rest      as character initial ?
    field cdClassification  as character initial ?
    field cdNature          as character initial ?
    field cdUsage1          as character initial ?
    field cdUsage2          as character initial ?
    field cdStatutVentes    as character initial ?
    field tpGerance         as character initial ?
    field tpBail            as character initial ?
    field tpEngagement      as character initial ?
    field dtEngagement      as date                extent 6
    field dtStatutVentes    as date
    field anxeb             as logical   initial ?
    field FgProlongation    as logical   initial ?
    field MotifProlongation as character initial ?
    field cdmotprolong      as character initial ?
    field web-fgactif       as logical   initial ?
    field web-datact        as date
    field web-cs            as logical   initial ?
    field web-datdesact     as date
    field web-div           as character initial ?
    field fgmadispo         as logical   initial ?
    field fgimprdoc         as logical   initial ?
    field tpmadisp          as character initial ?
    field FgAnnul           as logical   initial ?
    field DtAnnul           as date
    field cdAnnul           as character initial ?
    field dtderAG           as date
    field lClameur          as logical   initial ?
    field dtnomin           as date
    field lGIClameur        as logical   initial ?
    field cImmatCoproREGCOP as character initial ?

    field lbcsy       as character  initial ?
    field pgcsy       as character  initial ?
    field lbmsy       as character  initial ?
    field pgmsy       as character  initial ?
    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
