/*------------------------------------------------------------------------
File        : imble.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttImble
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field afdev          as integer    initial ? 
    field afhab          as integer    initial ? 
    field afhob          as integer    initial ? 
    field afhon          as integer    initial ? 
    field after          as integer    initial ? 
    field afvet          as integer    initial ? 
    field cdAFUL         as character  initial ? 
    field cdcad          as character  initial ? 
    field cdcsy          as character  initial ? 
    field cddev          as character  initial ? 
    field cdext          as character  initial ? 
    field CdInternet     as character  initial ? 
    field CdIris         as character  initial ? 
    field CdLocalisation as character  initial ? 
    field cdmsy          as character  initial ? 
    field CdOffGeo       as character  initial ? 
    field cdpln          as character  initial ? 
    field CdQualite      as character  initial ? 
    field cdres          as character  initial ? 
    field cdsec          as character  initial ? 
    field cdsse          as character  initial ? 
    field CdZonage       as character  initial ? 
    field dtcsy          as date       initial ? 
    field dtmsy          as date       initial ? 
    field dtrenov        as date       initial ? 
    field fgservitude    as logical    initial ? 
    field fgven          as logical    initial ? 
    field hecsy          as integer    initial ? 
    field hemsy          as integer    initial ? 
    field lbAFUL         as character  initial ? 
    field lbdiv          as character  initial ? 
    field lbdiv2         as character  initial ? 
    field lbdiv3         as character  initial ? 
    field lbdiv4         as character  initial ? 
    field lbimgctent     as character  initial ? 
    field lbnom          as character  initial ? 
    field lbservitude    as character  initial ? 
    field lbtitctent     as character  initial ? 
    field mdcha          as character  initial ? 
    field mdchd          as character  initial ? 
    field mdcli          as character  initial ? 
    field mdfra          as character  initial ? 
    field nbant          as integer    initial ? 
    field nbasc          as integer    initial ? 
    field NbBAES         as integer    initial ? 
    field nbbat          as integer    initial ? 
    field NbColSec       as integer    initial ? 
    field NbDAD          as integer    initial ? 
    field NbDeclench     as integer    initial ? 
    field nbesc          as integer    initial ? 
    field nbeta          as integer    initial ? 
    field nbext          as integer    initial ? 
    field NbExutoir      as integer    initial ? 
    field nbfer          as integer    initial ? 
    field nbint          as integer    initial ? 
    field nblet          as integer    initial ? 
    field nblog          as integer    initial ? 
    field nbmch          as integer    initial ? 
    field nbpkg          as integer    initial ? 
    field nbppe          as integer    initial ? 
    field nbpte          as integer    initial ? 
    field NbPteCF        as integer    initial ? 
    field NbSSI          as integer    initial ? 
    field nbsss          as integer    initial ? 
    field NbSurpres      as integer    initial ? 
    field nbtap          as integer    initial ? 
    field nbttp          as integer    initial ? 
    field nbvid          as integer    initial ? 
    field NbVigik        as integer    initial ? 
    field NbVoletD       as integer    initial ? 
    field noblc          as integer    initial ? 
    field nocad          as integer    initial ? 
    field noimm          as integer    initial ? 
    field nopln          as integer    initial ? 
    field norol          as integer    initial ? 
    field ntbie          as character  initial ? 
    field permis         as character  initial ? 
    field sfdev          as decimal    initial ?  decimals 2
    field sfhab          as decimal    initial ?  decimals 2
    field sfhob          as decimal    initial ?  decimals 2
    field sfhon          as decimal    initial ?  decimals 2
    field sfter          as decimal    initial ?  decimals 2
    field sfvet          as decimal    initial ?  decimals 2
    field tpcha          as character  initial ? 
    field tpcst          as character  initial ? 
    field tpimm          as character  initial ? 
    field tplogoctent    as character  initial ? 
    field TpPropriete    as character  initial ? 
    field tprol          as character  initial ? 
    field tptot          as character  initial ? 
    field usdev          as character  initial ? 
    field ushab          as character  initial ? 
    field ushob          as character  initial ? 
    field ushon          as character  initial ? 
    field uster          as character  initial ? 
    field usvet          as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
