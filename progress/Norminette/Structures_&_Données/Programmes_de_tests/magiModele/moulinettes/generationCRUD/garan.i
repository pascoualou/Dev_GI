/*------------------------------------------------------------------------
File        : garan.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttGaran
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdass       as character  initial ? 
    field cdcsy       as character  initial ? 
    field CdDebCal    as character  initial ? 
    field cddev       as character  initial ? 
    field cdmsy       as character  initial ? 
    field cdper       as character  initial ? 
    field cdperbord   as character  initial ? 
    field CdTriEdi    as character  initial ? 
    field cdtva       as character  initial ? 
    field convention  as character  initial ? 
    field cpgar       as character  initial ? 
    field dtcsy       as date       initial ? 
    field dtmsy       as date       initial ? 
    field fgGRL       as logical    initial ? 
    field fgtot       as logical    initial ? 
    field hecsy       as integer    initial ? 
    field hemsy       as integer    initial ? 
    field lbdiv       as character  initial ? 
    field lbdiv2      as character  initial ? 
    field lbdiv3      as character  initial ? 
    field mtcot       as decimal    initial ?  decimals 2
    field nbmca       as decimal    initial ?  decimals 2
    field nbmfr       as decimal    initial ?  decimals 2
    field nobar       as integer    initial ? 
    field nocontrat   as character  initial ? 
    field noctt       as integer    initial ? 
    field nompartres  as character  initial ? 
    field norolcour   as integer    initial ? 
    field tpbar       as character  initial ? 
    field tpctt       as character  initial ? 
    field tpmnt       as character  initial ? 
    field tprolcour   as character  initial ? 
    field txcot       as decimal    initial ?  decimals 4
    field txcot-dev   as decimal    initial ?  decimals 2
    field txhon       as decimal    initial ?  decimals 4
    field txnor       as decimal    initial ?  decimals 2
    field txrec       as decimal    initial ?  decimals 2
    field txres       as decimal    initial ?  decimals 4
    field typefac-cle as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
