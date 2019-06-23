/*------------------------------------------------------------------------
File        : SuiHono.i
Purpose     : Suivi des honoraires (0513/0067)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttSuihono
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy          as character  initial ? 
    field cdenr          as character  initial ? 
    field cdhon          as integer    initial ? 
    field cdmsy          as character  initial ? 
    field cdStatutVentes as character  initial ? 
    field cdUsage1       as character  initial ? 
    field dacpta         as date       initial ? 
    field dtcsy          as date       initial ? 
    field dtdeb          as date       initial ? 
    field dtfin          as date       initial ? 
    field DtIniM         as date       initial ? 
    field dtmsy          as date       initial ? 
    field DtReeM         as date       initial ? 
    field DtTrtCpta      as date       initial ? 
    field DtVAN          as date       initial ? 
    field Fg-cpta        as logical    initial ? 
    field FgSpecif       as logical    initial ? 
    field hecsy          as integer    initial ? 
    field hemsy          as integer    initial ? 
    field lbdiv          as character  initial ? 
    field lbdiv2         as character  initial ? 
    field lbdiv3         as character  initial ? 
    field lbdiv4         as character  initial ? 
    field MtFac          as decimal    initial ?  decimals 2
    field mtVAN          as decimal    initial ?  decimals 2
    field nbden          as integer    initial ? 
    field nbnum          as integer    initial ? 
    field NbPDB          as decimal    initial ?  decimals 2
    field nomdt          as integer    initial ? 
    field noper          as integer    initial ? 
    field SfLotTotM      as decimal    initial ?  decimals 2
    field SfMinVac       as decimal    initial ?  decimals 2
    field SfULMLouee     as decimal    initial ?  decimals 2
    field SfULMTot       as decimal    initial ?  decimals 2
    field tpGerance      as character  initial ? 
    field tphon          as character  initial ? 
    field TxVacPhy       as decimal    initial ?  decimals 2
    field UserModVAN     as character  initial ? 
    field UsrTrtCpta     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
