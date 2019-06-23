/*------------------------------------------------------------------------
File        : prevoy.i
Purpose     : Paie : Paramétrage des prévoyances 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPrevoy
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy   as character  initial ? 
    field cdins   as character  initial ? 
    field cdmsy   as character  initial ? 
    field dtcsy   as date       initial ? 
    field dtmsy   as date       initial ? 
    field fgcsg   as logical    initial ? 
    field fgimp   as logical    initial ? 
    field hecsy   as integer    initial ? 
    field hemsy   as integer    initial ? 
    field lbdiv   as character  initial ? 
    field lbdiv2  as character  initial ? 
    field lbdiv3  as character  initial ? 
    field lbpre   as character  initial ? 
    field nopre   as integer    initial ? 
    field refctt  as character  initial ? 
    field tbbas   as character  initial ? 
    field tbcsg   as logical    initial ? 
    field tbdiv   as decimal    initial ?  decimals 3
    field tbimp   as logical    initial ? 
    field tbmod   as character  initial ? 
    field tbmta   as decimal    initial ?  decimals 2
    field tbmtm   as decimal    initial ?  decimals 2
    field tbpre   as logical    initial ? 
    field tbrub   as integer    initial ? 
    field tbtxp-A as decimal    initial ?  decimals 4
    field tbtxp-B as decimal    initial ?  decimals 4
    field tbtxs-A as decimal    initial ?  decimals 4
    field tbtxs-B as decimal    initial ?  decimals 4
    field tpbas   as character  initial ? 
    field tppre   as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
