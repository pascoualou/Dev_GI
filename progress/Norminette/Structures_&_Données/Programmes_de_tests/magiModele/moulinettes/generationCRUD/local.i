/*------------------------------------------------------------------------
File        : local.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttLocal
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdbat                as character  initial ? 
    field cdcsy                as character  initial ? 
    field cddev                as character  initial ? 
    field cdesc                as character  initial ? 
    field cdeta                as character  initial ? 
    field cdext                as character  initial ? 
    field CdIris               as character  initial ? 
    field CdLocalisation       as character  initial ? 
    field cdlot-cop            as character  initial ? 
    field cdmsy                as character  initial ? 
    field CdOffGeo             as character  initial ? 
    field cdpte                as character  initial ? 
    field cdtlb                as character  initial ? 
    field CdTrxEntretien       as character  initial ? 
    field CdTrxMiseAuxNormes   as character  initial ? 
    field CdTrxRestructuration as character  initial ? 
    field cdUsage              as character  initial ? 
    field CdZonage             as character  initial ? 
    field CodeCategorie        as character  initial ? 
    field Com-Pref-Sec-Plan    as character  initial ? 
    field dtach                as date       initial ? 
    field dtcsy                as date       initial ? 
    field dtdeb-validite       as date       initial ? 
    field DtEnt                as date       initial ? 
    field dtfin-validite       as date       initial ? 
    field DtFlo                as date       initial ? 
    field dtmsy                as date       initial ? 
    field dtmvt                as date       initial ? 
    field DtTrxEntretien       as date       initial ? 
    field DtTrxMiseAuxNormes   as date       initial ? 
    field DtTrxRestructuration as date       initial ? 
    field etqclimat            as character  initial ? 
    field etqenergie           as character  initial ? 
    field EuCtt                as character  initial ? 
    field EuGes                as character  initial ? 
    field fgair                as logical    initial ? 
    field fgcha                as logical    initial ? 
    field fgdiv                as logical    initial ? 
    field fgfra                as logical    initial ? 
    field fgmbl                as logical    initial ? 
    field fgwci                as logical    initial ? 
    field hecsy                as integer    initial ? 
    field hemsy                as integer    initial ? 
    field IdentLocal           as character  initial ? 
    field IndEnergiePrimaire   as decimal    initial ?  decimals 2
    field IndGazEffetSerre     as decimal    initial ?  decimals 2
    field lbcpl                as character  initial ? 
    field lbdiv                as character  initial ? 
    field lbdiv2               as character  initial ? 
    field lbdiv3               as character  initial ? 
    field lbdiv4               as character  initial ? 
    field lbdiv5               as character  initial ? 
    field lbdiv6               as character  initial ? 
    field lbgrp                as character  initial ? 
    field mdcha                as character  initial ? 
    field MontantFamille       as decimal    initial ?  decimals 2
    field mtmvt                as decimal    initial ?  decimals 2
    field nbdep                as integer    initial ? 
    field nbgrp                as integer    initial ? 
    field nbniv                as integer    initial ? 
    field nbpie                as integer    initial ? 
    field nbprf                as integer    initial ? 
    field nbser                as integer    initial ? 
    field NmOcc                as character  initial ? 
    field noblc                as integer    initial ? 
    field NoCategorie          as integer    initial ? 
    field NoCot                as integer    initial ? 
    field noimm                as integer    initial ? 
    field noloc                as int64      initial ? 
    field noloc-dec            as decimal    initial ?  decimals 0
    field nolot                as integer    initial ? 
    field nolot-cop            as integer    initial ? 
    field ntlot                as character  initial ? 
    field obser                as character  initial ? 
    field orien                as character  initial ? 
    field pcQuoPCHall          as decimal    initial ?  decimals 2
    field pcQuoPCPalier        as decimal    initial ?  decimals 2
    field pcQuoPCPorte         as decimal    initial ?  decimals 2
    field pcsfannexe           as decimal    initial ?  decimals 2
    field pcsfutipriv          as decimal    initial ?  decimals 2
    field quoPCHall            as decimal    initial ?  decimals 2
    field quoPCPalier          as decimal    initial ?  decimals 2
    field quoPCPorte           as decimal    initial ?  decimals 2
    field sfannexe             as decimal    initial ?  decimals 2
    field sfarc                as decimal    initial ?  decimals 2
    field sfaxe                as decimal    initial ?  decimals 2
    field sfbur                as decimal    initial ?  decimals 2
    field sfcom                as decimal    initial ?  decimals 2
    field sfcor                as decimal    initial ?  decimals 2
    field sfdiv                as decimal    initial ?  decimals 2
    field sfemprisesol         as decimal    initial ?  decimals 2
    field sfexp                as decimal    initial ?  decimals 2
    field sfhon                as decimal    initial ?  decimals 2
    field sfnon                as decimal    initial ?  decimals 2
    field sfparprc             as decimal    initial ?  decimals 2
    field sfparscouv           as decimal    initial ?  decimals 2
    field sfparsnoncouv        as decimal    initial ?  decimals 2
    field sfpde                as decimal    initial ?  decimals 2
    field sfpex                as decimal    initial ?  decimals 2
    field sfPkg                as decimal    initial ?  decimals 2
    field sfplancher           as decimal    initial ?  decimals 2
    field sfree                as decimal    initial ?  decimals 2
    field sfscu                as decimal    initial ?  decimals 2
    field sfstk                as decimal    initial ?  decimals 2
    field sfter                as decimal    initial ?  decimals 2
    field sfutipriv            as decimal    initial ?  decimals 2
    field telocc               as character  initial ? 
    field tpcha                as character  initial ? 
    field TpCot                as character  initial ? 
    field TpLot                as character  initial ? 
    field usage                as character  initial ? 
    field usarc                as character  initial ? 
    field usaxe                as character  initial ? 
    field usbur                as character  initial ? 
    field uscom                as character  initial ? 
    field uscor                as character  initial ? 
    field usdiv                as character  initial ? 
    field usemprisesol         as character  initial ? 
    field usexp                as character  initial ? 
    field ushon                as character  initial ? 
    field usnon                as character  initial ? 
    field usparprc             as character  initial ? 
    field usparscouv           as character  initial ? 
    field usparsnoncouv        as character  initial ? 
    field uspde                as character  initial ? 
    field uspkg                as character  initial ? 
    field usplancher           as character  initial ? 
    field usree                as character  initial ? 
    field usscu                as character  initial ? 
    field usstk                as character  initial ? 
    field uster                as character  initial ? 
    field valetqclimat         as integer    initial ? 
    field valetqenergie        as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
