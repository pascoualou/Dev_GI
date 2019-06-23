/*------------------------------------------------------------------------
File        : TrfPm.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTrfpm
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy      as character  initial ? 
    field cddev      as character  initial ? 
    field CdEcr      as character  initial ? 
    field CdFre      as character  initial ? 
    field CdFro      as character  initial ? 
    field CdLot      as character  initial ? 
    field cdmsy      as character  initial ? 
    field cdpli      as character  initial ? 
    field cdprelsold as character  initial ? 
    field cdreg      as character  initial ? 
    field cdsol      as character  initial ? 
    field cdtir      as character  initial ? 
    field circu      as character  initial ? 
    field dtapp      as date       initial ? 
    field dtcsy      as date       initial ? 
    field DtEch      as date       initial ? 
    field dtedi      as date       initial ? 
    field dtems      as date       initial ? 
    field DtFre      as date       initial ? 
    field DtFro      as date       initial ? 
    field DtInc      as date       initial ? 
    field dtmsy      as date       initial ? 
    field dtprel     as date       initial ? 
    field DtSol      as date       initial ? 
    field dttrf      as date       initial ? 
    field EtTrt      as character  initial ? 
    field hecsy      as integer    initial ? 
    field hemsy      as integer    initial ? 
    field hetrf      as integer    initial ? 
    field lbdiv      as character  initial ? 
    field lbdiv2     as character  initial ? 
    field lbdiv3     as character  initial ? 
    field NbExp      as integer    initial ? 
    field noapp      as integer    initial ? 
    field noapr      as integer    initial ? 
    field nochr      as integer    initial ? 
    field noexe      as integer    initial ? 
    field noexr      as integer    initial ? 
    field nomdt      as integer    initial ? 
    field noreg      as integer    initial ? 
    field TpApp      as character  initial ? 
    field TpApr      as character  initial ? 
    field TpTrf      as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
