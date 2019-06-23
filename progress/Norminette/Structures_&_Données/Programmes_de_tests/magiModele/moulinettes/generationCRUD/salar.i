/*------------------------------------------------------------------------
File        : salar.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttSalar
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdact        as character  initial ? 
    field cdcat        as character  initial ? 
    field cdCIP        as character  initial ? 
    field cdcot        as character  initial ? 
    field cdcsy        as character  initial ? 
    field cdctt        as character  initial ? 
    field cddev        as character  initial ? 
    field cdmot        as character  initial ? 
    field cdmsy        as character  initial ? 
    field cdsta        as character  initial ? 
    field cdtyp        as character  initial ? 
    field clsec        as character  initial ? 
    field codexterne   as character  initial ? 
    field coeff        as integer    initial ? 
    field dtanc        as date       initial ? 
    field dtcsy        as date       initial ? 
    field dtent        as date       initial ? 
    field dtfct        as date       initial ? 
    field dtmsy        as date       initial ? 
    field dtsor        as date       initial ? 
    field Fg13m        as logical    initial ? 
    field fgabs        as logical    initial ? 
    field fgacp        as logical    initial ? 
    field fgcan        as logical    initial ? 
    field fglog        as logical    initial ? 
    field fgmed        as logical    initial ? 
    field fgrpl        as logical    initial ? 
    field fgtps        as logical    initial ? 
    field hecsy        as integer    initial ? 
    field hemsy        as integer    initial ? 
    field insee        as integer    initial ? 
    field insee2       as character  initial ? 
    field lbdiv        as character  initial ? 
    field lbdiv2       as character  initial ? 
    field lbdiv3       as character  initial ? 
    field lbdiv4       as character  initial ? 
    field lbdiv5       as character  initial ? 
    field lbdiv6       as character  initial ? 
    field lbdiv7       as character  initial ? 
    field lbdiv8       as character  initial ? 
    field lbemp        as character  initial ? 
    field MtBrutAnnuel as decimal    initial ?  decimals 2
    field NbAcharge    as integer    initial ? 
    field NbEnfants    as integer    initial ? 
    field NbHeures     as decimal    initial ?  decimals 2
    field nbimp        as integer    initial ? 
    field nbpie        as integer    initial ? 
    field NbUV         as decimal    initial ?  decimals 2
    field Nivea        as integer    initial ? 
    field NoIDCC       as character  initial ? 
    field norol        as int64      initial ? 
    field nosec        as character  initial ? 
    field rgsec        as character  initial ? 
    field Surface      as decimal    initial ?  decimals 2
    field tbcle        as character  initial ? 
    field tbimp        as character  initial ? 
    field tbprc        as decimal    initial ?  decimals 3
    field tbtgl        as logical    initial ? 
    field tprol        as character  initial ? 
    field txhor        as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
