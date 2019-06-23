/*------------------------------------------------------------------------
File        : SuiHonDet.i
Purpose     : Detail du suivi des honoraires SuiHono (0513/0067)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttSuihondet
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy      as character  initial ? 
    field cdhon      as integer    initial ? 
    field cdmsy      as character  initial ? 
    field dtcsy      as date       initial ? 
    field dtdeb      as date       initial ? 
    field dtfin      as date       initial ? 
    field dtmsy      as date       initial ? 
    field fgdiv      as logical    initial ? 
    field FgErr      as logical    initial ? 
    field hecsy      as integer    initial ? 
    field hemsy      as integer    initial ? 
    field LbComment  as character  initial ? 
    field lbdiv      as character  initial ? 
    field lbdiv2     as character  initial ? 
    field lbdiv3     as character  initial ? 
    field lbdiv4     as character  initial ? 
    field LbErr      as character  initial ? 
    field LstBauxPer as character  initial ? 
    field LstULper   as character  initial ? 
    field nbjocc     as decimal    initial ?  decimals 2
    field nbjtot     as decimal    initial ?  decimals 2
    field nolot      as integer    initial ? 
    field nomdt      as integer    initial ? 
    field noper      as integer    initial ? 
    field SfLot      as decimal    initial ?  decimals 2
    field tphon      as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
