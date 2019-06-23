/*------------------------------------------------------------------------
File        : DtVen.i
Purpose     : Chaine travaux : Ventil ana ligne facture
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttDtven
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field CdCle       as character  initial ? 
    field CdDve       as character  initial ? 
    field CdRgp       as character  initial ? 
    field CdTva       as integer    initial ? 
    field LbEcr       as character  initial ? 
    field MtDev       as decimal    initial ?  decimals 2
    field MtInt       as decimal    initial ?  decimals 2
    field MtTva       as decimal    initial ?  decimals 2
    field NoFac       as integer    initial ? 
    field NoFis       as character  initial ? 
    field NoInt       as int64      initial ? 
    field NoOrd       as integer    initial ? 
    field NoRef       as integer    initial ? 
    field NoRub       as character  initial ? 
    field NoSsr       as character  initial ? 
    field PrVen       as decimal    initial ?  decimals 2
    field TpVen       as logical    initial ? 
    field tx-recuptva as decimal    initial ?  decimals 2
    field TxCle       as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
