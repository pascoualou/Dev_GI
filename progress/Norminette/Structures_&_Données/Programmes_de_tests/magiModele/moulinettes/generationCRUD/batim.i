/*------------------------------------------------------------------------
File        : batim.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttBatim
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field afdev  as integer    initial ? 
    field afhab  as integer    initial ? 
    field after  as integer    initial ? 
    field afvet  as integer    initial ? 
    field cdbat  as character  initial ? 
    field cdcsy  as character  initial ? 
    field cddev  as character  initial ? 
    field cdmsy  as character  initial ? 
    field dtcsy  as date       initial ? 
    field dtdch  as character  initial ? 
    field dtfch  as character  initial ? 
    field dtmsy  as date       initial ? 
    field fgrel  as logical    initial ? 
    field fgven  as logical    initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field LbBat  as character  initial ? 
    field Lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field mdcha  as character  initial ? 
    field mdchd  as character  initial ? 
    field mdcli  as character  initial ? 
    field mdfra  as character  initial ? 
    field nbant  as integer    initial ? 
    field nbasc  as integer    initial ? 
    field nbcab  as integer    initial ? 
    field nbesc  as integer    initial ? 
    field nbeta  as integer    initial ? 
    field nbext  as integer    initial ? 
    field nbfer  as integer    initial ? 
    field nbint  as integer    initial ? 
    field nblet  as integer    initial ? 
    field nblog  as integer    initial ? 
    field nbmch  as integer    initial ? 
    field nbpar  as integer    initial ? 
    field nbpkg  as integer    initial ? 
    field nbppe  as integer    initial ? 
    field nbpss  as integer    initial ? 
    field nbpte  as integer    initial ? 
    field nbsss  as integer    initial ? 
    field nbtap  as integer    initial ? 
    field nbvdo  as integer    initial ? 
    field nbvid  as integer    initial ? 
    field nobat  as integer    initial ? 
    field noimm  as integer    initial ? 
    field sfdev  as decimal    initial ?  decimals 2
    field sfhab  as decimal    initial ?  decimals 2
    field sfter  as decimal    initial ?  decimals 2
    field sfvet  as decimal    initial ?  decimals 2
    field tpcha  as character  initial ? 
    field tpcst  as character  initial ? 
    field tptot  as character  initial ? 
    field usdev  as character  initial ? 
    field ushab  as character  initial ? 
    field uster  as character  initial ? 
    field usvet  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
