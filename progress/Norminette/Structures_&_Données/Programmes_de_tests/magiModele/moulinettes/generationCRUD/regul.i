/*------------------------------------------------------------------------
File        : regul.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRegul
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdmsy     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtint     as date       initial ? 
    field dtmsy     as date       initial ? 
    field FgLis     as logical    initial ? 
    field FgReg     as logical    initial ? 
    field FgTrt     as logical    initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field LbDiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field msqtt     as integer    initial ? 
    field MtArg     as decimal    initial ?  decimals 2
    field MtArg-dev as decimal    initial ?  decimals 2
    field MtPrA     as decimal    initial ?  decimals 2
    field MtPrA-dev as decimal    initial ?  decimals 2
    field MtPrM     as decimal    initial ?  decimals 2
    field MtPrM-dev as decimal    initial ?  decimals 2
    field MtPrMCal  as decimal    initial ?  decimals 2
    field MtPrt     as decimal    initial ?  decimals 2
    field MtPrt-dev as decimal    initial ?  decimals 2
    field MtPrtCal  as decimal    initial ?  decimals 2
    field MtPrV     as decimal    initial ?  decimals 2
    field MtPrV-dev as decimal    initial ?  decimals 2
    field MtQtp     as decimal    initial ?  decimals 2
    field MtQtp-dev as decimal    initial ?  decimals 2
    field mtrub     as decimal    initial ?  decimals 2
    field NbQui     as integer    initial ? 
    field NoLib     as integer    initial ? 
    field NoLoc     as int64      initial ? 
    field noloc-dec as decimal    initial ?  decimals 0
    field NoMdt     as integer    initial ? 
    field NoPer     as integer    initial ? 
    field NoRub     as integer    initial ? 
    field PcAug     as decimal    initial ?  decimals 2
    field PcVar     as decimal    initial ?  decimals 2
    field PcVarCal  as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
