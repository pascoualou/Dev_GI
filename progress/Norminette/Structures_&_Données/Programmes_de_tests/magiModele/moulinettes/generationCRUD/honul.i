/*------------------------------------------------------------------------
File        : honul.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttHonul
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field art-cle    as character  initial ? 
    field cdcsy      as character  initial ? 
    field cdhon      as integer    initial ? 
    field cdmsy      as character  initial ? 
    field dtcsy      as date       initial ? 
    field dtdeb      as date       initial ? 
    field dtfin      as date       initial ? 
    field dtmsy      as date       initial ? 
    field fgpro      as logical    initial ? 
    field hecsy      as integer    initial ? 
    field hemsy      as integer    initial ? 
    field lbdiv      as character  initial ? 
    field lbdiv2     as character  initial ? 
    field lbdiv3     as character  initial ? 
    field lbdiv4     as character  initial ? 
    field lbdiv5     as character  initial ? 
    field msqtt      as integer    initial ? 
    field mtbar      as decimal    initial ?  decimals 2
    field mthon      as decimal    initial ?  decimals 10
    field nbjou      as integer    initial ? 
    field nbjouindis as integer    initial ? 
    field nbjouocc   as integer    initial ? 
    field nbjouvac   as integer    initial ? 
    field noapp      as integer    initial ? 
    field nomdt      as integer    initial ? 
    field nthon      as character  initial ? 
    field pdhon      as character  initial ? 
    field tphon      as character  initial ? 
    field txtva      as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
