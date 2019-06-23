/*------------------------------------------------------------------------
File        : local.i
Purpose     : 
Author(s)   : GGA - 2018/01/04
Notes       :
------------------------------------------------------------------------*/

&if defined(nomTable)   = 0 &then &scoped-define nomTable ttLocal
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif

define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
   field dtcsy                as date      initial ?
   field hecsy                as integer   initial ?
   field cdcsy                as character initial ?
   field dtmsy                as date      initial ?
   field hemsy                as integer   initial ?
   field cdmsy                as character initial ?
   field noloc                as int64     initial ?     
   field noimm                as integer   initial ?
   field nolot                as integer   initial ?
   field nbpie                as integer   initial ?
   field ntlot                as character initial ?
   field cdbat                as character initial ?
   field cdesc                as character initial ?
   field cdeta                as character initial ?
   field cdpte                as character initial ?
   field sfree                as decimal   initial ? decimals 2
   field usree                as character initial ?
   field sfpde                as decimal   initial ? decimals 2
   field uspde                as character initial ?
   field sfcor                as decimal   initial ? decimals 2
   field uscor                as character initial ?
   field sfter                as decimal   initial ? decimals 2
   field uster                as character initial ?
   field sfbur                as decimal   initial ? decimals 2
   field usbur                as character initial ?
   field sfcom                as decimal   initial ? decimals 2
   field uscom                as character initial ?
   field sfstk                as decimal   initial ? decimals 2
   field usstk                as character initial ?
   field cdtlb                as character initial ?
   field tpcha                as character initial ?
   field mdcha                as character initial ?
   field fgcha                as logical   initial ?
   field fgfra                as logical   initial ?
   field fgair                as logical   initial ?
   field fgmbl                as logical   initial ?
   field fgwci                as logical   initial ?
   field sfexp                as decimal   initial ? decimals 2
   field usexp                as character initial ?
   field sfaxe                as decimal   initial ? decimals 2
   field usaxe                as character initial ?
   field sfarc                as decimal   initial ? decimals 2
   field usarc                as character initial ?
   field sfnon                as decimal   initial ? decimals 2
   field usnon                as character initial ?
   field nbniv                as integer   initial ?
   field nbprf                as integer   initial ?
   field nbdep                as integer   initial ?
   field nbser                as integer   initial ?
   field noblc                as integer   initial ?
   field cdext                as character initial ?
   field NmOcc                as character initial ?
   field DtEnt                as date      initial ?
   field fgdiv                as logical   initial ?
   field lbgrp                as character initial ?
   field nbgrp                as integer   initial ?
   field usage                as character initial ?
   field lbdiv                as character initial ?
   field dtach                as date      initial ?
   field sfhon                as decimal   initial ? decimals 2
   field ushon                as character initial ?
   field cddev                as character initial ?
   field lbdiv2               as character initial ?
   field lbdiv3               as character initial ?
   field dtmvt                as date      initial ?
   field mtmvt                as decimal   initial ? decimals 2
   field noloc-dec            as decimal   initial ? decimals 0
   field EuGes                as character initial ?
   field TpLot                as character initial ?
   field EuCtt                as character initial ?
   field TpCot                as character initial ?
   field NoCot                as integer   initial ?
   field nolot-cop            as integer   initial ?
   field cdlot-cop            as character initial ?
   field DtFlo                as date      initial ?
   field sfutipriv            as decimal   initial ? decimals 2
   field pcsfutipriv          as decimal   initial ? decimals 2
   field sfannexe             as decimal   initial ? decimals 2
   field pcsfannexe           as decimal   initial ? decimals 2
   field quoPCHall            as decimal   initial ? decimals 2
   field pcQuoPCHall          as decimal   initial ? decimals 2
   field quoPCPalier          as decimal   initial ? decimals 2
   field pcQuoPCPalier        as decimal   initial ? decimals 2
   field quoPCPorte           as decimal   initial ? decimals 2
   field pcQuoPCPorte         as decimal   initial ? decimals 2
   field dtdeb-validite       as date      initial ?
   field dtfin-validite       as date      initial ?
   field cdUsage              as character initial ?
   field etqenergie           as character initial ?
   field etqclimat            as character initial ?
   field sfPkg                as decimal   initial ? decimals 2
   field uspkg                as character initial ?
   field sfdiv                as decimal   initial ? decimals 2
   field usdiv                as character initial ?
   field lbdiv4               as character initial ?
   field lbdiv5               as character initial ?
   field telocc               as character initial ?
   field orien                as character initial ?
   field IdentLocal           as character initial ?
   field Com-Pref-Sec-Plan    as character initial ?
   field CodeCategorie        as character initial ?
   field NoCategorie          as integer   initial ?
   field sfparprc             as decimal   initial ? decimals 2
   field usparprc             as character initial ?
   field sfparscouv           as decimal   initial ? decimals 2
   field usparscouv           as character initial ?
   field sfparsnoncouv        as decimal   initial ? decimals 2
   field usparsnoncouv        as character initial ?
   field lbcpl                as character initial ?
   field obser                as character initial ?
   field sfplancher           as decimal   initial ? decimals 2
   field MontantFamille       as decimal   initial ? decimals 2 extent 10
   field usplancher           as character initial ?
   field sfemprisesol         as decimal   initial ? decimals 2
   field usemprisesol         as character initial ?
   field lbdiv6               as character initial ?
   field CdOffGeo             as character initial ?
   field CdZonage             as character initial ?
   field CdIris               as character initial ?
   field CdLocalisation       as character initial ?
   field CdTrxEntretien       as character initial ?
   field DtTrxEntretien       as date      initial ?
   field CdTrxMiseAuxNormes   as character initial ?
   field DtTrxMiseAuxNormes   as date      initial ?
   field CdTrxRestructuration as character initial ?
   field DtTrxRestructuration as date      initial ?
   field sfpex                as decimal   initial ? decimals 2
   field uspex                as character initial ?
   field dtTimestamp          as datetime  initial ?
   field CRUD                 as character initial ?
   field rRowid               as rowid
.
