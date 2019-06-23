/*------------------------------------------------------------------------
File        : location.i
Purpose     : 1106/0142 - AGF Module LOCATIONS
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttLocation
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field AncLoy-tbloy  as decimal    initial ?  decimals 2
    field AncLoy-tbm2   as decimal    initial ?  decimals 2
    field AncLoy-tbnat  as character  initial ? 
    field anneeplan     as integer    initial ? 
    field anneerlv      as integer    initial ? 
    field anper         as integer    initial ? 
    field bail-cddur    as character  initial ? 
    field bail-nbdur    as integer    initial ? 
    field cdcmp         as character  initial ? 
    field cdcsy         as character  initial ? 
    field cdirv         as integer    initial ? 
    field cdmsy         as character  initial ? 
    field cdstatut      as character  initial ? 
    field cdusage       as character  initial ? 
    field commentaire   as character  initial ? 
    field DG-fgrev      as logical    initial ? 
    field DG-nbmoi      as decimal    initial ?  decimals 3
    field dtarch        as date       initial ? 
    field dtcontrol     as date       initial ? 
    field dtcsy         as date       initial ? 
    field dtdispo       as date       initial ? 
    field dtfiche       as date       initial ? 
    field dtfin         as date       initial ? 
    field dtmsy         as date       initial ? 
    field dtnonconform  as date       initial ? 
    field dtrecep       as date       initial ? 
    field dtsign        as date       initial ? 
    field dtsor         as date       initial ? 
    field dtvalid       as date       initial ? 
    field fgair         as logical    initial ? 
    field fgarch        as logical    initial ? 
    field fgAsc         as logical    initial ? 
    field fgdigicode    as logical    initial ? 
    field fgEaucha      as logical    initial ? 
    field FgInterphone  as logical    initial ? 
    field fgplan        as logical    initial ? 
    field fgrlv         as logical    initial ? 
    field fgrub-pkg     as logical    initial ? 
    field fgrub-taxbur  as logical    initial ? 
    field fgrub-taxfon  as logical    initial ? 
    field fgtrav1       as logical    initial ? 
    field fgtrav2       as logical    initial ? 
    field fgtrav3       as logical    initial ? 
    field fisc-cdcal    as character  initial ? 
    field fisc-cdtaux   as character  initial ? 
    field fisc-prcloc   as decimal    initial ?  decimals 2
    field fisc-regime   as character  initial ? 
    field fisc-tptaux   as character  initial ? 
    field gardien-nom   as character  initial ? 
    field gardien-tel   as character  initial ? 
    field hecsy         as integer    initial ? 
    field hemsy         as integer    initial ? 
    field LbConfort     as character  initial ? 
    field lbdiv         as character  initial ? 
    field lbdiv2        as character  initial ? 
    field lbdiv3        as character  initial ? 
    field LbdurTrx      as character  initial ? 
    field LbObsTrav     as character  initial ? 
    field ListePieces   as character  initial ? 
    field mdAir         as character  initial ? 
    field mdcha         as character  initial ? 
    field mdEaucha      as character  initial ? 
    field mtbudeng-mdt  as decimal    initial ?  decimals 2
    field mtbudeng-pro  as decimal    initial ?  decimals 2
    field mtbudpre-mdt  as decimal    initial ?  decimals 2
    field mtbudpre-pro  as decimal    initial ?  decimals 2
    field mtentloc      as decimal    initial ?  decimals 2
    field mtentpro      as decimal    initial ?  decimals 2
    field mtloym2       as decimal    initial ?  decimals 2
    field mtrub-charges as decimal    initial ?  decimals 2
    field mtrub-CRL     as decimal    initial ?  decimals 2
    field mtrub-loyer   as decimal    initial ?  decimals 2
    field mtrub-pkg     as decimal    initial ?  decimals 2
    field mtrub-taxbur  as decimal    initial ?  decimals 2
    field mtrub-taxfon  as decimal    initial ?  decimals 2
    field mtrub-TVA     as decimal    initial ?  decimals 2
    field mttrav        as decimal    initial ?  decimals 2
    field mttrav-loc    as decimal    initial ?  decimals 2
    field mttrav-pro    as decimal    initial ?  decimals 2
    field nbpkgdisp     as integer    initial ? 
    field noapp         as integer    initial ? 
    field nocon         as integer    initial ? 
    field noderloc      as decimal    initial ?  decimals 0
    field nofiche       as integer    initial ? 
    field noman         as integer    initial ? 
    field NomCompletEdi as character  initial ? 
    field NomDot        as character  initial ? 
    field nomdtass      as integer    initial ? 
    field NoNewLoc      as decimal    initial ?  decimals 0
    field noper         as integer    initial ? 
    field norolges      as integer    initial ? 
    field NouLoy-tbloy  as decimal    initial ?  decimals 2
    field NouLoy-tbm2   as decimal    initial ?  decimals ?
    field NouLoy-tbnat  as character  initial ? 
    field Organisme     as character  initial ? 
    field qtt-cdper     as character  initial ? 
    field qtt-terme     as character  initial ? 
    field rev-cddur     as character  initial ? 
    field rev-nbdur     as integer    initial ? 
    field rub-perio     as character  initial ? 
    field sig1-nom      as character  initial ? 
    field sig1-prof     as character  initial ? 
    field sig2-nom      as character  initial ? 
    field sig2-prof     as character  initial ? 
    field sig3-nom      as character  initial ? 
    field sig3-prof     as character  initial ? 
    field tbdesign      as character  initial ? 
    field tpcha         as character  initial ? 
    field tpcon         as character  initial ? 
    field tpmdtass      as character  initial ? 
    field tprolges      as character  initial ? 
    field typefiche     as character  initial ? 
    field UL-surfanx    as decimal    initial ?  decimals 2
    field UL-surfpond   as decimal    initial ?  decimals 2
    field UL-surfutil   as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
