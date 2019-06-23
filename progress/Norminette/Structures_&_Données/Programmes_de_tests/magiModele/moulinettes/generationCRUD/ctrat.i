/*------------------------------------------------------------------------
File        : ctrat.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCtrat
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field anxeb             as logical    initial ? 
    field cdAnnul           as character  initial ? 
    field cdClassification  as character  initial ? 
    field cdConst-Rest      as character  initial ? 
    field cdcsy             as character  initial ? 
    field cddev             as character  initial ? 
    field cddur             as character  initial ? 
    field cddurmax          as character  initial ? 
    field cdetat            as character  initial ? 
    field cdext             as character  initial ? 
    field cdmotprolong      as character  initial ? 
    field cdmsy             as character  initial ? 
    field cdNature          as character  initial ? 
    field cdori             as character  initial ? 
    field cdstatut          as character  initial ? 
    field cdStatutVentes    as character  initial ? 
    field cdUsage1          as character  initial ? 
    field cdUsage2          as character  initial ? 
    field DtAnnul           as date       initial ? 
    field dtarc             as date       initial ? 
    field dtcsy             as date       initial ? 
    field dtdeb             as date       initial ? 
    field dtderAG           as date       initial ? 
    field dtEngagement      as date       initial ? 
    field dtfin             as date       initial ? 
    field dtini             as date       initial ? 
    field dtmax             as date       initial ? 
    field dtmsy             as date       initial ? 
    field dtnomin           as date       initial ? 
    field dtodf             as date       initial ? 
    field dtree             as date       initial ? 
    field dtsig             as date       initial ? 
    field dtStatutVentes    as date       initial ? 
    field dtvaldef          as date       initial ? 
    field FgAnnul           as logical    initial ? 
    field fgdurmax          as logical    initial ? 
    field fgfloy            as logical    initial ? 
    field fgimprdoc         as logical    initial ? 
    field fgmadispo         as logical    initial ? 
    field FgProlongation    as logical    initial ? 
    field fgprov            as logical    initial ? 
    field FgResTrien        as logical    initial ? 
    field hecsy             as integer    initial ? 
    field hemsy             as integer    initial ? 
    field lbdiv             as character  initial ? 
    field lbdiv2            as character  initial ? 
    field lbdiv3            as character  initial ? 
    field lbdiv4            as character  initial ? 
    field lbdiv5            as character  initial ? 
    field lbdiv6            as character  initial ? 
    field lbnom             as character  initial ? 
    field lbnomnego         as character  initial ? 
    field lbsig1            as character  initial ? 
    field lbsig2            as character  initial ? 
    field lbsig3            as character  initial ? 
    field lClameur          as logical    initial ? 
    field lGIClameur        as logical    initial ? 
    field lisig             as character  initial ? 
    field lnom2             as character  initial ? 
    field MotifProlongation as character  initial ? 
    field nbAnn1Bai         as integer    initial ? 
    field nbannmax          as integer    initial ? 
    field nbdur             as integer    initial ? 
    field nbjou1bail        as integer    initial ? 
    field nbmois1Bai        as integer    initial ? 
    field nbrenmax          as integer    initial ? 
    field nbres             as integer    initial ? 
    field noave             as integer    initial ? 
    field noblc             as integer    initial ? 
    field nocon             as int64      initial ? 
    field nocon-dec         as decimal    initial ?  decimals 0
    field nodoc             as integer    initial ? 
    field nomdt-ach         as integer    initial ? 
    field noree             as character  initial ? 
    field noref             as integer    initial ? 
    field noren             as integer    initial ? 
    field norol             as integer    initial ? 
    field norol-ach         as integer    initial ? 
    field norol-dec         as decimal    initial ?  decimals 0
    field norolnego         as integer    initial ? 
    field ntcon             as character  initial ? 
    field pcpte             as integer    initial ? 
    field scpte             as integer    initial ? 
    field tpact             as character  initial ? 
    field tpBail            as character  initial ? 
    field tpcon             as character  initial ? 
    field tpEngagement      as character  initial ? 
    field tpfin             as character  initial ? 
    field tpGerance         as character  initial ? 
    field tpmadisp          as character  initial ? 
    field tpren             as character  initial ? 
    field tprol             as character  initial ? 
    field tprol-ach         as character  initial ? 
    field tprolnego         as character  initial ? 
    field utres             as character  initial ? 
    field web-cs            as logical    initial ? 
    field web-datact        as date       initial ? 
    field web-datdesact     as date       initial ? 
    field web-div           as character  initial ? 
    field web-fgactif       as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
