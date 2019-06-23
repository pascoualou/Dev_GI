/*------------------------------------------------------------------------
File        : salimp.i
Purpose     : Imputation comptable par salarié,clé, rub et sous-rub ana
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttSalimp
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcle   as character  initial ? 
    field cdcsy   as character  initial ? 
    field cdenr   as character  initial ? 
    field cdmsy   as character  initial ? 
    field cdrub   as integer    initial ? 
    field cdsru   as integer    initial ? 
    field dtcsy   as date       initial ? 
    field dtmsy   as date       initial ? 
    field hecsy   as integer    initial ? 
    field hemsy   as integer    initial ? 
    field lbdiv   as character  initial ? 
    field lbdiv2  as character  initial ? 
    field lbdiv3  as character  initial ? 
    field norol   as int64      initial ? 
    field tbpcana as decimal    initial ?  decimals 4
    field tbpccle as decimal    initial ?  decimals 4
    field tbpcres as decimal    initial ?  decimals 4
    field tprol   as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
